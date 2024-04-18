class DisableController {

  final Function doEnable;
  final Function doDisable;

  DisableController({
    required this.doEnable,
    required this.doDisable
  });

  void disable() => doDisable();
  void enable() => doEnable();
}