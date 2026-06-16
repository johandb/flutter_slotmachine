import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slotmachine/services/sound_service.dart';
import 'package:flutter_slotmachine/slot_controller.dart';
import 'package:flutter_slotmachine/slot_screen.dart';

void main() {
  runApp(const SlotMachine());
}

class SlotMachine extends StatelessWidget {
  const SlotMachine({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casino Slotmachine',
      debugShowCheckedModeBanner: false,
      home: const SlotMachinePage(title: 'Slot Machine'),
    );
  }
}

class SlotMachinePage extends StatefulWidget {
  const SlotMachinePage({super.key, required this.title});

  final String title;

  @override
  State<SlotMachinePage> createState() => _SlotMachinePageState();
}

class _SlotMachinePageState extends State<SlotMachinePage> {
  int _score = 50;
  int _win = 2;

  final List<String> _wheelItems = [
    "7",
    "bar",
    "bell",
    "cherries",
    "diamond",
    "grape",
    "melon",
    "orange",
  ];

  late SlotMachineController _controller;

  void onStart() {
    late Timer timer1;
    late Timer timer2;
    late Timer timer3;

    print("onStart ...");

    SoundService.instance.playSound("spin.mp3");

    setState(() {
      _score -= _win;
    });
    int wheel1Timer = 1000 + Random().nextInt(1000);
    int wheel2Timer = wheel1Timer + Random().nextInt(1000);
    int wheel3Timer = wheel2Timer + Random().nextInt(1000);
    _controller.start();
    print("run 1 for $wheel1Timer");
    timer1 = Timer(Duration(milliseconds: wheel1Timer), () {
      _stopWheel(timer1, 0);
    });
    print("run 2 for $wheel2Timer");
    timer2 = Timer(Duration(milliseconds: wheel2Timer), () {
      _stopWheel(timer2, 1);
    });
    print("run 3 for $wheel3Timer");
    timer3 = Timer(Duration(milliseconds: wheel3Timer), () {
      _stopWheel(timer3, 2);
    });
  }

  void _stopWheel(Timer timer, int wheelId) {
    print("stopWheel $wheelId");
    _controller.stop(wheelId: wheelId);
    timer.cancel();
  }

  void _updateScore(List<String> results) {
    int tempScore = 0;
    if (results.length != 3) {
      return;
    }
    if (results[0] == 'cherries') {
      tempScore = 2;
    }
    if (results[0] == results[1]) {
      if (results[0] == 'cherries') {
        tempScore = 4;
      } else if (results[0] == 'diamond') {
        tempScore = 6;
      } else if (results[0] == 'bell') {
        tempScore = 8;
      } else if (results[0] == '7') {
        tempScore = 12;
      }
    }
    if (results[0] == results[1] && results[0] == results[2]) {
      if (results[0] == 'cherries') {
        tempScore = 8;
      } else if (results[0] == 'diamond' || results[0] == 'orange') {
        tempScore = 16;
      } else if (results[0] == 'bell') {
        tempScore = 24;
      } else if (results[0] == '7') {
        tempScore = 50;
      } else if (results[0] == 'melon') {
        tempScore = 18;
      } else if (results[0] == 'bar') {
        tempScore = 100;
      } else if (results[0] == 'grape' || results[0] == 'citron') {
        tempScore = 20;
      }
    }
    if (tempScore > 0) {
      SoundService.instance.playSound("win.mp3");
      print("win ${(tempScore * (_win / 2)).toInt()}");
      setState(() {
        _score += (tempScore * (_win / 2)).toInt();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: DecoratedBox(
        // BoxDecoration takes the image
        decoration: BoxDecoration(
          // Image set to background of the body
          image: DecorationImage(image: AssetImage("images/casino.png"), fit: BoxFit.cover),
        ),
        child: Center(
          // flutter logo that will shown
          // above the background image
          child: Column(
            mainAxisAlignment: .start,
            children: [
              SizedBox(height: 25),
              Text(
                'Credits : $_score',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        _win = 2;
                      }),
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Color(0x80000000),
                    ),
                    child: Text(
                      '€ 2',
                      style: TextStyle(
                        fontSize: 20,
                        color: _win == 2 ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        _win = 5;
                      }),
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Color(0x80000000),
                    ),
                    child: Text(
                      '€ 5',
                      style: TextStyle(
                        fontSize: 20,
                        color: _win == 5 ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        _win = 10;
                      }),
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(12),
                      backgroundColor: Color(0x80000000),
                    ),
                    child: Text(
                      '€ 10',
                      style: TextStyle(
                        fontSize: 20,
                        color: _win == 10 ? Colors.yellow : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SlotMachineScreen(
                wheelItems: _wheelItems,
                onCreated: (controller) {
                  print("onCreated");
                  _controller = controller;
                },
                onFinished: (results) {
                  print('onFinished : Result: $results');
                  _updateScore(results);
                },
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: .center,
                children: [
                  ElevatedButton(
                    onPressed: () => (_score - _win) < 0 ? {} : onStart(),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                      backgroundColor: Color(0x80000000),
                    ),
                    child: Text('Spin', style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _score += 50;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24),
                      backgroundColor: Color(0x80000000),
                    ),
                    child: Text('Buy €', style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
