import 'package:flutter/foundation.dart';

class AppRefreshService {
  static final ValueNotifier<int> refreshTick = ValueNotifier<int>(0);

  static void refreshAll() {
    refreshTick.value++;
  }
}