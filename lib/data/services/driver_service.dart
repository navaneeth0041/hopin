import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hopin/data/models/home/driver_model.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // "Old Times" Hardcoded Drivers
  // Note: 'Vinod Kumar' is verified: false, so he will be automatically hidden by the logic below.
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
      isVerified: false, // This driver will be hidden
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

  // Stream that merges Firebase drivers with Hardcoded drivers
  // AND filters for ONLY verified drivers
  Stream<List<Driver>> getVerifiedDrivers() {
    return _firestore
        .collection('drivers')
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      // 1. Fetch Firestore Drivers
      final firestoreDrivers = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return Driver.fromJson(data);
      }).toList();

      // 2. Filter Hardcoded Drivers (Keep only verified ones)
      final verifiedHardcoded = _hardcodedDrivers
          .where((driver) => driver.isVerified)
          .toList();

      // 3. Merge and Return
      return [...verifiedHardcoded, ...firestoreDrivers];
    });
  }

  Future<void> addDriver(Driver driver) async {
    // When adding via the app, we set them to 'verified: true' for now 
    // so you can see them immediately during testing.
    await _firestore.collection('drivers').add(driver.toJson());
  }
}