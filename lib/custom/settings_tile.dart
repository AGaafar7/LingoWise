import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.leadingIcon,
    required this.tileTitle,
    required this.tileSubtitle,
    required this.trailingIcon,
  });

  final Icon leadingIcon;
  final String tileTitle;
  final String tileSubtitle;
  final Icon trailingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingIcon,
      title: Text(tileTitle),
      subtitle: Text(tileSubtitle),
      trailing: trailingIcon,
    );
  }
}
