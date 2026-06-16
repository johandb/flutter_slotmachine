class SlotMachineController {
  const SlotMachineController({required this.start, required this.stop});

  final Function() start;
  final Function({required int wheelId}) stop;
}
