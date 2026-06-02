import 'package:dindinvani_nani/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/datasources/remote/piggy_bank_remote_datasource.dart';
import '../../../../data/repositories/piggy_bank_repository_impl.dart';
import '../../../../domain/entities/piggy_bank.dart';
import '../../../../domain/entities/piggy_bank_contribution.dart';
import '../../../../domain/usecases/get_piggy_banks.dart';
import '../../../../domain/usecases/save_piggy_bank.dart';
import '../../../../domain/usecases/operate_piggy_bank.dart';
import '../../../../presentation/features/dashboard/providers/dashboard_providers.dart';

// Infra
final piggyBankDatasourceProvider = Provider<PiggyBankRemoteDatasource>((ref) =>
    PiggyBankRemoteDatasourceImpl(Supabase.instance.client));

final piggyBankRepositoryProvider = Provider((ref) =>
    PiggyBankRepositoryImpl(ref.watch(piggyBankDatasourceProvider)));

// Use cases
final getPiggyBanksProvider    = Provider((ref) => GetPiggyBanks(ref.watch(piggyBankRepositoryProvider)));
final savePiggyBankProvider    = Provider((ref) => SavePiggyBank(ref.watch(piggyBankRepositoryProvider)));
final operatePiggyBankProvider = Provider((ref) => OperatePiggyBank(ref.watch(piggyBankRepositoryProvider)));

// Lista de caixinhas
final piggyBankListProvider = FutureProvider.autoDispose<List<PiggyBank>>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  return ref.watch(getPiggyBanksProvider).call(familyId);
});

// Historico de uma caixinha especifica
final piggyBankHistoryProvider = FutureProvider.autoDispose
    .family<List<PiggyBankContribution>, String>((ref, piggyBankId) async {
  return ref.watch(operatePiggyBankProvider).getHistory(piggyBankId);
});

// Totais por tipo
final piggyBankTotalsProvider = Provider.autoDispose<Map<PiggyBankType, double>>((ref) {
  final async = ref.watch(piggyBankListProvider);
  return async.when(
    data: (list) {
      final map = <PiggyBankType, double>{};
      for (final p in list) {
        map[p.type] = (map[p.type] ?? 0) + p.currentBalance;
      }
      return map;
    },
    loading: () => {},
    error:   (_, __) => {},
  );
});

// Saldo total guardado em caixinhas
final piggyBankTotalBalanceProvider = Provider.autoDispose<double>((ref) {
  final async = ref.watch(piggyBankListProvider);
  return async.when(
    data: (list) => list.fold(0.0, (sum, p) => sum + p.currentBalance),
    loading: () => 0.0,
    error:   (_, __) => 0.0,
  );
});