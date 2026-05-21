import '../domain/repositories/app_repository.dart';
import '../infrastructure/local/sqlite_service.dart';
import '../infrastructure/repositories/sqlite_app_repository.dart';

AppRepository createAppRepository() => SqliteAppRepository(SqliteService());
