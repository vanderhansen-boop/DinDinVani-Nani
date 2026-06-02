import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/credit_card_model.dart';
import '../models/invoice_model.dart';

class CreditCardsRemoteDataSource {
  final SupabaseClient _c = SupabaseService.client;

  Future<List<CreditCardModel>> list(String familyId) async {
    try {
      final data = await _c.from('credit_cards').select().eq('family_id', familyId);
      return (data as List)
          .map((e) => CreditCardModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<CreditCardModel> insert(CreditCardModel card) async {
    final data = await _c.from('credit_cards').insert(card.toJson()).select().single();
    return CreditCardModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<InvoiceModel>> listInvoices(String creditCardId) async {
    final data = await _c
        .from('invoices')
        .select()
        .eq('credit_card_id', creditCardId)
        .order('reference_year', ascending: false)
        .order('reference_month', ascending: false);
    return (data as List)
        .map((e) => InvoiceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<InvoiceModel?> getCurrentInvoice(String creditCardId) async {
    final now = DateTime.now();
    final data = await _c
        .from('invoices')
        .select()
        .eq('credit_card_id', creditCardId)
        .eq('reference_month', now.month)
        .eq('reference_year', now.year)
        .maybeSingle();
    if (data == null) return null;
    return InvoiceModel.fromJson(Map<String, dynamic>.from(data));
  }
}
