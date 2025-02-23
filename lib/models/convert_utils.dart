import 'package:angersmap_data/models/route_type.dart';

class ConvertUtils {
  static int fromJsonStringToInt(String value) => int.tryParse(value) ?? 0;

  static bool fromJsonStringToBool(String value) => value == '1';

  static double fromJsonStringToDouble(String value) => double.parse(value);

  static String fromJsonStringUppercase(String value) => value.toUpperCase();

  static String? toJsonTypeRoute(RouteType? value) => value?.toStringValue();

  static String toJsonString(dynamic value) => value.toString();
}
