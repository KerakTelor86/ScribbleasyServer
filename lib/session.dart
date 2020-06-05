import 'dart:collection';
import 'package:Server/exceptions.dart';
import 'package:Server/misc.dart';
import 'package:Server/board.dart';

class Session {
  final int maxUsers;
  final Board board = Board();
  final HashSet<User> users = HashSet();

  Session(this.maxUsers);

  void handleData(User user, Data data) {
    switch (data['reqType']) {
      case 'draw':
        board.applyUpdate(data);
        for (var i in users) {
          if (i != user) {
            i.sendData(data.toString());
          }
        }
        break;
      case 'sync':
        syncUser(user);
        break;
      default:
        break;
    }
  }

  void syncUser(User user) async {
    Data reply = await board.export();
    reply['type'] = 'sessionData';
    reply['reqType'] = 'sync';
    user.sendData(reply.toString());
  }

  void addUser(User user) {
    if (users.length == maxUsers) {
      throw SessionFullException();
    }
    users.add(user);
    syncUser(user);
  }

  void removeUser(User user) {
    users.remove(user);
  }
}
