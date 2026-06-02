import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../data/datasources/remote/credit_card_remote_datasource.dart';
import '../../../../data/repositories/credit_card_repository_impl.dart';
import '../../../../domain/entities/credit_card.dart';
import '../../../../domain/entities/invoice.dart';
import '../../../../domain/entities/invoice_reserve.dart';
import '../../../../domain/repositories/credit_card_repository.dart';

// ── Datasource ───────────────────────────────────────────────
final creditCardDatasourceProvider = Provider<CreditCardRemoteDatasource>((ref) {
  return CreditCardRemoteDatasourceImpl(ref.watch(supabaseClientProvider));
});

// ── Repository ───────────────────────────────────────────────
final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  return CreditCardRepositoryImpl(ref.watch(creditCardDatasourceProvider));
});

// ── Lista de cartões ─────────────────────────────────────────
final creditCardsProvider = FutureProvider<List<CreditCard>>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId.isEmpty) return [];
  return ref.watch(creditCardRepositoryProvider).getCards(familyId);
});

// ── Fatura atual por cartão ──────────────────────────────────
final currentInvoiceProvider =
    FutureProvider.family<Invoice?, String>((ref, cardId) async {
  return ref.watch(creditCardRepositoryProvider).getCurrentInvoice(cardId);
});

// ── Histórico de faturas por cartão ─────────────────────────
final invoiceHistoryProvider =
    FutureProvider.family<List<Invoice>, String>((ref, cardId) async {
  return ref.watch(creditCardRepositoryProvider).getInvoices(cardId);
});

// ── Reservas de uma fatura ───────────────────────────────────
final invoiceReservesProvider =
    FutureProvider.family<List<InvoiceReserve>, String>((ref, invoiceId) async {
  final client = ref.watch(supabaseClientProvider);
  final res = await client
      .from('invoice_reserves')
      .select()
      .eq('invoice_id', invoiceId)
      .order('created_at', ascending: false);
  return (res as List)
      .map((m) => InvoiceReserve.fromMap(m as Map<String, dynamic>))
      .toList();
});

// ── Total de faturas abertas ─────────────────────────────────
final totalOpenInvoicesProvider = FutureProvider<double>((ref) async {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId.isEmpty) return 0;
  return ref.watch(creditCardRepositoryProvider).getTotalOpenInvoices(familyId);
});

// ── Saldo da Caixinha de Fatura (CF) de um piggyBank ────────
final cfBalanceProvider =
    FutureProvider.family<double, String>((ref, piggyBankId) async {
  if (piggyBankId.isEmpty) return 0;
  final client = ref.watch(supabaseClientProvider);
  final res = await client
      .from('piggy_banks')
      .select('balance')
      .eq('id', piggyBankId)
      .maybeSingle();
  if (res == null) return 0;
  return (res['balance'] as num? ?? 0).toDouble();
});

// ── Gerenciador de cartão ────────────────────────────────────
final manageCreditCardProvider = Provider<ManageCreditCardService>((ref) {
  return ManageCreditCardService(ref.watch(creditCardRepositoryProvider), ref);
});

class ManageCreditCardService {
  final CreditCardRepository _repo;
  final Ref _ref;
  ManageCreditCardService(this._repo, this._ref);

  Future<void> create(CreditCard card)              => _repo.createCard(card);
  Future<void> update(CreditCard card)              => _repo.updateCard(card);
  Future<void> delete(String id)                    => _repo.deleteCard(id);
  Future<void> payInvoice(String invoiceId, double amount) =>
      _repo.payInvoice(invoiceId, amount);
}