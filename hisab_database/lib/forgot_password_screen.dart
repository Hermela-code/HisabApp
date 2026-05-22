import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
const ForgotPasswordScreen({super.key});

@override
State<ForgotPasswordScreen> createState() =>
    _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
  extends State<ForgotPasswordScreen> {

final TextEditingController emailController =
    TextEditingController();

void resetPassword() {
  String email = emailController.text;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Password reset link sent to $email',
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],

    appBar: AppBar(
      title: const Text("Forgot Password"),
      centerTitle: true,
    ),

    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Container(
          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Enter your email to receive a reset link",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,

                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: resetPassword,

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Send Reset Link",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}