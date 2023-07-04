class ConvertUtils {
  static int fromJsonStringToInt(String value) => int.tryParse(value) ?? 0;

  static double fromJsonStringToDouble(String value) => double.parse(value);
  static String fromJsonStringUppercase(String value) => value.toUpperCase();
}