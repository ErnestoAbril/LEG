import 'package:flutter/material.dart';

/// Small placeholder for budget tile if needed elsewhere. Keeps analyzer happy.
class BudgetTile extends StatelessWidget {
  final Widget child;

  const BudgetTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Card(child: child);
}
