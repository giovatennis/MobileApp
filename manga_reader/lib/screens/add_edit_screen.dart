import 'package:flutter/material.dart';
import '../models/manga_entry.dart';
import '../database/database_helper.dart';

class AddEditScreen extends StatefulWidget {
  final String scannedText; // pre-filled from ML Kit, empty if editing
  final MangaEntry? existingEntry; // non-null when editing

  const AddEditScreen({
    super.key,
    this.scannedText = '',
    this.existingEntry,
  });

  bool get isEditing => existingEntry != null;

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _volumeController;
  late final TextEditingController _notesController;
  late String _selectedStatus;
  bool _isSaving = false;

  final List<String> _statuses = ['Reading', 'Completed', 'Wishlist'];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      // Pre-fill from existing entry when editing
      _titleController = TextEditingController(text: widget.existingEntry!.title);
      _volumeController = TextEditingController(text: widget.existingEntry!.volume);
      _notesController = TextEditingController(text: widget.existingEntry!.notes);
      _selectedStatus = widget.existingEntry!.status;
    } else {
      // Pre-fill title from scanned text (user can edit it)
      _titleController = TextEditingController(text: widget.scannedText);
      _volumeController = TextEditingController();
      _notesController = TextEditingController();
      _selectedStatus = 'Reading';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        final updated = widget.existingEntry!.copyWith(
          title: _titleController.text.trim(),
          volume: _volumeController.text.trim(),
          status: _selectedStatus,
          notes: _notesController.text.trim(),
        );
        await DatabaseHelper.instance.updateEntry(updated);
      } else {
        final entry = MangaEntry(
          title: _titleController.text.trim(),
          volume: _volumeController.text.trim(),
          status: _selectedStatus,
          notes: _notesController.text.trim(),
          scannedText: widget.scannedText,
          createdAt: DateTime.now(),
        );
        await DatabaseHelper.instance.insertEntry(entry);
      }

      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scanned text preview (only shown on new entry)
              if (!widget.isEditing && widget.scannedText.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.text_fields,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Scanned Text',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.scannedText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // No text found warning
              if (!widget.isEditing && widget.scannedText.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No text was detected. Please fill in the details manually.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Manga Title *',
                  prefixIcon: Icon(Icons.book_outlined),
                  helperText: 'Edit the scanned title or type it manually',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Volume
              TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Volume Number',
                  prefixIcon: Icon(Icons.numbers_outlined),
                  helperText: 'e.g. 1, 2, 3...',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Status
              const Text(
                'Reading Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  Color color;
                  switch (status) {
                    case 'Reading':
                      color = const Color(0xFF1976D2);
                      break;
                    case 'Completed':
                      color = const Color(0xFF388E3C);
                      break;
                    default:
                      color = const Color(0xFFF57C00);
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStatus = status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color
                                : color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            status,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                  helperText: 'Your thoughts, where you left off, etc.',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.isEditing ? 'Update Entry' : 'Save to Journal',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
