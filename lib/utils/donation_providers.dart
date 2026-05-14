import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// لتخزين ملف الصورة الملتقطة (مؤقتاً للتحليل فقط، لا تُرفع)
final donationImageProvider = StateProvider<File?>((ref) => null);

// لتخزين حالة المنتج التي يتوقعها الـ AI أو يختارها المستخدم
final itemConditionProvider = StateProvider<String>((ref) => "Good");

// لتخزين فئة التبرع المختارة
final donationCategoryProvider = StateProvider<String>((ref) => "Food");

// لإظهار مؤشر التحليل
final isAnalyzingProvider = StateProvider<bool>((ref) => false);

// قرار الـ AI: مقبول أم مرفوض
final aiAcceptedProvider = StateProvider<bool?>((ref) => null);

// سبب القرار من الـ AI
final aiReasonProvider = StateProvider<String>((ref) => "");
