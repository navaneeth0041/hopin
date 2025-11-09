import 'package:hopin/data/models/help_faq/faq_item.dart';

class FaqDataProvider {
  static final List<String> categories = [
    'All',
    'Getting Started',
    'Rides & Trips',
    'Payments',
    'Safety',
    'Account',
  ];

  static final List<FaqItem> allFaqs = [
    FaqItem(
      category: 'Getting Started',
      question: 'How do I sign up for HopIn?',
      answer:
          'To sign up:\n1. Download the HopIn app\n2. Click "Sign Up"\n3. Enter your college email address\n4. Verify your email with the OTP sent\n5. Complete your profile with your name and phone number\n\nOnly verified college students can use HopIn!',
    ),
    FaqItem(
      category: 'Getting Started',
      question: 'Why do I need a college email to register?',
      answer:
          'We require college email verification to ensure HopIn remains a safe, student-only community. This helps us verify that all users are genuine college students and maintains the security and trust within our platform.',
    ),
    FaqItem(
      category: 'Getting Started',
      question: 'How does HopIn work?',
      answer:
          'HopIn connects students traveling similar routes at similar times:\n\n1. Create or join a trip with your destination and time\n2. The app matches you with students on the same route\n3. Connect instantly and coordinate your ride\n4. Share an auto/taxi and split the fare automatically\n5. Rate your experience after the trip',
    ),

    FaqItem(
      category: 'Rides & Trips',
      question: 'How do I create a trip?',
      answer:
          'To create a trip:\n1. Tap the "Create Trip" button on the home screen\n2. Enter your pickup location\n3. Enter your destination\n4. Select date and time\n5. Choose your preferred transport (auto/taxi)\n6. Add any additional notes\n7. Tap "Create Trip"\n\nOther students on the same route will be able to see and join your trip!',
    ),
    FaqItem(
      category: 'Rides & Trips',
      question: 'How do I join an existing trip?',
      answer:
          'To join a trip:\n1. Browse available trips on the home screen\n2. Use filters to find trips matching your route and time\n3. Tap on a trip to view details\n4. Check the pickup/drop points and timing\n5. Tap "Join Trip"\n\nYou\'ll be added to the trip and can chat with other riders to coordinate.',
    ),
    FaqItem(
      category: 'Rides & Trips',
      question: 'Can I cancel a trip?',
      answer:
          'Yes, you can cancel a trip:\n\n• If you created the trip: Cancel at least 30 minutes before departure. All riders will be notified.\n\n• If you joined a trip: Cancel at least 15 minutes before departure to avoid penalties.\n\nFrequent last-minute cancellations may affect your reliability rating.',
    ),
    FaqItem(
      category: 'Rides & Trips',
      question: 'What if no one joins my trip?',
      answer:
          'If no one joins your trip:\n• You can still use the verified driver directory to book a ride\n• Check the app closer to your departure time - riders often join last minute\n• Try adjusting your timing slightly to match other trips\n• You can cancel the trip without penalty if no one joins',
    ),
    FaqItem(
      category: 'Rides & Trips',
      question: 'How many people can join a single trip?',
      answer:
          'The maximum number of riders depends on the vehicle type:\n• Auto rickshaw: Up to 3 riders\n• Taxi (sedan): Up to 4 riders\n• Taxi (SUV): Up to 6 riders\n\nThis ensures comfort and safety for all passengers.',
    ),

    FaqItem(
      category: 'Payments',
      question: 'How is the fare calculated?',
      answer:
          'Fare calculation is transparent and automatic:\n\n1. Base fare is determined by distance using Google Maps\n2. Total fare is divided equally among all riders\n3. Each rider sees their share before joining\n4. If someone leaves, fares are recalculated automatically\n\nYou always know your exact cost before confirming!',
    ),
    FaqItem(
      category: 'Payments',
      question: 'What payment methods are accepted?',
      answer:
          'HopIn supports multiple payment methods:\n• UPI (Google Pay, PhonePe, Paytm, etc.)\n• Debit/Credit Cards\n• Net Banking\n• Digital Wallets\n\nAll payments are processed securely through trusted payment gateways.',
    ),
    FaqItem(
      category: 'Payments',
      question: 'When do I need to pay?',
      answer:
          'Payment timing:\n• Pay your share before the trip starts\n• Payment is held securely until trip completion\n• Funds are released to the trip creator after the ride\n• In case of cancellation, refunds are processed automatically',
    ),
    FaqItem(
      category: 'Payments',
      question: 'What if someone doesn\'t pay?',
      answer:
          'HopIn requires payment confirmation before trip start. If a rider hasn\'t paid:\n• They cannot join the trip\n• Other riders are not affected\n• The fare is recalculated for paying members\n\nThis ensures all riders contribute fairly.',
    ),
    FaqItem(
      category: 'Payments',
      question: 'Can I get a refund?',
      answer:
          'Refund policy:\n• Trip cancelled by creator: Full refund\n• You cancel 30+ minutes before: Full refund\n• You cancel 15-30 minutes before: 50% refund\n• You cancel less than 15 minutes: No refund\n• Trip not completed: Full refund after investigation\n\nRefunds are processed within 3-5 business days.',
    ),

    FaqItem(
      category: 'Safety',
      question: 'How does HopIn ensure my safety?',
      answer:
          'Your safety is our priority:\n\n• Only verified college students can use the app\n• Real-time location sharing during trips\n• Emergency SOS button to alert your contacts\n• Verified driver directory with ratings\n• Trip history and rider details stored\n• In-app reporting and blocking features\n• 24/7 support team',
    ),
    FaqItem(
      category: 'Safety',
      question: 'What is the SOS feature?',
      answer:
          'The SOS feature is for emergencies:\n\n1. Tap the SOS button during a trip\n2. Your emergency contacts are instantly notified\n3. Your live location is shared with them\n4. Our support team is also alerted\n5. They can track your location in real-time\n\nSet up emergency contacts in Settings > Emergency Contact.',
    ),
    FaqItem(
      category: 'Safety',
      question: 'Can I share my trip details with someone?',
      answer:
          'Yes! You can share trip details:\n• Share live location during active trips\n• Send trip details via WhatsApp, SMS, or email\n• Emergency contacts automatically receive trip info\n• Trip history is always accessible in your profile',
    ),
    FaqItem(
      category: 'Safety',
      question: 'What should I do if I feel unsafe?',
      answer:
          'If you feel unsafe:\n1. Use the SOS button immediately\n2. Contact your emergency contacts\n3. Ask the driver to stop in a safe, public place\n4. Call local emergency services if needed (100/112)\n5. Report the incident through the app\n\nYour safety comes first. Don\'t hesitate to take action.',
    ),
    FaqItem(
      category: 'Safety',
      question: 'How do I report inappropriate behavior?',
      answer:
          'To report issues:\n1. Go to the trip in your Trip History\n2. Tap "Report Issue"\n3. Select the type of problem\n4. Provide details and evidence if available\n5. Submit the report\n\nOur team reviews all reports within 24 hours. Serious violations result in immediate account suspension.',
    ),

    FaqItem(
      category: 'Account',
      question: 'How do I edit my profile?',
      answer:
          'To edit your profile:\n1. Go to Profile tab\n2. Tap on your profile card\n3. Or go to Settings > Edit Profile\n4. Update your name, phone, or photo\n5. Save changes\n\nYour college email cannot be changed for security reasons.',
    ),
    FaqItem(
      category: 'Account',
      question: 'I forgot my password. What should I do?',
      answer:
          'To reset your password:\n1. Tap "Forgot Password" on login screen\n2. Enter your registered college email\n3. Check your email for reset link\n4. Click the link and create a new password\n5. Log in with your new password\n\nThe reset link expires in 1 hour.',
    ),
    FaqItem(
      category: 'Account',
      question: 'Can I delete my account?',
      answer:
          'Yes, you can delete your account:\n1. Go to Settings\n2. Scroll to bottom and tap "Delete Account"\n3. Confirm your decision\n4. Enter your password\n5. Your account will be deleted permanently\n\nNote: This action cannot be undone. All your data will be erased.',
    ),
    FaqItem(
      category: 'Account',
      question: 'How do I block another user?',
      answer:
          'To block a user:\n1. Go to the user\'s profile or trip details\n2. Tap the three dots menu\n3. Select "Block User"\n4. Confirm the action\n\nBlocked users cannot see your trips or contact you. You can manage blocked users in Settings.',
    ),
    FaqItem(
      category: 'Account',
      question: 'Why is my account suspended?',
      answer:
          'Accounts may be suspended for:\n• Multiple cancellations\n• Inappropriate behavior reports\n• Payment fraud or disputes\n• Violation of Terms of Service\n• Safety concerns\n\nCheck your email for details. You can appeal by contacting support@hopin.app.',
    ),
  ];
}
