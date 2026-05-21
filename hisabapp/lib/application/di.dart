import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/app_repository.dart';
import '../infrastructure/local/sqlite_service.dart';
import '../infrastructure/remote/api_client.dart';
import '../infrastructure/repositories/cached_app_repository.dart';
import 'use_cases/auth/login_user_use_case.dart';
import 'use_cases/auth/register_user_use_case.dart';
import 'use_cases/sale/record_sale_use_case.dart';

final sqliteServiceProvider = Provider((ref) => SqliteService());
final apiClientProvider = Provider((ref) => ApiClient());

final appRepositoryProvider = Provider<AppRepository>((ref) => CachedAppRepository(ref.read(sqliteServiceProvider), ref.read(apiClientProvider)));

final loginUserUseCaseProvider = Provider((ref) => LoginUserUseCase(ref.read(appRepositoryProvider)));
final registerUserUseCaseProvider = Provider((ref) => RegisterUserUseCase(ref.read(appRepositoryProvider)));
final recordSaleUseCaseProvider = Provider((ref) => RecordSaleUseCase(ref.read(appRepositoryProvider)));

// Backwards-compatible singletons for code that expects top-level instances
final AppRepository appRepository = CachedAppRepository(SqliteService(), ApiClient());
final LoginUserUseCase loginUserUseCase = LoginUserUseCase(appRepository);
final RegisterUserUseCase registerUserUseCase = RegisterUserUseCase(appRepository);
final RecordSaleUseCase recordSaleUseCase = RecordSaleUseCase(appRepository);
