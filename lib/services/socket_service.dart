import 'package:Teriya/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../constants.dart';
import '../models.dart';

class SocketService extends ChangeNotifier {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  SocketService() {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socket = IO.io(
        Constants.socketUrl,
        IO.OptionBuilder()
            .setPath("/ws/socket.io/")
            .setTransports(['websocket']).build());

    _socket.onConnect((_) {
      print("Socket connected successfully");
    });

    _socket.onDisconnect((_) {
      print("socket disconnected !");
    });

    _socket.connect();
  }

  dynamic onUserEvent(
    BuildContext context,
    String eventName,
    dynamic Function(dynamic) handler,
  ) {
    final TeriyaUser user = Provider.of<AuthService>(context).user!;
    return _socket.on("users.${user.id}.$eventName", handler);
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
