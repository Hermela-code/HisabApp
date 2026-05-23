import '../domain/repositories/app_repository.dart';
import '../infrastructure/data_sources/in_memory_data_store.dart';
import '../infrastructure/repositories/local_app_repository.dart';

AppRepository createAppRepository() => LocalAppRepository(InMemoryDataStore());
