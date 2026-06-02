import '../../domain/entities/credit_card.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../datasources/remote/credit_card_remote_datasource.dart';
import '../models/credit_card_model.dart';
import '../models/invoice_model.dart';

class CreditCardRepositoryImpl implements CreditCardRepository {
  final CreditCardRemoteDatasource _datasource;
  CreditCardRepositoryImpl(this._datasource);

  @override
  Future<List<CreditCard>> getCards(String familyId) async {
    final models = await _datasource.getCards(familyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CreditCard?> getCard(String id) async {
    final m = await _datasource.getCard(id);
    return m?.toEntity();
  }

  @override
  Future<void> createCard(CreditCard card) =>
      _datasource.createCard(CreditCardModel.fromEntity(card));

  @override
  Future<void> updateCard(CreditCard card) =>
      _datasource.updateCard(CreditCardModel.fromEntity(card));

  @override
  Future<void> deleteCard(String id) => _datasource.deleteCard(id);

  @override
  Future<Invoice?> getCurrentInvoice(String cardId) async {
    final m = await _datasource.getCurrentInvoice(cardId);
    return m?.toEntity();
  }

  @override
  Future<List<Invoice>> getInvoices(String cardId) async {
    final models = await _datasource.getInvoices(cardId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<double> getTotalOpenInvoices(String familyId) =>
      _datasource.getTotalOpenInvoices(familyId);

  @override
  Future<void> payInvoice(String invoiceId, double amount) =>
      _datasource.payInvoice(invoiceId, amount);
}