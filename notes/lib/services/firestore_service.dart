import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'notes';

  /// Add a new note to Firestore
  Future<String> addNote(Note note) async {
    try {
      final docRef = await _firestore.collection(_collection).add(note.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah catatan: $e');
    }
  }

  /// Get all notes from Firestore
  Stream<List<Note>> getNotes() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Note.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('Gagal mengambil catatan: $e');
    }
  }

  /// Get a single note by ID
  Future<Note?> getNote(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Note.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil catatan: $e');
    }
  }

  /// Update an existing note
  Future<void> updateNote(String id, Note note) async {
    try {
      await _firestore.collection(_collection).doc(id).update(note.toMap());
    } catch (e) {
      throw Exception('Gagal memperbarui catatan: $e');
    }
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus catatan: $e');
    }
  }
}
