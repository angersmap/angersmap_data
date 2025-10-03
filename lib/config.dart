class Config {
  final String supabaseUrl;
  final String supabaseKey;
  final String supabaseAnonKey;

  Config(
      {required this.supabaseUrl,
      required this.supabaseKey,
      required this.supabaseAnonKey});

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        supabaseUrl: json['SUPABASE_URL'],
        supabaseKey: json['SUPABASE_KEY'],
        supabaseAnonKey: json['SUPABASE_ANON_KEY'],
      );
}

late Config config;
