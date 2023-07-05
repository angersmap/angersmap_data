enum TypeRoute {
  tram,
  week,
  night,
  sunday,
  special
}

extension TypeLineExtension on TypeRoute {
  String toStringValue() {
    switch(this) {
      case TypeRoute.tram:
        return 'tram';
      case TypeRoute.week:
        return 'week';
      case TypeRoute.night:
        return 'night';
      case TypeRoute.sunday:
        return 'sunday';
      case TypeRoute.special:
        return 'special';
      default:
        return '';
    }
  }
}