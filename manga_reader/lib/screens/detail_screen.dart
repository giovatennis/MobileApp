import 'package:flutter/material.dart';
import '../models/manga_entry.dart';
import '../database/database_helper.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final MangaEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late MangaEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Color get _statusColor {
    switch (_entry.status) {
      case 'Reading':
        return const Color(0xFF1976D2);
      case 'Completed':
        return const Color(0xFF388E3C);
      case 'Wishlist':
        return const Color(0xFFF57C00);
      default:
        return Colors.grey;
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Remove "${_entry.title}" from your journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && _entry.id != null) {
      await DatabaseHelper.instance.deleteEntry(_entry.id!);
      if (mounted) Navigator.of(context).pop(true); // pop back to home
    }
  }

  Future<void> _edit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditScreen(existingEntry: _entry),
      ),
    );

    if (result == true) {
      // Refresh the entry from database
      final entries = await DatabaseHelper.instance.getAllEntries();
      final updated = entries.firstWhere(
        (e) => e.id == _entry.id,
        orElse: () => _entry,
      );
      setState(() => _entry = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _entry.status,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              _entry.title.isEmpty ? 'Untitled' : _entry.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (_entry.volume.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Volume ${_entry.volume}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Notes section
            _SectionLabel(label: 'Notes'),
            const SizedBox(height: 8),
            _entry.notes.isEmpty
                ? Text(
                    'No notes added.',
                    style: TextStyle(
                        color: Colors.grey[500], fontStyle: FontStyle.italic),
                  )
                : Text(
                    _entry.notes,
                    style:
                        const TextStyle(fontSize: 15, height: 1.6),
                  ),

            const SizedBox(height: 24),

            // Scanned text section
            if (_entry.scannedText.isNotEmpty) ...[
              _SectionLabel(label: 'Original Scanned Text'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _entry.scannedText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Date added
            _SectionLabel(label: 'Added'),
            const SizedBox(height: 6),
            Text(
              '${_entry.createdAt.day}/${_entry.createdAt.month}/${_entry.createdAt.year}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Colors.grey,
      ),
    );
  }
}
