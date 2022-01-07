import 'dart:html';

import '../whychat.dart';

class RoomClientSocket {
  RoomClientSocket(String username)
      : socket = WebSocket('ws://localhost:8080/room?username=$username') {
    _initListeners();
  }

  final WebSocket socket;

  send(String data) => socket.send(data);

  close() => socket.close();

  _initListeners() {
    socket.onOpen.listen((evt) {
      print('Socket is open');
      send(encodeMessage(ActionTypes.newChat, "", ""));
    });

    socket.onError.listen((evt) {
      print('Problems with socket. $evt');
    });

    socket.onClose.listen((evt) {
      print('Socket is closed');
    });
  }
}