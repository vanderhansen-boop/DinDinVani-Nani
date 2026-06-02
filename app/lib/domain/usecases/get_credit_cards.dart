import '../entities/credit_card.dart';
import '../entities/invoice.dart';
import '../repositories/credit_card_repository.dart';

class GetCreditCards {
  final CreditCardRepository repository;
  GetCreditCards(this.repository);

  Future<List<CreditCard>> call(String familyId) =>
      repository.getCards(familyId);
}

class GetCardInvoice {
  final CreditCardRepository repository;
  GetCardInvoice(this.repository);

  Future<Invoice?> call(String cardId) =>
      repository.getCurrentInvoice(cardId);
}

class GetInvoiceHistory {
  final CreditCardRepository repository;
  GetInvoiceHistory(this.repository);

  Future<List<Invoice>> call(String cardId, {int limit = 6}) =>
      repository.getInvoiceHistory(cardId, limit: limit);
}