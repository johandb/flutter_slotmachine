import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slotmachine/slot_controller.dart';

class SlotMachineScreen extends StatefulWidget {
  final Function(SlotMachineController) onCreated;
  final Function(List<String> result) onFinished;

  final List<String> wheelItems;

  const SlotMachineScreen({
    super.key,
    required this.wheelItems,
    required this.onCreated,
    required this.onFinished,
  });

  @override
  State<SlotMachineScreen> createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends State<SlotMachineScreen> {
  final Map<int, WheelController> _wheelControllers = {};
  late SlotMachineController _slotMachineController;
  List<WheelItem> wheelItems = [];
  List<String> _results = ["", "", ""];
  int _stoppedWheels = 0;

  @override
  void initState() {
    super.initState();
    _slotMachineController = SlotMachineController(start: _start, stop: _stop);
    widget.onCreated(_slotMachineController);

    wheelItems = widget.wheelItems.map<WheelItem>((item) {
      return WheelItem(
        name: item,
        image: SizedBox(width: 100, height: 100, child: Image.asset('images/$item.png')),
      );
    }).toList();
  }

  void _start() {
    _results = ["", "", ""];
    _stoppedWheels = 0;
    _wheelControllers.forEach((key, _) => _wheelControllers[key]!.start());
  }

  void _stop({required int wheelId}) {
    final wc = _wheelControllers[wheelId];
    if (wc == null) {
      return;
    }
    wc.stop(wheelId: wheelId);
    _stoppedWheels++;
  }

  void _onResult({required int wheelId, required String name}) {
    _results[wheelId] = name;
    if (_stoppedWheels == 2) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onFinished(_results);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          children: [
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Wheel(
                    wheelItems: [...wheelItems..shuffle()],
                    onCreated: (wc) => _wheelControllers[0] = wc,
                    onResult: (w, r) => _onResult(wheelId: w, name: r),
                    wheelId: 0,
                    fraction: -0.4,
                  ),
                  Wheel(
                    wheelItems: [...wheelItems..shuffle()],
                    onCreated: (wc) => _wheelControllers[1] = wc,
                    onResult: (w, r) => _onResult(wheelId: w, name: r),
                    wheelId: 1,
                    fraction: 0.0,
                  ),
                  Wheel(
                    wheelItems: [...wheelItems..shuffle()],
                    onCreated: (wc) => _wheelControllers[2] = wc,
                    onResult: (w, r) => _onResult(wheelId: w, name: r),
                    wheelId: 2,
                    fraction: 0.6,
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 90),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Opacity(opacity: 0.7, child: Divider(thickness: 2, color: Colors.red)),
          ),
        ),
      ],
    );
  }
}

class WheelItem {
  final String name;
  final Widget image;

  WheelItem({required this.name, required this.image});
}

class WheelController {
  final Function start;
  final Function({required int wheelId}) stop;

  const WheelController({required this.start, required this.stop});
}

class Wheel extends StatefulWidget {
  final int wheelId;
  final double fraction;
  final List<WheelItem> wheelItems;
  final Function(WheelController) onCreated;
  final Function(int, String) onResult;

  const Wheel({
    super.key,
    required this.wheelItems,
    required this.fraction,
    required this.onCreated,
    required this.wheelId,
    required this.onResult,
  });

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  int counter = 0;
  int result = -1;
  late Timer timer;
  List<WheelItem> _items = [];
  late WheelController _wheelController;
  final _scrollController = FixedExtentScrollController(initialItem: 0);

  @override
  void initState() {
    super.initState();
    _items = widget.wheelItems;

    _wheelController = WheelController(start: _start, stop: _stop);
    widget.onCreated(_wheelController);
  }

  void _start() {
    counter = 7;
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      _scrollController.animateToItem(
        counter,
        duration: Duration(milliseconds: 50),
        curve: Curves.linear,
      );
      counter--;
      if (counter < 0) {
        counter = 7;
      }
    });
  }

  void _stop({required int wheelId}) {
    timer.cancel();
    int selectedItem = _scrollController.selectedItem;

    final mod = (-counter) % _items.length - 1;
    final delta = (_items.length - mod) + (_items.length - selectedItem) - 1;
    result = selectedItem.abs() % 8;
    final name = _items[result].name;
    _scrollController.animateToItem(
      counter - delta,
      duration: const Duration(milliseconds: 750),
      curve: Curves.decelerate,
    );
    widget.onResult(wheelId, name);
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      //height: 200,
      //width: 100,
      flex: 1,
      child: ListWheelScrollView.useDelegate(
        controller: _scrollController,
        itemExtent: 75,
        offAxisFraction: widget.fraction,
        physics: FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildLoopingListDelegate(
          children: _items.map<Widget>((item) {
            return SizedBox(
              width: 100,
              height: 100,
              child: Container(color: Color(0xe0ffffff), child: item.image),
            );
          }).toList(),
        ),
      ),
    );
  }
}
