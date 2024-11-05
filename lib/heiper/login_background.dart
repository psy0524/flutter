import 'package:flutter/material.dart';
import 'package:untitled1/data/join_or_login.dart';

class LoginBackground extends CustomPainter {
  // Use 'required' to indicate this parameter is mandatory
  LoginBackground({required this.isJoin}); // Marking as required

  final bool isJoin;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = isJoin ? Colors.red : Colors.blue;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), size.height * 0.5, paint);
    // TODO: Implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: Implement ShouldRepaint
    return false; // Or return true based on your requirements
  }
}
