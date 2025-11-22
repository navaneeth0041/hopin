import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hopin/data/models/home/driver_model.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- "Old Times" Hardcoded Drivers ---
  // Kept as requested. Note: 'Vinod Kumar' (ID 5) is verified: false, 
  // so he will NOT be shown in the app due to the filter below.
  final List<Driver> _hardcodedDrivers = [
    Driver(
      id: '1',
      name: 'Raju Kumar',
      phoneNumber: '+91 98765 43210',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 AB 1234',
      area: 'Amritapuri',
      rating: 4.8,
      isVerified: true,
    ),
    Driver(
      id: '2',
      name: 'Suresh Babu',
      phoneNumber: '+91 98765 43211',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 CD 5678',
      area: 'Kollam',
      rating: 4.9,
      isVerified: true,
    ),
    Driver(
      id: '3',
      name: 'Anil Kumar',
      phoneNumber: '+91 98765 43212',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 EF 9012',
      area: 'Karunagappally',
      rating: 4.6,
      isVerified: true,
    ),
    Driver(
      id: '4',
      name: 'Mohan Das',
      phoneNumber: '+91 98765 43213',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 GH 3456',
      area: 'Haripad',
      rating: 4.7,
      isVerified: true,
    ),
    Driver(
      id: '5',
      name: 'Vinod Kumar',
      phoneNumber: '+91 98765 43214',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 IJ 7890',
      area: 'Amritapuri',
      rating: 4.5,
      isVerified: false, // This driver will be HIDDEN
    ),
    Driver(
      id: '6',
      name: 'Ramesh Pillai',
      phoneNumber: '+91 98765 43215',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 KL 2345',
      area: 'Kollam',
      rating: 4.9,
      isVerified: true,
    ),
    Driver(
      id: '7',
      name: 'Ajay Kumar',
      phoneNumber: '+91 98765 43216',
      vehicleType: 'auto',
      vehicleNumber: 'KL-07 MN 6789',
      area: 'Kayamkulam',
      rating: 4.4,
      isVerified: true,
    ),
    Driver(
      id: '8',
      name: 'Krishna Das',
      phoneNumber: '+91 98765 43217',
      vehicleType: 'taxi',
      vehicleNumber: 'KL-07 OP 0123',
      area: 'Amritapuri',
      rating: 4.8,
      isVerified: true,
    ),
  ];

  /// Fetches ONLY Verified drivers from Firestore and merges them 
  /// with ONLY Verified drivers from the hardcoded list.
  Stream<List<Driver>> getVerifiedDrivers() {
    return _firestore
        .collection('drivers')
        .where('isVerified', isEqualTo: true) // Filter Firestore Data
        .snapshots()
        .map((snapshot) {
      // 1. Convert Firestore Docs to Driver objects
      final firestoreDrivers = snapshot.docs.map((doc) {
        var data = doc.data();
        // Inject the Firestore Document ID into the model
        data['id'] = doc.id; 
        // Handle cases where int comes as double from JSON
        if (data['rating'] is int) {
          data['rating'] = (data['rating'] as int).toDouble();
        }
        return Driver.fromJson(data);
      }).toList();

      // 2. Filter Hardcoded List
      final verifiedHardcoded = _hardcodedDrivers
          .where((driver) => driver.isVerified)
          .toList();

      // 3. Merge Both Lists
      return [...verifiedHardcoded, ...firestoreDrivers];
    });
  }

  /// Adds a new driver to Firebase
  Future<void> addDriver(Driver driver) async {
    // We use .toJson() to exclude the 'id' field if your model handles it,
    // or we create a map that doesn't include the empty ID string.
    final data = driver.toJson();
    data.remove('id'); // Let Firestore generate the ID
    
    await _firestore.collection('drivers').add(data);
  }
}