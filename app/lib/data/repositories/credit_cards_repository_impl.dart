import '../datasources/credit_cards_remote_datasource.dart';
import '../models/credit_card_model.dart';
import '../models/invoice_model.dart';
import '../../core/errors/failure.dart';

class CreditCardsRepositoryImpl {
  final CreditCardsRemoteDataSource remote;
  CreditCardsRepositoryImpl(this.remote);

  Future<List<CreditCardModel>> list(String familyId) => remote.list(familyId);

  Future<CreditCardModel> create(CreditCardModel card) async {
    if (card.closingDay < 1 || card.closingDay > 31) {
      throw const ValidationFailure('Dia de fechamento invalido');
    }
    if (card.dueDay < 1 || card.dueDay > 31) {
      throw const ValidationFailure('Dia de vencimento invalido');
    }
    if (card.creditLimit <= 0) {
      throw const ValidationFailure('Limite deve ser maior que zero');
    }
    return remote.insert(card);
  }

  Future<List<InvoiceModel>> getInvoices(String creditCardId) =>
      remote.listInvoices(creditCardId);

  Future<InvoiceModel?> getCurrentInvoice(String creditCardId) =>
      remote.getCurrentInvoice(creditCardId);
}
