enum Flavor { dev, prod }

abstract final class FlavorConfig {
  static final Flavor current = _parse(
    const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
  );

  static Flavor _parse(String s) => switch (s) {
        'prod' => Flavor.prod,
        _ => Flavor.dev,
      };
}
