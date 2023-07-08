enum RouteType { tram, day, night, special }

extension TypeLineExtension on RouteType {
  String toStringValue() {
    switch (this) {
      case RouteType.tram:
        return 'tram';
      case RouteType.day:
        return 'day';
      case RouteType.night:
        return 'night';
      case RouteType.special:
        return 'special';
      default:
        return '';
    }
  }
}

RouteType stringToTypeRoute(String? typeRoute) {
  switch (typeRoute) {
    case 'tram':
      return RouteType.tram;
    case 'day':
      return RouteType.day;
    case 'night':
      return RouteType.night;
    case 'special':
      return RouteType.special;
    default:
      return RouteType.day;
  }
}
