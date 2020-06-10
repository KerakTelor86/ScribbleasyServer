import 'dart:io';
import 'dart:collection';
import 'dart:async';
import 'package:Server/exceptions.dart';
import 'package:Server/misc.dart';
import 'package:Server/session_manager.dart';

class Server {
  final HashSet<int> _unusedIds = HashSet();
  final List<User> _users;
  final SessionManager _sessionManager;

  Server(int maxUsers, int maxSessions)
      : _sessionManager = SessionManager(maxSessions),
        _users = List(maxUsers) {
    for (var i = 0; i < maxUsers; ++i) _unusedIds.add(i);
  }

  Future<void> start(String ip, int port) async {
    var http_server = await HttpServer.bind(ip, port);
    print('Listening on ${ip}:${port}');

    await for (HttpRequest req in http_server) {
      if (req.uri.path == '/connect') {
        _connectUser(req, req.uri.queryParameters['username']);
      }
    }
  }

  void stop() {
    // TODO: Cleanly stop server
    print('Server closing, disconnecting everyone...');
    for (User i in _users) {
      _disconnectUser(i);
    }
  }

  Future<void> _connectUser(HttpRequest req, String username) async {
    print('CONNECTING: $username');
    var ws = await WebSocketTransformer.upgrade(req);
    var confirmation = Data();
    confirmation['type'] = 'auth';
    try {
      var id = _getUserId();
      var user = User(id, username, ws);
      ws.listen((data) => _handleMsg(user, Data.fromString(data)),
          onError: (err) => _handleError(user, err),
          onDone: () => _disconnectUser(user));
      _users[id] = user;
      confirmation['auth'] = 1;
      user.sendData(confirmation.toString());
      print('LOGGED IN: $username');
    } on ServerFullException catch (e) {
      confirmation['auth'] = 0;
      ws.add(confirmation.toString());
      print('SERVER FULL: $username');
    }
  }

  void _handleMsg(User user, Data data) {
    if (data['type'] != 'logout') {
      return _sessionManager.handleRequest(user, data);
    } else {
      return _disconnectUser(user);
    }
  }

  void _handleError(User user, Exception err) {
    print('ERROR: ${user.username}');
    print('${err.toString()}');
  }

  void _disconnectUser(User user) {
    _sessionManager.disconnectUser(user);
    _returnUserId(user.userId);
    _users[user.userId] = null;
    user.socket.close(6969, 'Server shutting down');
    print('LOGGED OUT: ${user.username}');
  }

  int _getUserId() {
    if (_unusedIds.isEmpty) {
      throw ServerFullException();
    }
    int id = _unusedIds.first;
    _unusedIds.remove(id);
    return id;
  }

  void _returnUserId(int id) {
    _unusedIds.add(id);
  }
}
