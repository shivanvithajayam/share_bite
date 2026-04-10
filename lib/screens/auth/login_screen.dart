import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'signup_screen.dart';
import '../donor/donor_home_screen.dart';
import '../ngo/ngo_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _snack('Please fill all fields');
      return;
    }

    try {
      setState(() => _loading = true);

      // Login with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
          );

      String uid = userCredential.user!.uid;

      // Get user role from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      String role = userDoc['role'];

      bool isDonorTab = _tabController.index == 0;
      bool isNgoTab = _tabController.index == 1;

      setState(() => _loading = false);

      if (isDonorTab && role != "donor") {
        await FirebaseAuth.instance.signOut();
        _snack("This account is not registered as a donor.");
        return;
      }

      if (isNgoTab && role != "ngo") {
        await FirebaseAuth.instance.signOut();
        _snack("This account is not registered as an NGO.");
        return;
      }

      if (role == "donor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DonorHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NgoHomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      _snack("Login failed. Check email or password.");
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isDonor = _tabController.index == 0;
    final headerColor = isDonor ? AppColors.teal : AppColors.rose;
    final btnColor = isDonor ? AppColors.teal : AppColors.rose;
    final btnText = isDonor ? Colors.white : AppColors.roseDark;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: headerColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
              bottom: 36,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('🍱', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ShareBite',
                      style: TextStyle(
                        fontFamily: 'DM Serif Display',
                        fontSize: 18,
                        color: isDonor ? Colors.white : AppColors.roseDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  isDonor ? 'Welcome back,\nkind soul.' : 'NGO Partner\nPortal',
                  style: TextStyle(
                    fontFamily: 'DM Serif Display',
                    fontSize: 26,
                    color: isDonor ? Colors.white : AppColors.roseDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isDonor
                      ? 'Sign in to share your surplus food'
                      : 'Manage incoming food donations',
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDonor ? Colors.white : AppColors.roseDark)
                        .withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Pill handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Tab bar
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (_, __) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          onTap: (_) => setState(() {}),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: isDonor ? AppColors.mint : AppColors.rose,
                          ),
                          labelColor: isDonor
                              ? AppColors.tealDark
                              : AppColors.roseDark,
                          unselectedLabelColor: AppColors.mutedText,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          tabs: const [
                            Tab(text: 'Donor'),
                            Tab(text: 'NGO Partner'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    _buildField(
                      controller: _emailCtrl,
                      label: 'Email address',
                      hint: 'you@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _buildField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.mutedText,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _snack('Password reset email sent'),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: btnColor, fontSize: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          foregroundColor: btnText,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isDonor
                                    ? 'Sign in as Donor'
                                    : 'Sign in as NGO Partner',
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "New here? ",
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          ),
                          child: Text(
                            'Create account',
                            style: TextStyle(
                              color: btnColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.mutedText),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
