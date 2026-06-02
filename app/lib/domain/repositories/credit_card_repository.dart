import '../entities/credit_card.dart';
import '../entities/invoice.dart';

abstract class CreditCardRepository {
  Future<List<CreditCard>> getCards(String familyId);
  Future<CreditCard?>      getCard(String id);
  Future<void>             createCard(CreditCard card);
  Future<void>             updateCard(CreditCard card);
  Future<void>             deleteCard(String id);
  Future<Invoice?>         getCurrentInvoice(String cardId);
  Future<List<Invoice>>    getInvoices(String cardId);
  Future<double>           getTotalOpenInvoices(String familyId);
  Future<void>             payInvoice(String invoiceId, double amount);
}