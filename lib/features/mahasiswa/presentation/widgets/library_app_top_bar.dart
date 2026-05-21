import 'package:flutter/material.dart';

import '../../../../shared/widgets/app/lumina_app_top_bar.dart';

class LibraryAppTopBar extends StatelessWidget {
  const LibraryAppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.leadingIcon,
    this.actionIcon = Icons.notifications_none_rounded,
    this.showNotificationDot = false,
    this.onLeadingTap,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final IconData? leadingIcon;
  final IconData actionIcon;
  final bool showNotificationDot;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return LuminaAppTopBar(
      title: title,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      leadingIcon: leadingIcon,
      onLeadingTap: onLeadingTap,
      actions: [
        LuminaTopBarIconButton(
          icon: actionIcon,
          showDot: showNotificationDot,
          onTap: onActionTap,
        ),
      ],
    );
  }
}
