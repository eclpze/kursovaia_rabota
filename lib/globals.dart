import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Стили
var OnboardingTopStyle = GoogleFonts.nunitoSans(
  color: Color(0xff1A1D26),
  fontSize: 18,
  fontWeight: FontWeight.w900,
);
var OnboardingBotStyle = GoogleFonts.nunitoSans(
  color: Color(0xff4A4E4D),
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
var ButtonTextStyle = GoogleFonts.nunitoSans(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);
var AuthorizationTopStyle = GoogleFonts.nunitoSans(
  color: Colors.black,
  fontSize: 28,
  fontWeight: FontWeight.w900,
  height: 1.2,
);
var AuthorizationBotStyle = GoogleFonts.nunitoSans(
  color: Color(0xff4A4E4D),
  fontSize: 18,
  fontWeight: FontWeight.w500,
  height: 1.2,
);
var TextEditStyle = GoogleFonts.nunitoSans(
  color: Color(0xff474747),
  fontWeight: FontWeight.bold,
  fontSize: 16,
);
var TopEditStyle = GoogleFonts.nunitoSans(
  color: Colors.black,
  fontWeight: FontWeight.w700,
  fontSize: 18,
);

// Контроллеры
var SmoothController = PageController();
final EmailController = TextEditingController();
final PasswordController = TextEditingController();
final NameController = TextEditingController();


final supabase = Supabase.instance.client;

class SupabaseManager {
  static final SupabaseManager _instance = SupabaseManager._internal();
  late final SupabaseClient client;

  factory SupabaseManager() {
    return _instance;
  }

  SupabaseManager._internal() {
    client = SupabaseClient(
      'https://dzqvgirkmftcrtlfolee.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cXZnaXJrbWZ0Y3J0bGZvbGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMzgwMDMsImV4cCI6MjA1NTcxNDAwM30.GIiPuXo_GVX37kEtGmxNg4lKRImKh9a1XKThn2uQV1k',
    );
  }
}

