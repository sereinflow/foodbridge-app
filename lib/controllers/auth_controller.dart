import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_bridge/models/user.dart';
import 'package:food_bridge/views/screens/auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  var userModel = Rxn<UserModel>();

  Future<String?> login(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return "error";

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('User data not found in Firestore.');
        return "error";
      }

      final data = userDoc.data()!;
      final fetchedUser = UserModel.fromMap(data);

      userModel.value = fetchedUser;

      return userModel.value?.role;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      return "error";
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    isLoading.value = true;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return false;

      await user.updateDisplayName(name);

      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: 'user',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser.toMap());

      userModel.value = newUser;

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration error: ${e.message}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> isUserLoggedIn() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          userModel.value = UserModel.fromMap(userDoc.data()!);
          debugPrint("User is logged in: ${userModel.value?.email}");
          return userModel.value?.role;
        } else {
          debugPrint("Firestore record not found for user: ${currentUser.uid}");
          return null;
        }
      } else {
        debugPrint("No user is currently logged in.");
        return null;
      }
    } catch (e) {
      debugPrint("Error checking user login: $e");
      return null;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        await user.delete();

        Get.offAll(() => LoginScreen());
        Get.snackbar("Success", "Account deleted successfully");
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", "Failed to delete account: ${e.message}");
      if (e.code == 'requires-recent-login') {
        logout();
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", "Unknown error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final user = userModel.value;
    if (user == null) return;

    try {
      final isSaved = user.savedPosts.contains(postId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      if (isSaved) {
        await userRef.update({
          'savedPosts': FieldValue.arrayRemove([postId])
        });
        userModel.value = user.copyWith(
            savedPosts: user.savedPosts.where((id) => id != postId).toList());
      } else {
        await userRef.update({
          'savedPosts': FieldValue.arrayUnion([postId])
        });
        userModel.value = user.copyWith(
            savedPosts: [...user.savedPosts, postId]);
      }
    } catch (e) {
      debugPrint("Error toggling bookmark: \$e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAll(() => LoginScreen());
  }
}
