import '../domain/repositories/app_repository.dart';
import '../infrastructure/data_sources/in_memory_data_store.dart';
import '../infrastructure/repositories/local_app_repository.dart';
import 'use_cases/auth/login_user_use_case.dart';
import 'use_cases/auth/register_user_use_case.dart';
import 'use_cases/sale/record_sale_use_case.dart';

final AppRepository appRepository = LocalAppRepository(InMemoryDataStore());
final LoginUserUseCase loginUserUseCase = LoginUserUseCase(appRepository);
final RegisterUserUseCase registerUserUseCase = RegisterUserUseCase(appRepository);
final RecordSaleUseCase recordSaleUseCase = RecordSaleUseCase(appRepository);
