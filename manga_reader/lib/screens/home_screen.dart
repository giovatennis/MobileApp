import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/manga_entry.dart';
import '../widgets/manga_card.dart';
import 'scan_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MangaEntry> _allEntries = [];
  Map<String, int> _statusCounts = {'Reading': 0, 'Completed': 0, 'Wishlist': 0};
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> _filters = ['All', 'Reading', 'Completed', 'Wishlist'];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final entries = await DatabaseHelper.instance.getAllEntries();
      final counts = await DatabaseHelper.instance.getStatusCounts();
      setState(() {
        _allEntries = entries;
        _statusCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<MangaEntry> get _filteredEntries {
    if (_selectedFilter == 'All') return _allEntries;
    return _allEntries
        .where((e) => e.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manga Journal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scan covers and track your collection',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Summary row
                Row(
                  children: [
                    _SummaryChip(
                      label: 'Total',
                      count: _allEntries.length,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _SummaryChip(
                      label: 'Reading',
                      count: _statusCounts['Reading'] ?? 0,
                      color: const Color(0xFF64B5F6),
                    ),
                    const SizedBox(width: 10),
                    _SummaryChip(
                      label: 'Done',
                      count: _statusCounts['Completed'] ?? 0,
                      color: const Color(0xFF81C784),
                    ),
                    const SizedBox(width: 10),
                    _SummaryChip(
                      label: 'Wishlist',
                      count: _statusCounts['Wishlist'] ?? 0,
                      color: const Color(0xFFFFB74D),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    showCheckmark: false,
                    selectedColor: const Color(0xFF1A1A2E),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntries.isEmpty
                    ? _EmptyState(filter: _selectedFilter)
                    : RefreshIndicator(
                        onRefresh: _loadEntries,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return MangaCard(
                              entry: entry,
                              onTap: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(entry: entry),
                                  ),
                                );
                                if (result == true) _loadEntries();
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()),
          );
          _loadEntries(); // always reload, regardless of result
        },
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isFiltered = filter != 'All';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFiltered
                  ? Icons.filter_list_off_rounded
                  : Icons.menu_book_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No "$filter" entries yet'
                  : 'Your journal is empty',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Scan a manga or add one manually'
                  : 'Tap Scan to add your first manga',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
