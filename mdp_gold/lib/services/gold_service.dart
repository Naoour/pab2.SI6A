import "package:firebase_database/firebase_database.dart";

class GoldService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref(
    'harga_emas',
  );

  Stream<DatabaseEvent> getPriceList() {
    return _database.onValue;
  }
}