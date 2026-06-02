class ApiConstants {
  ApiConstants._();

  // Edge Functions
  static const String fnGenerateBudget   = 'generate_monthly_budget';
  static const String fnPayCpiInstall    = 'pay_cpi_installment';
  static const String fnPayInvoice       = 'pay_invoice_on_due_date';
  static const String fnRecalculateScore = 'recalculate_score';

  // Tabelas
  static const String tFamilies     = 'families';
  static const String tUsers        = 'users';
  static const String tAccounts     = 'accounts';
  static const String tCreditCards  = 'credit_cards';
  static const String tInvoices     = 'invoices';
  static const String tTransactions = 'transactions';
  static const String tPiggyBanks   = 'piggy_banks';
  static const String tBudgets      = 'budgets';
  static const String tGoals        = 'family_goals';
  static const String tCategories   = 'categories';
}
