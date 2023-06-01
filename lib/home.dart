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

  late bool ativo = false;

  late bool desastre= false;

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
        title: const Text('Sensores'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text((ativo?"Sensor automático ativo":"Sensor automático desligado.")+(desastre?"+ desastre ativo":""),style: TextStyle(color: ativo?Colors.red:Colors.blue,fontSize: 20) ),
              _receber(),
              _publicar(),
              Container(
                child: ElevatedButton(
                  onPressed: _ativarAuto,
                  child: Text(ativo ? "Desativar auto" : "Ativar auto"),
                ),
              ),
              ElevatedButton(
                onPressed: _ativarDesastre,
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(desastre?Colors.red:Colors.blue)),
                child: Text(desastre ? "Desativar desastre" : "Causar desastre"),
              )
            ],

          ),
        ),

      ),
    );
  }

  _ativarDesastre(){
    setState(() {
      desastre = !desastre;
    });
  }

  _ativarAuto(){
    setState(() {
      ativo = !ativo;
      publicarAuto();
    });
  }

  publicarAuto(){
    print("auto pressionado");
    if (ativo) {
      timer = Timer.periodic(Duration(seconds: 2), (timer){
        var tmin = desastre?-10:18; //ideal entre 18 e 24º
        var tmax = desastre?50:24; //
        var hmin = desastre?0:30; //ideal entre 30 e 70%
        var hmax = desastre?100:70; //=
        var gmin = desastre?20:0; //ideal abaixo de 20
        var gmax = desastre?100:20; //=

        mqttHandler.publishMessage(
            generateRandomData(tmin, tmax).toString(), "av1c0ntr0lz2er0/temperatura");
        mqttHandler.publishMessage(
            generateRandomData(hmin,hmax).toString(), "av1c0ntr0lz2er0/humidade");
        mqttHandler.publishMessage(
            generateRandomData(gmin, gmax).toString(), "av1c0ntr0lz2er0/gases");
      });
    } else {
      timer.cancel(); // Cancelar o Timer
    }
    setState(() {

    });
  }

  int generateRandomData(int min, int max) {
    final Random random = Random();
    return min + random.nextInt(max - min);
  }

  _publicar() {
    return Column(
        children: [
          TextFormField(decoration: InputDecoration(hintText: "Temperatura"),controller: txtTemp, keyboardType: TextInputType.number,),
          TextFormField(decoration: InputDecoration(hintText: "Humidade"),controller: txtHum, keyboardType: TextInputType.number,),
          TextFormField(decoration: InputDecoration(hintText: "Gases"),controller: txtGas, keyboardType: TextInputType.number,),
          FloatingActionButton(
            onPressed: () => setState(() {
              mqttHandler.publishMessage(txtTemp.text,"av1c0ntr0lz2er0/temperatura");
              mqttHandler.publishMessage(txtHum.text,"av1c0ntr0lz2er0/humidade");
              mqttHandler.publishMessage(txtGas.text,"av1c0ntr0lz2er0/gases");
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
                Text("$value º",
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
                Text("$value %",
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
                Text("$value ppm",
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
