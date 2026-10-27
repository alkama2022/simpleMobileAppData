import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../core/models.dart';
import '../widgets/dn_card.dart';
import '../widgets/dn_chip.dart';
import '../widgets/tx_row.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All';
  static const List<String> _filters = ['All', 'Successful', 'Pending', 'Failed'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Transaction> _filtered(List<Transaction> txs) {
    return txs.where((t) {
      final matchFilter = _filter == 'All' || t.statusLabel == _filter;
      final q = _searchCtrl.text.toLowerCase();
      final matchSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.sub.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final txs = context.watch<AppState>().transactions;
    final listed = _filtered(txs);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Transactions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search
                  ValueListenableBuilder(
                    valueListenable: _searchCtrl,
                    builder: (ctx, val, child) => TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: DnChip(
                            label: f,
                            selected: _filter == f,
                            onTap: () => setState(() => _filter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // List
                  DnCard(
                    child: listed.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No transactions found.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: listed.asMap().entries.map((e) {
                              return TxRow(
                                tx: e.value,
                                isLast: e.key == listed.length - 1,
                                showDate: true,
                                onTap: () => Navigator.of(context).pushNamed(
                                  '/transaction-detail',
                                  arguments: e.value,
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
