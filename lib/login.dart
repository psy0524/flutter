import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add this import
import 'package:untitled1/data/join_or_login.dart';
import 'package:untitled1/heiper/login_background.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: size,
            painter: LoginBackground(isJoin: Provider.of<JoinOrLogin>(context).isJoin),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                  child: CircleAvatar(
                    radius: 170, // 크기를 고정
                    backgroundImage: NetworkImage(
                      "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExYmRnZzFqYmJwd3c2cHF2ZHg1Y3c2ejNvbDB4ZGF4anRuMDRnaWE1YSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l46Cy1rHbQ92uuLXa/giphy.webp",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        right: 12,
                        top: 12,
                        bottom: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.account_circle),
                                labelText: "Email",
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please input correct Email.";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true, // Password input masking
                              decoration: InputDecoration(
                                icon: Icon(Icons.vpn_key),
                                labelText: "Password",
                              ),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please input correct Password.";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),
                            Consumer<JoinOrLogin>(
                              builder: (context, value, child) => Opacity(
                                opacity: value.isJoin ? 0 : 1, // Adjusts visibility based on isJoin
                                child: Text("Forgot Password"),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                child: Text(
                                  Provider.of<JoinOrLogin>(context).isJoin ? "Join" : "Login", // Button text based on isJoin
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Provider.of<JoinOrLogin>(context).isJoin ? Colors.red : Colors.blue), // Background color based on isJoin
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    print(_passwordController.text.toString());
                                    // Code to execute when the form is valid
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.1),

                // Combined text using RichText
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black), // Default color for the text
                    children: [
                      TextSpan(
                        text: Provider.of<JoinOrLogin>(context).isJoin ? "Already Have an Account? Sign in." : "Don't Have an Account? Create one.",
                        style: TextStyle(
                          color: Provider.of<JoinOrLogin>(context).isJoin ? Colors.red : Colors.blue, // Change colors based on isJoin
                          fontWeight: FontWeight.bold, // Optional: make it bold for emphasis
                        ),
                        recognizer: TapGestureRecognizer() // Makes the text tappable
                          ..onTap = () {
                            JoinOrLogin joinOrLogin = Provider.of<JoinOrLogin>(context, listen: false);
                            joinOrLogin.toggle(); // Toggles the state when tapped
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}