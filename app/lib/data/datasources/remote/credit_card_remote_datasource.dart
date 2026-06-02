import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/credit_card_model.dart';
import '../../models/invoice_model.dart';

abstract class CreditCardRemoteDatasource {
  Future<List<CreditCardModel>> getCards(String familyId);
  Future<CreditCardModel?>      getCard(String id);
  Future<void>                  createCard(CreditCardModel card);
  Future<void>                  updateCard(CreditCardModel card);
  Future<void>                  deleteCard(String id);
  Future<InvoiceModel?>         getCurrentInvoice(String cardId);
  Future<List<InvoiceModel>>    getInvoices(String cardId);
  Future<double>                getTotalOpenInvoices(String familyId);
  Future<void>                  payInvoice(String invoiceId, double amount);
}

class CreditCardRemoteDatasourceImpl implements CreditCardRemoteDatasource {
  final SupabaseClient _client;
  CreditCardRemoteDatasourceImpl(this._client);

  @override
  Future<List<CreditCardModel>> getCards(String familyId) async {
    final res = await _client
        .from('credit_cards')
        .select()
        .eq('family_id', familyId)
        .eq('is_active', true)
        .order('name');
    return (res as List).map((j) => CreditCardModel.fromJson(j)).toList();
  }

  @override
  Future<CreditCardModel?> getCard(String id) async {
    final res = await _client.from('credit_cards').select().eq('id', id).maybeSingle();
    return res != null ? CreditCardModel.fromJson(res) : null;
  }

  @override
  Future<void> createCard(CreditCardModel card) async {
    await _client.from('credit_cards').insert(card.toJson());
  }

  @override
  Future<void> updateCard(CreditCardModel card) async {
    await _client.from('credit_cards').update(card.toJson()).eq('id', card.id);
  }

  @override
  Future<void> deleteCard(String id) async {
    await _client.from('credit_cards').update({'is_active': false}).eq('id', id);
  }

  @override
  Future<InvoiceModel?> getCurrentInvoice(String cardId) async {
    final now = DateTime.now();
    final res = await _client
        .from('invoices')
        .select()
        .eq('credit_card_id', cardId)
        .eq('month', now.month)
        .eq('year', now.year)
        .maybeSingle();
    return res != null ? InvoiceModel.fromJson(res) : null;
  }

  @override
  Future<List<InvoiceModel>> getInvoices(String cardId) async {
    final res = await _client
        .from('invoices')
        .select()
        .eq('credit_card_id', cardId)
        .order('year', ascending: false)
        .order('month', ascending: false);
    return (res as List).map((j) => InvoiceModel.fromJson(j)).toList();
  }

  @override
  Future<double> getTotalOpenInvoices(String familyId) async {
    final res = await _client
        .from('invoices')
        .select('total_amount, reserved_amount, credit_cards!inner(family_id)')
        .eq('credit_cards.family_id', familyId)
        .eq('status', 'open');
    double total = 0;
    for (final row in (res as List)) {
      final t = (row['total_amount'] as num).toDouble();
      final r = (row['reserved_amount'] as num? ?? 0).toDouble();
      total += (t - r).clamp(0, double.infinity);
    }
    return total;
  }

  @override
  Future<void> payInvoice(String invoiceId, double amount) async {
    await _client.from('invoices').update({
      'status': 'paid',
      'reserved_amount': amount,
    }).eq('id', invoiceId);
  }
}