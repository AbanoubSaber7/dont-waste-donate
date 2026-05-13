import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/donation_repository.dart';
import '../models/donation.dart';

// Provider for DonationRepository
final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository();
});

// Provider for user donations stream
final userDonationsProvider = StreamProvider.family<List<Donation>, String>((ref, userId) {
  final repository = ref.watch(donationRepositoryProvider);
  return repository.getUserDonations(userId);
});

// Provider for adding donation
final addDonationProvider = FutureProvider.family<void, Donation>((ref, donation) async {
  final repository = ref.watch(donationRepositoryProvider);
  await repository.addDonation(donation);
});