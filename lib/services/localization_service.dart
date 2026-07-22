import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationService extends Translations {
  static const Locale localeEnglish = Locale('en', 'US');

  var currentLocale = localeEnglish.obs;

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _englishTranslations,
      };

  Future<void> init() async {
    currentLocale.value = localeEnglish;
    Get.updateLocale(localeEnglish);
  }

  void changeLanguage(String langCode) {
    currentLocale.value = localeEnglish;
    Get.updateLocale(localeEnglish);
  }

  static const Map<String, String> _englishTranslations = {
    // Common
    'appName': 'Food Bridge',
    'ok': 'OK',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'success': 'Success',
    'error': 'Error',
    'loading': 'Loading...',
    'submit': 'Submit',
    'save': 'Save',
    'edit': 'Edit',

    // Onboarding
    'onb_title1': 'Reduce Food Waste',
    'onb_desc1': 'Turn surplus food into meaningful support for communities.',
    'onb_title2': 'Connect With Communities',
    'onb_desc2': 'Connect donors, volunteers, NGOs, and people who need food.',
    'onb_title3': 'Deliver Hope',
    'onb_desc3': 'Together we can reduce hunger and build a sustainable future.',
    'skip': 'Skip',
    'next': 'Next',
    'get_started': 'Get Started',

    // Auth
    'login_welcome': 'Good to see you!',
    'login_subtitle': 'Login to continue',
    'email_hint': 'E-Mail',
    'password_hint': 'Password',
    'confirm_password_hint': 'Confirm Password',
    'forgot_password': 'Forgot Password?',
    'login': 'Login',
    'register': 'Register',
    'create_account': 'Create Account',
    'register_subtitle': 'Register to continue',
    'already_have_acc': 'Already have an account? ',
    'dont_have_acc': "Don't have an account? ",
    'fullname_hint': 'Full Name',
    'role_select': 'Select Role',
    'logout': 'Logout',
    'delete_account': 'Delete Account',
    'logout_confirm': 'Are you sure you want to logout?',
    'delete_confirm': 'Are you sure you want to delete your account? This action cannot be undone and you will lose all your data.',

    // Tabs
    'tab_explore': 'Explore',
    'tab_favorites': 'Favorites',
    'tab_impact': 'Impact',
    'tab_profile': 'Profile',

    // Home / Explore
    'give_today': 'Give ',
    'today': 'today',
    'so_they_can': ', so they can\nthrive ',
    'tomorrow': 'tomorrow!',
    'search_hint': 'Search here...',
    'donation_rising': 'Donation Rising',
    'food_share': 'Food Share',
    'collect': 'Collect',
    'buy': 'Buy',
    'advanced_filters': 'Advanced Filters',
    'food_type': 'Food Type',
    'all': 'All',
    'free': 'Free',
    'sale': 'Sale',
    'food_safety': 'Food Safety',
    'hide_expired': 'Hide Expired Posts',
    'apply_filters': 'Apply Filters',

    // Details Screen
    'donor': 'Donor',
    'volunteer': 'Volunteer',
    'buyer': 'Buyer',
    'ngo': 'NGO',
    'admin': 'Admin',
    'quantity': 'Quantity',
    'price': 'Price',
    'descriptions': 'Descriptions',
    'safety_verif': 'Safety Verification',
    'expires': 'Expires',
    'storage_temp': 'Storage Temp',
    'expiring_soon': 'Expiring Soon',
    'req_to_collect': 'Request to Collect',
    'req_to_buy': 'Request to Buy',
    'bdt': 'BDT',
    'people_donated': 'people Donated',

    // Profile Settings
    'activity_support': 'Activity & Support',
    'my_collections': 'My Collections',
    'my_collections_desc': 'Track your claimed and purchased food',
    'my_posts': 'My Posts Status',
    'my_posts_desc': 'Manage food items you have listed',
    'campaign_history': 'Campaign History',
    'campaign_history_desc': 'View your completed donations',
    'help_faq': 'Help & FAQ',
    'about_us': 'About Us',
    'about_us_desc': 'Learn more about our mission',
    'terms': 'Terms & Service',
    'terms_desc': 'App rules and legal policies',
    'language': 'Language',
    'theme': 'Theme',
    'reset_onboarding': 'Reset Onboarding',
    'reset_onboarding_desc': 'View the intro guide screens again',
    'save_changes': 'Save Changes',
    'phone_label': 'Phone',
    'bio_label': 'Bio',
    'name_label': 'Name',
    'view_reviews': 'View Reviews',
    'no_bio': 'No bio',
    'not_set': 'Not set',

    // Stats
    'donations_stat': 'Donations',
    'meals_stat': 'Meals',
    'deliveries_stat': 'Deliveries',
    'purchases_stat': 'Purchases',

    // Chat
    'chats': 'Chats',
    'no_messages': 'No messages yet',
    'type_message': 'Type message...',
    'seen': 'Seen',
    'sent': 'Sent',
    'unread': 'Unread',
    'image_shared': 'Shared an image',

    // Reporting
    'report_title': 'Submit Report',
    'report_type': 'Report Type',
    'report_user': 'User',
    'report_food': 'Food Listing',
    'report_reason': 'Reason',
    'report_desc': 'Description',
    'report_desc_hint': 'Provide detailed information about the issue...',
    'optional_image': 'Optional Image',
    'expired_food': 'Expired food',
    'unsafe_food': 'Unsafe food',
    'fake_listing': 'Fake listing',
    'incorrect_info': 'Incorrect information',
    'fake_account': 'Fake account',
    'bad_behavior': 'Bad behavior',
    'fraud': 'Fraud',
    'harassment': 'Harassment',
    'report_success': 'Report submitted successfully. Thank you!',
    'report_button': 'Report',
  };
}
