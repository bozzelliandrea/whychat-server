import 'dart:io';

class Chatter {
  final HttpSession session;
  final WebSocket socket;
  final String name;

  Chatter(this.session, this.socket, this.name);
}

class RoomSession {
  final List<Chatter> _chatters = [];

  addChatter(HttpRequest request) async {
    String username = request.uri.queryParameters['username']!;
    WebSocket ws = await WebSocketTransformer.upgrade(request);
    Chatter chatter = Chatter(request.session, ws, username);
    // Listen for incoming messages, handle errors and close events
    chatter.socket.listen(
      (data) => _handleMessage(chatter, data),
      onError: (err) => print('Error with socket ${err.message}'),
      onDone: () => _removeChatter(chatter),
    );
    _chatters.add(chatter);
    print('[ADDED CHATTER]: ${chatter.name}');
  }

  _handleMessage(Chatter chatter, String data) {
    chatter.socket.add('You said: $data');
    _notifyChatters(chatter, data);
  }

  _notifyChatters(Chatter exclude, String message) {
    _chatters
        .where((chatter) => chatter.name != exclude.name)
        .toList()
        .forEach((chatter) => chatter.socket.add(message));
  }

  _removeChatter(Chatter chatter) {
    print('[REMOVING CHATTER]: ${chatter.name}');
    _chatters.removeWhere((c) => c.name == chatter.name);
    _notifyChatters(chatter, '${chatter.name} has left the chat.');
  }
}
