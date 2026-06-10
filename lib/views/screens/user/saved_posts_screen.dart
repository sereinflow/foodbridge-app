import 'package:food_bridge/views/screens/user/my_favorites_screen.dart';
import 'package:flutter/material.dart';

/// Legacy route alias — redirects to the enhanced My Favorites screen.
class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) => const MyFavoritesScreen();
}
