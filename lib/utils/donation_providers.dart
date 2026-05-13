import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// لتخزين ملف الصورة الملتقطة
final donationImageProvider = StateProvider<File?>((ref) => null);

// لتخزين حالة المنتج التي يتوقعها الـ AI أو يختارها المستخدم
final itemConditionProvider = StateProvider<String>((ref) => "Good");

// لتخزين فئة التبرع المختارة
final donationCategoryProvider = StateProvider<String>((ref) => "Food");

// لإظهار مؤشر التحليل (محاكاة لمعالجة الصور بالـ AI)
final isAnalyzingProvider = StateProvider<bool>((ref) => false);
