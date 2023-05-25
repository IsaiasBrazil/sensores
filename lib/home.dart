import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MqttServerClient client ;
  String temperature = 'N/A';
  String humidity = 'N/A';
  String toxicGas = 'N/A';
  @override
  void  initState() {
    super.initState();
    client  = MqttServerClient('test.mosquitto.org', '');
    connect();
  }
  void connect() async {
    // Configurar a conexão MQTT
    // ...
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FloatingActionButton(tooltip: "Enviar dados sensores",onPressed: (){_simularSensores(){};},child: const Icon(Icons.send_sharp),),
      ),
    );
  }
}
