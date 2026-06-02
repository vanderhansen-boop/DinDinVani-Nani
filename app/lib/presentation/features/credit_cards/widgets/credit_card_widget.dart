import 'package:flutter/material.dart';
import '../../../../domain/entities/credit_card.dart';
import '../../../../domain/entities/invoice.dart';
import '../../../../core/extensions/currency_extension.dart';

/// Card visual estilo cartao de credito real
class CreditCardWidget extends StatelessWidget {
  final CreditCard card;
  final Invoice?   invoice;
  final VoidCallback? onTap;

  const CreditCardWidget({
    super.key,
    required this.card,
    this.invoice,
    this.onTap,
  });

  Color get _cardColor {
    try {
      final hex = card.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverage = invoice?.coveragePercent ?? 1.0;
    final isOk     = coverage >= 0.99 || invoice == null;
    final isWarn   = coverage >= 0.7 && coverage < 0.99;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [_cardColor, _cardColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _cardColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Circulos decorativos
            Positioned(top: -30, right: -30,
              child: Container(width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08)))),
            Positioned(bottom: -20, left: -20,
              child: Container(width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06)))),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha topo: emoji + nome + bandeira
                  Row(
                    children: [
                      Text(card.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(card.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                      Text(card.brandLabel,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Numero mascarado
                  Text('•••• •••• •••• ${card.lastFourDigits}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          letterSpacing: 2)),

                  const Spacer(),

                  // Fatura + CF status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fatura atual',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10)),
                          Text(
                            invoice != null
                                ? invoice!.totalAmount.toBRL
                                : 'R\$ 0,00',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Cobertura CF',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOk
                                  ? Colors.green.withOpacity(0.85)
                                  : isWarn
                                      ? Colors.orange.withOpacity(0.85)
                                      : Colors.red.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              invoice != null
                                  ? '${(coverage * 100).toStringAsFixed(0)}%'
                                  : '—',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Barra de cobertura
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: coverage.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOk ? Colors.greenAccent
                               : isWarn ? Colors.orangeAccent
                                        : Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}