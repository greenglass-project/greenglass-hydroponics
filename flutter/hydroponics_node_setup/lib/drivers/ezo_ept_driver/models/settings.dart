class Settings {
  final int tickInterval;
  final int window;

  Settings(this.tickInterval, this.window);

  static Settings fromJson(Map<String,dynamic> json) =>
    Settings (json["tickInterval"] as int, json["window"] as int);

  Map<String,dynamic> toJson() => {
    "tickInterval" : tickInterval,
    "window" : window
  };
}