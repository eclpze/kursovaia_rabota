import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Стили
final OnboardingTopStyle = GoogleFonts.nunitoSans(
  color: const Color(0xff1A1D26),
  fontSize: 18,
  fontWeight: FontWeight.w900,
);

final OnboardingBotStyle = GoogleFonts.nunitoSans(
  color: const Color(0xff4A4E4D),
  fontSize: 16,
  fontWeight: FontWeight.normal,
);

final ButtonTextStyle = GoogleFonts.nunitoSans(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final AuthorizationTopStyle = GoogleFonts.nunitoSans(
  color: Colors.black,
  fontSize: 28,
  fontWeight: FontWeight.w900,
  height: 1.2,
);

final AuthorizationBotStyle = GoogleFonts.nunitoSans(
  color: const Color(0xff4A4E4D),
  fontSize: 18,
  fontWeight: FontWeight.w500,
  height: 1.2,
);

final TextEditStyle = GoogleFonts.nunitoSans(
  color: const Color(0xff474747),
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

final TopEditStyle = GoogleFonts.nunitoSans(
  color: Colors.black,
  fontWeight: FontWeight.w700,
  fontSize: 18,
);

// Контроллеры
final SmoothController = PageController();
final EmailController = TextEditingController();
final PasswordController = TextEditingController();
final NameController = TextEditingController();

// Инициализация Supabase
final supabase = Supabase.instance.client;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://dzqvgirkmftcrtlfolee.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6cXZnaXJrbWZ0Y3J0bGZvbGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAxMzgwMDMsImV4cCI6MjA1NTcxNDAwM30.GIiPuXo_GVX37kEtGmxNg4lKRImKh9a1XKThn2uQV1k',
    );
  }
}
