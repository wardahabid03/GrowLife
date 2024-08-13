import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> checkAndUpdateBadges(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final userData = userDoc.data()!;
    final uploadCount = userData['uploadCount'] ?? 0;
    final plantCount = userData['plantCount'] ?? 0;
    final consecutiveDays = userData['consecutiveDays'] ?? 0;
    final currentBadge = (userData['badges'] as String).isNotEmpty
        ? (userData['badges'] as String)
        : '';

        print("checking user badge");

    String newBadge = '';

    // Determine the highest badge based on combined criteria
    if (uploadCount > 30) newBadge = 'Green Thumb';
    else if (uploadCount > 20) newBadge = 'Plant Hero';
    else if (uploadCount > 10) newBadge = 'Regular Gardener';
    else if (uploadCount > 5) newBadge = 'New Grower';
    else if (consecutiveDays > 30) newBadge = 'Plant Master';
    else if (consecutiveDays > 14) newBadge = 'Two-Week Keeper';
    else if (consecutiveDays > 7) newBadge = 'Weekly Gardener';
    else if (uploadCount > 15 && plantCount > 10) newBadge = 'Top Grower';
    else if (plantCount > 5) newBadge = 'Garden Star';
    else if (plantCount > 3) newBadge = 'Plant Friend';

    if (newBadge != currentBadge) {
         print("new badge");
      await userRef.update({
        'badges': newBadge, // Ensure only one badge is stored
      }
   
      );
         print("badge updated");
      return newBadge;
    }

    return null;
  }
}
