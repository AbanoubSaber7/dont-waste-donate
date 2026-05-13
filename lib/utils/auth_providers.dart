import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Provider بيجيب بيانات المستخدم من الـ Firestore بناءً على الـ UID
final userDocProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  
  if (user == null) return Stream.value(null);
  
  return ref.watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots();
});

// Provider بيجيب اسم المستخدم من الـ Firestore (أو الـ Auth كاحتياط)
final userNameProvider = Provider<String>((ref) {
  final userDoc = ref.watch(userDocProvider);
  final authState = ref.watch(authStateProvider);
  
  // 1. نحاول نجيب الاسم من Firestore الأول (زي ما المستخدم طلب)
  final firestoreName = userDoc.asData?.value?.data() != null 
      ? (userDoc.asData!.value!.data() as Map<String, dynamic>)['name'] as String?
      : null;
      
  if (firestoreName != null && firestoreName.isNotEmpty) {
    return firestoreName;
  }

  // 2. لو مش موجود في Firestore، نشوف الـ Display Name بتاع الـ Auth
  final user = authState.asData?.value;
  if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
    return user.displayName!;
  }

  // 3. كآخر حل لو مفيش خالص
  return "User";
});
