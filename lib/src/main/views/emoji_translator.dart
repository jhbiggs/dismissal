enum BusAnimals {
  snail,
  dinosaur,
  elephant,
  bear,
  eagle,
  squirrel,
  cow,
  alligator,
  kangaroo,
  none
}

extension BusAnimalsExtension on BusAnimals {
  String get emoji {
    switch (this) {
      case BusAnimals.snail:
        return '🐌';
      case BusAnimals.dinosaur:
        return '🦖';
      case BusAnimals.elephant:
        return '🐘';
      case BusAnimals.bear:
        return '🐻';
      case BusAnimals.eagle:
        return '🦅';
      case BusAnimals.squirrel:
        return '🐿️';
      case BusAnimals.cow:
        return '🐮';
      case BusAnimals.alligator:
        return '🐊';
      case BusAnimals.kangaroo:
        return '🦘';
      case BusAnimals.none:
        return '??';
      default:
        return '?';
    }
  }
}

extension ParseToString on BusAnimals {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension ParseToEnum on String {
  BusAnimals toEnum() {
    return BusAnimals.values.firstWhere(
        (e) => e.toString().split('.').last == this,
        orElse: () => BusAnimals.none);
  }
}
