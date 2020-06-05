import 'dart:collection';
import 'package:Server/exceptions.dart';
import 'package:Server/misc.dart';
import 'package:Server/session.dart';

class SessionManager {
  final HashSet<int> _unusedIds = HashSet();
  final List<Session> sessions;
  final List<String> sessionNames;
  final List<int> sessionPasswords;

  SessionManager(int maxSessions)
      : sessions = List(maxSessions),
        sessionNames = List(maxSessions),
        sessionPasswords = List(maxSessions) {
    for (var i = 0; i < maxSessions; ++i) _unusedIds.add(i);
  }

  void handleRequest(User user, Data data) {
    switch (data.contents['type']) {
      case 'createSession': // Create session
        return createSession(user, data);
        break;
      case 'joinSession': // Join session
        return connectUser(user, data);
        break;
      case 'quitSession': // Quit session
        return disconnectUser(user);
        break;
      case 'getSessions': // Session list
        return sendSessions(user);
        break;
      case 'sessionData': // Forward to session
        return sessions[user.sessionId].handleData(user, data);
        break;
      default:
        // throw UnknownRequestException();
        break;
    }
  }

  void createSession(User user, Data data) {
    try {
      int id = newSession(data);
      data.contents['id'] = id;
      connectUser(user, data);
    } on MaxSessionsException catch (e) {
      var reply = Data();
      reply['type'] = 'sessionAuth';
      reply['auth'] = 0;
      reply['reason'] = 'Session limit reached.';
      user.sendData(reply.toString());
    }
  }

  void connectUser(User user, Data data) {
    var id = data.contents['id'];
    var reply = Data();
    reply.contents['type'] = 'sessionAuth';
    if (data.contents['pwHash'] == sessionPasswords[id]) {
      try {
        sessions[id].addUser(user);
      } on SessionFullException catch (e) {
        reply['auth'] = 0;
        reply['reason'] = 'Session full.';
        user.sendData(reply.toString());
        return;
      }
      user.sessionId = data.contents['id'];
      reply.contents['auth'] = 1;
      user.sendData(reply.toString());
      print('${sessionNames[id]}: CONNECTED: USER ${user.username}');
    } else {
      reply.contents['auth'] = 0;
      reply['reason'] = 'Invalid password.';
      user.sendData(reply.toString());
      print('${sessionNames[id]}: INVALID PASSWORD: USER ${user.username}');
    }
  }

  void disconnectUser(User user) {
    int id = user.sessionId;
    if (id != null) {
      sessions[id].removeUser(user);
      user.sessionId = null;
      print('${sessionNames[id]}: DISCONNECTED: USER ${user.username}');
      if (sessions[id].users.isEmpty) {
        deleteSession(id);
      }
    }
  }

  int newSession(Data data) {
    int id = getSessionId();
    Session sess = Session(data.contents['maxUsers']);
    sessions[id] = sess;
    sessionNames[id] = data.contents['name'];
    sessionPasswords[id] = data.contents['pwHash'];
    print('SESSION CREATED: ${sessionNames[id]}');
    return id;
  }

  void deleteSession(int id) {
    print('SESSION DELETED: ${sessionNames[id]}');
    sessions[id] = null;
    sessionPasswords[id] = null;
    sessionNames[id] = null;
    returnSessionId(id);
  }

  int getSessionId() {
    if (_unusedIds.isEmpty) {
      throw MaxSessionsException();
    }
    int id = _unusedIds.first;
    _unusedIds.remove(id);
    return id;
  }

  void sendSessions(User user) {
    Data list = Data();
    list['type'] = 'sessionList';
    list['sessions'] = sessionNames;
    user.sendData(list.toString());
  }

  void returnSessionId(int id) {
    _unusedIds.add(id);
  }
}
