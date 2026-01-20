import 'package:flutter/material.dart';

class CustomBWButton extends StatelessWidget {
  const CustomBWButton({
    super.key,
    required this.bgColor,
    this.shadowLight,
    this.shadowDark,
    required this.textColor,
    required this.onTap,
    required this.title,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String title;
  final bool? isLoading;
  final Color bgColor;
  final Color? shadowLight;
  final Color? shadowDark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowLight ?? Colors.green.shade200,
              offset: const Offset(-6, -6),
              blurRadius: 10,
            ),
            BoxShadow(
              color: shadowDark ?? Colors.green.shade200,
              offset: const Offset(6, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: isLoading == true
            ? Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              )
            : Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
      ),
    );
  }
}
