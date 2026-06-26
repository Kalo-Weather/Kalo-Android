import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConfigStatus { loading, ok, missingEnv }

final configStatusProvider = StateProvider<ConfigStatus>((ref) => ConfigStatus.loading);
