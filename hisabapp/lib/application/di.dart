import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/app_repository.dart';
import 'app_repository_factory.dart';
import 'use_cases/auth/login_user_use_case.dart';
import 'use_cases/auth/register_user_use_case.dart';
import 'use_cases/sale/record_sale_use_case.dart';

final appRepositoryProvider = Provider<AppRepository>((ref) => createAppRepository());

final loginUserUseCaseProvider = Provider((ref) => LoginUserUseCase(ref.read(appRepositoryProvider)));
final registerUserUseCaseProvider = Provider((ref) => RegisterUserUseCase(ref.read(appRepositoryProvider)));
final recordSaleUseCaseProvider = Provider((ref) => RecordSaleUseCase(ref.read(appRepositoryProvider)));

// Backwards-compatible singleton for code that expects a top-level instance
final AppRepository appRepository = createAppRepository();
final LoginUserUseCase loginUserUseCase = LoginUserUseCase(appRepository);
final RegisterUserUseCase registerUserUseCase = RegisterUserUseCase(appRepository);
final RecordSaleUseCase recordSaleUseCase = RecordSaleUseCase(appRepository);
