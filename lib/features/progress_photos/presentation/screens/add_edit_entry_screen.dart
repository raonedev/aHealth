import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/progress_entry.dart';
import '../bloc/progress_bloc.dart';
import '../bloc/progress_event.dart';

const _kOnSurfaceVariant = Color(0xFF40493D);
const _kPrimary = Color(0xFF0D631B);
const _kSurfaceContainerHighest = Color(0xFFE3E2E2);

class AddEditEntryScreen extends StatefulWidget {
  final ProgressEntry? existing;
  const AddEditEntryScreen({super.key, this.existing});

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  DateTime _date = DateTime.now();
  final _weightController = TextEditingController();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _date = widget.existing!.date;
      _weightController.text = widget.existing!.weight.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null) return;
    if (widget.existing == null) {
      if (_pickedImage == null) return;
      context.read<ProgressBloc>().add(
            AddProgressEntry(date: _date, weight: weight, image: _pickedImage!),
          );
    } else {
      context.read<ProgressBloc>().add(
            EditProgressEntry(
              existing: widget.existing!,
              date: _date,
              weight: weight,
              newImage: _pickedImage,
            ),
          );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existingImagePath = widget.existing?.photoPath;
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kOnSurfaceVariant),
        title: Text(
          isEdit ? 'Edit Entry' : 'Add Entry',
          style: const TextStyle(fontWeight: FontWeight.w700, color: _kOnSurfaceVariant),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _kSurfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _pickedImage != null
                    ? Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity)
                    : (existingImagePath != null
                        ? Image.file(File(existingImagePath), fit: BoxFit.cover, width: double.infinity)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedCamera01,
                                color: _kOnSurfaceVariant,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text('Tap to add photo',
                                  style: TextStyle(color: _kOnSurfaceVariant.withValues(alpha: 0.7))),
                            ],
                          )),
              ),
            ),
            const SizedBox(height: 20),
            _fieldCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, color: _kOnSurfaceVariant),
                title: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: _kOnSurfaceVariant),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 12),
            _fieldCard(
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(color: _kOnSurfaceVariant),
                  prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedWeightScale, color: _kOnSurfaceVariant,size: 24,),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _save,
                child: Text(isEdit ? 'Save Changes' : 'Add Entry',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}