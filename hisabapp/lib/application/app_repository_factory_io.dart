import 'package:http/http.dart' as http;

import '../domain/repositories/app_repository.dart';
import '../infrastructure/local/sqlite_service.dart';
import '../infrastructure/repositories/cache_first_app_repository.dart';
import '../infrastructure/repositories/remote_app_repository.dart';
import '../infrastructure/repositories/sqlite_app_repository.dart';

AppRepository createAppRepository() => CacheFirstAppRepository(
      localRepository: SqliteAppRepository(SqliteService()),
      remoteRepository: RemoteAppRepository(client: http.Client()),
    );
