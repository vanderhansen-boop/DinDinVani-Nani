import 'package:flutter/material.dart';
import '../../../../domain/entities/user_profile.dart';

/// Header visual do casal: avatares + nome da familia
class CoupleAvatarHeader extends StatelessWidget {
  final UserProfile  me;
  final UserProfile? partner;
  final String       familyName;
  final String       familyEmoji;

  const CoupleAvatarHeader({
    super.key,
    required this.me,
    this.partner,
    required this.familyName,
    required this.familyEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Avatares lado a lado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarBadge(profile: me,      isMe: true),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                child: Column(
                  children: [
                    Text(familyEmoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text('&',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onPrimaryContainer)),
                  ],
                ),
              ),
              if (partner != null)
                _AvatarBadge(profile: partner!, isMe: false)
              else
                _PendingAvatar(),
            ],
          ),
          const SizedBox(height: 12),
          // Nome da familia
          Text(
            familyName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            partner != null
                ? '${me.displayName} e ${partner!.displayName}'
                : '${me.displayName} (aguardando parceiro)',
            style: TextStyle(
              fontSize: 13,
              color: cs.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final UserProfile profile;
  final bool        isMe;
  const _AvatarBadge({required this.profile, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? Text(profile.emoji,
                      style: const TextStyle(fontSize: 32))
                  : null,
            ),
            if (isMe)
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color:  cs.primary,
                    shape:  BoxShape.circle,
                    border: Border.all(
                        color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(profile.displayName,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: cs.onPrimaryContainer)),
        Text(profile.role.toUpperCase(),
            style: TextStyle(
                fontSize: 9,
                color: cs.onPrimaryContainer.withValues(alpha: 0.6),
                letterSpacing: 1)),
      ],
    );
  }
}

class _PendingAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person_add_rounded,
            size: 28, color: Colors.grey),
      ),
      const SizedBox(height: 6),
      const Text('Pendente',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey)),
    ],
  );
}
