import '../../../domain/entities/sale.dart';
import '../../../domain/repositories/app_repository.dart';

class RecordSaleUseCase {
  final AppRepository repository;

  RecordSaleUseCase(this.repository);

  Future<void> execute(Sale sale) {
    return repository.recordSale(sale);
  }
}
