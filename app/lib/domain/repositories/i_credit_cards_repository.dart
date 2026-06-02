import '../entities/credit_card.dart';
import '../entities/invoice.dart';

abstract class ICreditCardsRepository {
  Future<List<CreditCard>> list(String familyId);
  Future<CreditCard> create(CreditCard card);
  Future<List<Invoice>> listInvoices(String creditCardId);
  Future<Invoice?> getCurrentInvoice(String creditCardId);
}
