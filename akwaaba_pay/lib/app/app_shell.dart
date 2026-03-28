import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expenses/presentation/screens/expenses_list_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/sales/presentation/screens/sales_list_screen.dart';
import '../features/voice_input/domain/entities/voice_command.dart';
import '../features/voice_input/presentation/widgets/voice_input_bottom_sheet.dart';
import '../features/sales/presentation/providers/sales_provider.dart';
import '../features/expenses/presentation/providers/expenses_provider.dart';
import '../core/providers/app_providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    SalesListScreen(),
    SizedBox(), // Placeholder for mic button
    ExpensesListScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex >= 2 ? _currentIndex : _currentIndex,
        children: [
          _screens[0],
          _screens[1],
          _screens[2],
          _screens[3],
          _screens[4],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Sales',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                // Center mic button
                GestureDetector(
                  onTap: () => _openVoiceInput(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.micGradient,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.trending_down_rounded,
                  label: 'Expenses',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVoiceInput() {
    VoiceInputBottomSheet.show(
      context,
      ref,
      onConfirm: (command) => _handleVoiceCommand(command),
    );
  }

  void _handleVoiceCommand(VoiceCommand command) {
    final language = ref.read(selectedLanguageProvider);

    if (command.type == TransactionType.sale) {
      ref.read(salesNotifierProvider.notifier).addSale(
            itemName: command.itemName ?? 'Sale',
            amount: command.amount ?? 0,
            quantity: command.quantity,
            category: command.category ?? 'Other',
            voiceTranscription: command.rawTranscription,
            language: language,
          );
      _showConfirmation('Sale recorded!', AppColors.success);
      setState(() => _currentIndex = 1); // Navigate to sales
    } else if (command.type == TransactionType.expense) {
      ref.read(expensesNotifierProvider.notifier).addExpense(
            description: command.itemName ?? 'Expense',
            amount: command.amount ?? 0,
            category: command.category ?? 'Other',
            voiceTranscription: command.rawTranscription,
            language: language,
          );
      _showConfirmation('Expense recorded!', AppColors.warning);
      setState(() => _currentIndex = 3); // Navigate to expenses
    }
  }

  void _showConfirmation(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
