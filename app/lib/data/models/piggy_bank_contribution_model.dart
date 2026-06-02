import '../../domain/entities/piggy_bank_contribution.dart';

class PiggyBankContributionModel extends PiggyBankContribution {
  const PiggyBankContributionModel({
    required super.id,
    required super.piggyBankId,
    required super.familyId,
    required super.amount,
    required super.type,
    super.description,
    required super.createdAt,
    required super.createdBy,
  });

  factory PiggyBankContributionModel.fromJson(Map<String, dynamic> j) =>
      PiggyBankContributionModel(
        id:          j['id']            as String,
        piggyBankId: j['piggy_bank_id'] as String,
        familyId:    j['family_id']     as String,
        amount:      (j['amount'] as num).toDouble(),
        type:        j['type']          as String,
        description: j['description']   as String?,
        createdAt:   DateTime.parse(j['created_at'] as String),
        createdBy:   j['created_by']    as String,
      );
}