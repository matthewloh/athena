import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/home/domain/repositories/dashboard_repository.dart';

/// Use case for retrieving dashboard data
/// This is a simple use case that forwards the request to the repository
class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  /// Execute the use case to get dashboard data
  Future<DashboardData> execute() async {
    return await repository.getDashboardData();
  }
}
