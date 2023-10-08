import 'package:flutter/material.dart';
import 'slider_controller.dart';
import 'slider_decoration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Custom Slider'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SliderController(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
          },
          sliderDecoration: SliderDecoration(
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.deepPurpleAccent,
            thumbColor: Colors.deepPurple,
            borderRadius: 20.0,
            height: 50.0,
            isThumbVisible: true,
            thumbHeight: 25.0,
            thumbWidth: 5.0,
          ),
        ),
      ),
    );
  }
}
