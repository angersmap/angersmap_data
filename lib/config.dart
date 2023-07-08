class Config {
  final String dbHost;
  final String dbUsername;
  final String dbName;
  final String dbPassword;

  Config(
      {required this.dbHost,
      required this.dbUsername,
      required this.dbName,
      required this.dbPassword});

  factory Config.fromJson(Map<String, dynamic> json) => Config(
      dbHost: json['DB_HOST'],
      dbUsername: json['DB_USERNAME'],
      dbName: json['DB_DBNAME'],
      dbPassword: json['DB_PASSWORD']);
}

late Config config;
