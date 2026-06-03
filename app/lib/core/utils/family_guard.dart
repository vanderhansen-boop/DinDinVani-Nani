/// Valida o family_id antes de qualquer query ao Supabase.
/// Previne o erro "invalid input syntax for type uuid: \"\"".
bool isValidFamilyId(String? id) => id != null && id.trim().isNotEmpty;
