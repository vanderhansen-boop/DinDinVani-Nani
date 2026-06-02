/// Use Case - Calculo do Orcamento Defasado (OD)
/// REGRA OD: Renda do mes M define o orcamento do mes M+2.
/// Ex: Renda recebida em Janeiro -> orcamento de Marco.
class CalculateOrcamentoDefasadoUseCase {
  /// Retorna o mes/ano de origem da renda que define o orcamento do mes alvo.
  /// targetMonth/targetYear = mes que sera orcado.
  /// Retorna {month, year} = mes M-2 cuja renda define este orcamento.
  Map<String, int> getSourceMonth({
    required int targetMonth,
    required int targetYear,
  }) {
    int sm = targetMonth - 2;
    int sy = targetYear;
    if (sm <= 0) {
      sm += 12;
      sy -= 1;
    }
    return {'month': sm, 'year': sy};
  }

  /// Aplica regra 50/30/20:
  /// 50% essencial / 30% estilo de vida / 20% poupanca+metas
  Map<String, double> split503020(double totalIncome) {
    return {
      'essential': totalIncome * 0.50,
      'lifestyle': totalIncome * 0.30,
      'savings': totalIncome * 0.20,
    };
  }
}
