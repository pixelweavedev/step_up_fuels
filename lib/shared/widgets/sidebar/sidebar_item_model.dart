import 'package:flutter/material.dart';

/// Data model for a sidebar navigation item.
class SidebarItemModel {
  const SidebarItemModel({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badge,
    this.section,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  /// Optional badge count (e.g., pending invoices).
  final int? badge;

  /// Optional section header shown above this item.
  final String? section;
}
