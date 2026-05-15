import 'package:socket_io_client/socket_io_client.dart' as IO;

class TelemetryService {
  static late IO.Socket socket;

  static void connect() {
    socket = IO.io('http://192.168.1.80:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Conectado al servidor Socket.IO');
    });

    socket.onDisconnect((_) {
      print("Desconectado del servidor");
    });
  }

  //Enviar evento telemetríco
  static void sendEvent({required String eventType, required String details}) {
    socket.emit('telemetry_event', {
      'eventType': eventType,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Evento enviado');
  }
}
