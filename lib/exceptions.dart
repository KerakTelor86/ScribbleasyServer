class ServerFullException implements Exception {
  String errMsg() => 'Server is full.';
}

class MaxSessionsException implements Exception {
  String errMsg() => 'Max number of sessions reached.';
}

class SessionFullException implements Exception {
  String errMsg() => 'Session is full.';
}

class UnknownRequestException implements Exception {
  String errMsg() => 'Unknown request';
}
