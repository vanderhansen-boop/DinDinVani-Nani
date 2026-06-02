import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/report_filter.dart';

class ReportRemoteDataSource {
  final SupabaseClient _client;

  ReportRemoteDataSource(this._client);

  Future<List<Map<String, dynamic>>> getTransactions({
    required String familyId,
    required ReportFilter filter,
  }) async {
    // Monta filtro base como PostgrestFilterBuilder
    // IMPORTANTE: .order() converte para PostgrestTransformBuilder
    // por isso todos os .eq() / .filter() devem vir ANTES do .order()
    var query = _client
        .from('transactions')
        .select('*, categories(name, emoji)')
        .eq('family_id', familyId)
        .gte('date', filter.resolvedStart.toIso8601String())
        .lte('date', filter.resolvedEnd.toIso8601String());

    // Filtros opcionais — ainda no PostgrestFilterBuilder
    if (filter.categoryIds.isNotEmpty) {
      // Formato esperado pelo Supabase: (id1,id2,id3)
      final ids = filter.categoryIds.join(',');
      query = query.filter('category_id', 'in', '($ids)');
    }

    if (filter.userId != null) {
      query = query.eq('user_id', filter.userId!);
    }

    // .order() por ultimo — converte para PostgrestTransformBuilder
    final data = await query.order('date', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSummary({
    required String familyId,
    required ReportFilter filter,
  }) async {
    final transactions = await getTransactions(
      familyId: familyId,
      filter: filter,
    );

    double totalIncome  = 0;
    double totalExpense = 0;

    for (final t in transactions) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
      final type   = t['type'] as String? ?? '';
      if (type == 'income') {
        totalIncome += amount;
      } else if (type == 'expense') {
        totalExpense += amount;
      }
    }

    return {
      'total_income':  totalIncome,
      'total_expense': totalExpense,
      'balance':       totalIncome - totalExpense,
      'count':         transactions.length,
    };
  }

  Future<List<Map<String, dynamic>>> getByCategory({
    required String familyId,
    required ReportFilter filter,
  }) async {
    final transactions = await getTransactions(
      familyId: familyId,
      filter: filter,
    );

    // Agrupa por categoria
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final t in transactions) {
      final catId   = t['category_id'] as String? ?? 'sem_categoria';
      final catData = t['categories'] as Map<String, dynamic>?;
      final catName = catData?['name']  as String? ?? 'Sem Categoria';
      final catEmoji= catData?['emoji'] as String? ?? '';
      final amount  = (t['amount'] as num?)?.toDouble() ?? 0.0;
      final type    = t['type']   as String? ?? '';

      if (!grouped.containsKey(catId)) {
        grouped[catId] = {
          'category_id':   catId,
          'category_name': catName,
          'category_emoji':catEmoji,
          'total_income':  0.0,
          'total_expense': 0.0,
          'count':         0,
        };
      }

      if (type == 'income') {
        grouped[catId]!['total_income'] =
            (grouped[catId]!['total_income'] as double) + amount;
      } else if (type == 'expense') {
        grouped[catId]!['total_expense'] =
            (grouped[catId]!['total_expense'] as double) + amount;
      }
      grouped[catId]!['count'] = (grouped[catId]!['count'] as int) + 1;
    }

    final result = grouped.values.toList();
    result.sort((a, b) =>
        (b['total_expense'] as double).compareTo(a['total_expense'] as double));
    return result;
  }
}