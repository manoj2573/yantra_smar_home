// lib/features/settings/widgets/settings_tile.dart
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: leading != null 
        ? Icon(
            leading,
            color: enabled 
              ? Theme.of(context).iconTheme.color 
              : Theme.of(context).disabledColor,
          )
        : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: enabled 
            ? null 
            : Theme.of(context).disabledColor,
        ),
      ),
      subtitle: subtitle != null 
        ? Text(
            subtitle!,
            style: TextStyle(
              color: enabled 
                ? Theme.of(context).textTheme.bodySmall?.color 
                : Theme.of(context).disabledColor,
            ),
          )
        : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }
}