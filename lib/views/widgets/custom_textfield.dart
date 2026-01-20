import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Color bgColor;
  final Color shadowLight;
  final Color shadowDark;
  final Color textColor;
  final bool isPassword;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.bgColor,
    required this.shadowLight,
    required this.shadowDark,
    required this.textColor,
    this.isPassword = false,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: textColor.withValues(alpha: .7)),
          hintText: hint,
          hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final Color bgColor;
  final Color shadowLight;
  final Color shadowDark;
  final Color textColor;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
    required this.bgColor,
    required this.shadowLight,
    required this.shadowDark,
    required this.textColor,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: widget.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: widget.shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: isObscure,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            widget.icon,
            color: widget.textColor.withValues(alpha: 0.7),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() => isObscure = !isObscure);
            },
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: widget.textColor.withValues(alpha: 0.7),
            ),
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
