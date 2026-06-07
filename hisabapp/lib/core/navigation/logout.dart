import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/cashier_data_provider.dart';
import '../../application/providers/session_provider.dart';
import 'app_router.dart';

void performLogout(BuildContext context, WidgetRef ref) {
  ref.read(sessionProvider.notifier).clearUser();
  ref.read(cashierDataProvider.notifier).reset();
  context.go(AppRouter.signup);
}
