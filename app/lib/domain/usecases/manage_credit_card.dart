import '../entities/credit_card.dart';
import '../repositories/credit_card_repository.dart';

class ManageCreditCard {
  final CreditCardRepository repository;
  ManageCreditCard(this.repository);

  Future<void> create(CreditCard card) => repository.createCard(card);
  Future<void> update(CreditCard card) => repository.updateCard(card);
  Future<void> delete(String id)       => repository.deleteCard(id);
  Future<void> payInvoice(String invoiceId, double amount) =>
      repository.payInvoice(invoiceId, amount);
}
