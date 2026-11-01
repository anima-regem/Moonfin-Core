import 'package:flutter/widgets.dart';
import 'package:moonfin_design/moonfin_design.dart';

// Kept for callers with explicit text styles. Settings inherit the app theme.
const String kCleanSettingsFontFamily = AppTypography.fontFamily;

Widget withCleanSettingsTypography(BuildContext context, Widget child) => child;
