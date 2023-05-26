import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'mqtthandler.dart';

class Home extends StatefulWidget {

  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MqttHandler mqttHandler = MqttHandler();

  var txtTemp = TextEditingController();
  var txtHum = TextEditingController();
  var txtGas = TextEditingController();
  late Timer timer;

  bool ativo=true;

  @override
  void initState() {
    super.initState();
    mqttHandler.connect();
  }

  @override
  void dispose() {
    timer.cancel(); // Cancelar o Timer ao descartar o widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Sample Code'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _receber(),
              _publicar(),
              _publicarAuto()

            ],

          ),
        ),

      ),
    );
  }

  _publicarAuto() {

    return FloatingActionButton(
      onPressed: () =>
          setState(() {
            ativo = ativo?false:true;
            publicarAuto();
          }),
      child: Text(ativo ? "Desativar" : "Ativar"),
    );
  }

  publicarAuto(){
    print("auto pressionado");
    if (ativo) {
    timer = Timer.periodic(Duration(seconds: 2), (timer){
    mqttHandler.publishMessage(
          generateRandomData(0, 40).toString(), "temperatura");
      mqttHandler.publishMessage(
          generateRandomData(0, 20).toString(), "humidade");
      mqttHandler.publishMessage(
          generateRandomData(0, 10).toString(), "gases");
  });
  } else {
  timer.cancel(); // Cancelar o Timer
  }
  }

  int generateRandomData(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min);
  }

  _publicar() {
    return Column(
      children: [
        TextFormField(decoration: InputDecoration(hintText: "Temperatura"),controller: txtTemp),
        TextFormField(decoration: InputDecoration(hintText: "Humidade"),controller: txtHum),
        TextFormField(decoration: InputDecoration(hintText: "Gases"),controller: txtGas),
        FloatingActionButton(
          onPressed: () => setState(() {
            mqttHandler.publishMessage(txtTemp.text,"temperatura");
            mqttHandler.publishMessage(txtHum.text,"humidade");
            mqttHandler.publishMessage(txtGas.text,"gases");
          }
          ),
          tooltip: 'Publicar',
          child: const Text("Enviar"),
        ),
      ]
    );

  }

  _receber() {
    return Column(
      children: [
        Text('Temperatura:',
            style: TextStyle(color: Colors.black, fontSize: 25)),
        ValueListenableBuilder<String>(
          builder: (BuildContext context, String value, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('$value',
                    style: TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 35))
              ],
            );
          },
          valueListenable: mqttHandler.temperatura,
        ),

        const Text('Humidade:',
            style: TextStyle(color: Colors.black, fontSize: 25)),
        ValueListenableBuilder<String>(
          builder: (BuildContext context, String value, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('$value',
                    style: TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 35))
              ],
            );
          },
          valueListenable: mqttHandler.humidade,
        ),

        const Text('Gases:',
            style: TextStyle(color: Colors.black, fontSize: 25)),
        ValueListenableBuilder<String>(
          builder: (BuildContext context, String value, Widget? child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('$value',
                    style: TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 35))
              ],
            );
          },
          valueListenable: mqttHandler.gases,
        ),
      ],
    );
  }
}
