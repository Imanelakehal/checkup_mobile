enum Flavor { dev, prod }

class AppConfig {
  final Flavor flavor;
  final String appName;

  const AppConfig({required this.flavor, required this.appName});

  static AppConfig? _instance;

  static AppConfig get instance {
    if (_instance == null) throw Exception("AppConfig not initialized");
    return _instance!;
  }

  static void initialize(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        _instance = const AppConfig(flavor: Flavor.dev, appName: 'MedFinder Dev');
        break;
      case Flavor.prod:
        _instance = const AppConfig(flavor: Flavor.prod, appName: 'MedFinder');
        break;
    }
  }
}
