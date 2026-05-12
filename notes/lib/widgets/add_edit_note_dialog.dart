import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note.dart';
import '../services/image_service.dart';

class AddEditNoteDialog extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const AddEditNoteDialog({
    Key? key,
    this.note,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditNoteDialog> createState() => _AddEditNoteDialogState();
}

class _AddEditNoteDialogState extends State<AddEditNoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ImageService _imageService = ImageService();
  
  File? _selectedImage;
  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');
    _imageBase64 = widget.note?.imageBase64;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final imageFile = await _imageService.pickImage(source: source);
      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _convertImageToBase64() async {
    if (_selectedImage == null && _imageBase64 == null) {
      return;
    }

    try {
      if (_selectedImage != null) {
        _imageBase64 = await _imageService.imageToBase64(_selectedImage!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _convertImageToBase64();

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        imageBase64: _imageBase64,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
      );

      widget.onSave(note);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      return Image.memory(
        base64Decode(_imageBase64!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Text('Tidak ada gambar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.note == null ? 'Tambah Catatan' : 'Edit Catatan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title Input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Masukkan judul catatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Input
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Masukkan deskripsi catatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Preview
              _buildImagePreview(),
              const SizedBox(height: 16),

              // Image Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageBase64 != null && _selectedImage == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _imageBase64 = null;
                      });
                    },
                    child: const Text('Hapus Gambar'),
                  ),
                ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
