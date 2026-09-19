import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/shared/widgets/cards/compact_stat_card.dart';
import 'package:step_up_fuels/shared/widgets/cards/customer_financial_metrics.dart';
import 'package:step_up_fuels/shared/widgets/cards/entity_status_presentation.dart';
import 'package:step_up_fuels/shared/widgets/cards/financial_breakdown.dart';

void main() {
  const testWidths = [320.0, 360.0, 375.0, 390.0, 412.0];

  group('Anti-AI-Slop & Responsive Layout Verification Tests', () {
    for (final width in testWidths) {
      testWidgets('CustomerFinancialMetrics renders cleanly without overflow at width $width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: CustomerFinancialMetrics(
                  totalInvoiced: 1250000.50,
                  totalPaid: 950000.00,
                  totalOutstanding: 300000.50,
                  advanceBalance: 50000.00,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Financial Summary'), findsOneWidget);
        expect(find.text('TOTAL INVOICED'), findsOneWidget);
        expect(find.text('OUTSTANDING'), findsOneWidget);
      });

      testWidgets('FinancialBreakdown renders cleanly without overflow at width $width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: FinancialBreakdown(
                  subtotal: 818389.83,
                  taxRows: [
                    FinancialTaxLine(label: 'CGST (9%)', amount: 73655.08),
                    FinancialTaxLine(label: 'SGST (9%)', amount: 73655.09),
                  ],
                  total: 965700.00,
                  outstanding: 965700.00,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Financial Summary'), findsOneWidget);
        expect(find.text('Subtotal'), findsOneWidget);
        expect(find.text('CGST (9%)'), findsOneWidget);
      });

      testWidgets('CompactStatCard does not clip long figures at width $width', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: CompactStatCard(
                  title: 'Total Outstanding',
                  value: '₹9,65,700.00',
                  icon: Icons.account_balance_wallet_outlined,
                  gradientColors: AppColors.gradientOutstanding,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('₹9,65,700.00'), findsOneWidget);
      });
    }

    testWidgets('EntityStatusPresentation produces correct badges', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Column(
              children: [
                EntityStatusPresentation.invoiceBadge(InvoiceStatus.posted),
                EntityStatusPresentation.invoiceBadge(InvoiceStatus.partiallyPaid),
                EntityStatusPresentation.purchasePaymentBadge('PAID'),
                EntityStatusPresentation.purchasePaymentBadge('UNPAID'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Posted'), findsOneWidget);
      expect(find.text('Partially Paid'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Unpaid'), findsOneWidget);
    });
  });
}
