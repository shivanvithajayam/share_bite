import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final emailCtrl = TextEditingController();

  bool loading = false;

  Future<void> resetPassword() async {

    if (emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter your email",
          ),
        ),
      );
      return;
    }

    try {

      setState(() {
        loading = true;
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailCtrl.text.trim(),
      );

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset link sent. Check Inbox or Spam folder.",
          ),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Something went wrong",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.cream,

      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Card(
              elevation: 6,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    const SizedBox(height: 10),

                    Icon(
                      Icons.lock_reset,
                      size: 90,
                      color: AppColors.teal,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Enter your registered email address and we'll send you a password reset link.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,

                      decoration: const InputDecoration(
                        labelText: "Email Address",
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed:
                            loading ? null : resetPassword,

                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Send Reset Link",
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      child: const Text(
                        "Back to Login",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}