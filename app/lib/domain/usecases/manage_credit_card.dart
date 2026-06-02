import '../entities/credit_card.dart';
import '../entities/invoice.dart';
import '../repositories/credit_card_repository.dart';

class ManageCreditCard {
  final CreditCardRepository repository;
  ManageCreditCard(this.repository);

  Future<CreditCard> create(CreditCard card) => repository.createCard(card);
  Future<CreditCard> update(CreditCard card) => repository.updateCard(card);
  Future<void>       delete(String id)       => repository.deleteCard(id);
  Future<Invoice>    payInvoice(String invoiceId, double amount) =>
      repository.payInvoice(invoiceId, amount);
}