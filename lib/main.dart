import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';
import 'config/app_config.dart';
import 'settings_screen.dart';

void main() => runApp(const ResiBotApp());

class AppColors {
  static const bg = Color(0xFF1C1C24);
  static const card = Color(0xFF272633);
  static const softCard = Color(0xFF312F3D);
  static const purple = Color(0xFF9A49D8);
  static const lightPurple = Color(0xFFC27BFF);
  static const text = Color(0xFFF5F0FA);
  static const muted = Color(0xFFAEA3B8);
}

class ResiBotApp extends StatelessWidget {
  const ResiBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resi-Bot',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: Brightness.dark),
      ),
      home: const LoginScreen(),
    );
  }
}

class Assets {
  static const logoLogin = 'assets/images/logo_for_login_page.png';
  static const logo = 'assets/images/resi_bot_logo.png';
  static const home = 'assets/images/home_page.png';
  static const invoices = 'assets/images/invoices.png';
  static const analytics = 'assets/images/analytics.png';
  static const profile = 'assets/images/profile.png';
  static const user = 'assets/images/user.png';
  static const phone = 'assets/images/phone.png';
  static const password = 'assets/images/password.png';
  static const gmail = 'assets/images/gmail_logo.png';
  static const member = 'assets/images/membership_card.png';
}

class DemoData {
  static final invoices = <Invoice>[
    Invoice('7 Eleven', 'Convenience', '₱250.67', 'May 20, 2026', '02:45 PM'),
    Invoice('Alfamart', 'Groceries', '₱120.69', 'May 19, 2026', '06:20 PM'),
    Invoice('Alfamart', 'Groceries', '₱120.69', 'May 16, 2026', '01:12 PM'),
    Invoice('Alfamart', 'Groceries', '₱820.67', 'May 13, 2026', '08:22 AM'),
    Invoice('Dali', 'Groceries', '₱720.69', 'May 10, 2026', '04:11 PM'),
    Invoice('Shell', 'Utilities', '₱5,000.00', 'May 05, 2026', '10:30 AM'),
    Invoice('7 Eleven', 'Convenience', '₱250.67', 'May 01, 2026', '09:35 PM'),
    Invoice('Alfamart', 'Groceries', '₱120.69', 'Apr 29, 2026', '06:10 PM'),
    Invoice('Dali', 'Groceries', '₱720.69', 'Apr 25, 2026', '02:15 PM'),
    Invoice('Alfamart', 'Groceries', '₱820.67', 'Apr 21, 2026', '11:45 AM'),
  ];
}

class Invoice {
  final String vendor, category, amount, date, time;
  Invoice(this.vendor, this.category, this.amount, this.date, this.time);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      top: Column(
        children: [
          const SizedBox(height: 42),
          Image.asset(Assets.logoLogin, height: 210),
          const SizedBox(height: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const Text(
            'Login to continue',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 30),
          AppInput(
            hint: 'Email',
            icon: Assets.gmail,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Password',
            icon: Assets.password,
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: loading ? 'SIGNING IN...' : 'SIGN IN',
            onTap: loading ? () {} : login,
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupInfoScreen()),
              ),
              child: RichText(
                text: const TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
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
}

class SignupInfoScreen extends StatefulWidget {
  const SignupInfoScreen({super.key});

  @override
  State<SignupInfoScreen> createState() => _SignupInfoScreenState();
}

class _SignupInfoScreenState extends State<SignupInfoScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String profilePicture = '';
  String profilePictureName = '';
  String profilePictureType = '';

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> pickProfilePicture() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 800,
    );

    if (pickedImage == null) return;

    final bytes = await pickedImage.readAsBytes();

    setState(() {
      profilePicture = base64Encode(bytes);
      profilePictureName = pickedImage.name;
      profilePictureType = pickedImage.mimeType ?? 'image/jpeg';
    });
  }

  void next() {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPasswordScreen(
          fullName: fullNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          profilePicture: profilePicture,
          profilePictureName: profilePictureName,
          profilePictureType: profilePictureType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign Up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const Text(
            'Please add your picture and details.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: pickProfilePicture,
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFF1EEF4),
              backgroundImage: profilePicture.isNotEmpty
                  ? MemoryImage(base64Decode(profilePicture))
                  : null,
              child: profilePicture.isEmpty
                  ? Image.asset(Assets.user, height: 42)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap to add profile picture',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 20),
          AppInput(
            hint: 'Full Name',
            icon: Assets.user,
            controller: fullNameController,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Email',
            icon: Assets.gmail,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Phone Number',
            icon: Assets.phone,
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 30),
          PrimaryButton(label: 'NEXT', onTap: next),
        ],
      ),
    );
  }
}

class SignupPasswordScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String profilePicture;
  final String profilePictureName;
  final String profilePictureType;

  const SignupPasswordScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.profilePictureName,
    required this.profilePictureType,
  });

  @override
  State<SignupPasswordScreen> createState() => _SignupPasswordScreenState();
}

class _SignupPasswordScreenState extends State<SignupPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void continueToPlan() {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter and confirm your password.')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionScreen(
          fullName: widget.fullName,
          email: widget.email,
          phone: widget.phone,
          password: passwordController.text,
          profilePicture: widget.profilePicture,
          profilePictureName: widget.profilePictureName,
          profilePictureType: widget.profilePictureType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const Text(
            'Create a secure password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 70),
          AppInput(
            hint: 'Password',
            icon: Assets.password,
            obscure: true,
            controller: passwordController,
          ),
          const SizedBox(height: 14),
          AppInput(
            hint: 'Confirm Password',
            icon: Assets.password,
            obscure: true,
            controller: confirmPasswordController,
          ),
          const SizedBox(height: 34),
          PrimaryButton(label: 'SIGN UP', onTap: continueToPlan),
        ],
      ),
    );
  }
}

class SubscriptionScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String profilePicture;
  final String profilePictureName;
  final String profilePictureType;

  const SubscriptionScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.profilePicture,
    required this.profilePictureName,
    required this.profilePictureType,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selected = 0;
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);

    try {
      final plan = selected == 0 ? 'Free' : 'Premium';

      await AuthService.register(
        fullName: widget.fullName,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
        plan: plan,
        profilePicture: widget.profilePicture,
        profilePictureName: widget.profilePictureName,
        profilePictureType: widget.profilePictureType,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      compactLogo: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome to Resi-Bot',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Don\'t miss out on our offer!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: pillDecoration(),
            child: const Text(
              'Start your journey with Resi-Bot Premium!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: PlanCard(
                  title: 'Free',
                  price: '₱0',
                  selected: selected == 0,
                  onTap: () => setState(() => selected = 0),
                  features: const [
                    'Manual invoice input',
                    'Basic tracking',
                    'Limited analytics',
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PlanCard(
                  title: 'Premium',
                  price: '₱499',
                  selected: selected == 1,
                  onTap: () => setState(() => selected = 1),
                  features: const [
                    'AI receipt scanner',
                    'Budget warnings',
                    'Premium analytics',
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: loading ? 'CREATING ACCOUNT...' : 'DONE',
            onTap: loading ? () {} : register,
          ),
          TextButton(
            onPressed: loading ? null : register,
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthShell extends StatelessWidget {
  final Widget child;
  final Widget? top;
  final bool compactLogo;
  const AuthShell({super.key, required this.child, this.top, this.compactLogo = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          if (top != null) top! else SizedBox(height: compactLogo ? 170 : 270, child: Center(child: Image.asset(Assets.logo, height: compactLogo ? 92 : 140))),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(36, 34, 36, 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: child,
            ),
          ),
        ]),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  late final pages = [HomeScreen(openBudget: showBudgetDialog), const InvoicesScreen(), const AnalyticsScreen(), const ProfileScreen()];

  void showBudgetDialog() {
    showDialog(context: context, barrierColor: Colors.black.withOpacity(.72), builder: (_) => const BudgetDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: AppColors.purple,
        shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 4)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoice: DemoData.invoices.first))),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: EdgeInsets.zero,
        color: Colors.white,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          NavItem(asset: Assets.home, label: 'Home', active: index == 0, onTap: () => setState(() => index = 0)),
          NavItem(asset: Assets.invoices, label: 'Invoices', active: index == 1, onTap: () => setState(() => index = 1)),
          const SizedBox(width: 70),
          NavItem(asset: Assets.analytics, label: 'Analytics', active: index == 2, onTap: () => setState(() => index = 2)),
          NavItem(asset: Assets.profile, label: 'Profile', active: index == 3, onTap: () => setState(() => index = 3)),
        ]),
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBell;
  const PageFrame({super.key, required this.title, required this.child, this.showBell = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 88),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          RichText(text: TextSpan(text: 'Resi-', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.purple), children: [TextSpan(text: 'Bot', style: TextStyle(color: Colors.white.withOpacity(.9)))])),
          const Spacer(),
          if (showBell) const Icon(Icons.notifications, color: AppColors.purple),
        ]),
        const SizedBox(height: 22),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Expanded(child: child),
      ]),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback openBudget;
  const HomeScreen({super.key, required this.openBudget});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Monthly Overview',
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: StatCard(label: 'Total Expenses', value: '₱10,000')),
          const SizedBox(width: 16),
          Expanded(child: StatCard(label: 'Total Invoices', value: '55')),
        ]),
        const SizedBox(height: 28),
        const Text('Budget', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Budget Limit', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 6),
          Row(children: [const Text('₱2500/10,000', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const Spacer(), const Text('25%', style: TextStyle(color: AppColors.muted))]),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: .25, minHeight: 11, backgroundColor: const Color(0xFF4A4554), valueColor: const AlwaysStoppedAnimation(AppColors.purple))),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: openBudget, icon: const Icon(Icons.chevron_right, size: 18), label: const Text('Set Budget Here'), style: TextButton.styleFrom(foregroundColor: Colors.white))),
        ])),
        const SizedBox(height: 24),
        const Text('Recent Invoices', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        InvoiceTable(invoices: DemoData.invoices.take(5).toList()),
      ])),
    );
  }
}

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'All Invoices',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: const [FilterChipLite('Date Range'), FilterChipLite('Yesterday'), FilterChipLite('Last 7 Days'), FilterChipLite('Last 15 Days'), FilterChipLite('Last 30 Days')]),
        const SizedBox(height: 14),
        Expanded(child: SingleChildScrollView(child: InvoiceTable(invoices: DemoData.invoices, clickable: true))),
      ]),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Analytics',
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Spending Over Time (Jan - June)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(child: SizedBox(height: 190, child: CustomPaint(painter: LineChartPainter()))),
        const SizedBox(height: 18),
        const Text('Spending by Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AppCard(child: Column(children: [
          CategoryBar('Convenience', '₱50,000', .88),
          CategoryBar('Groceries', '₱40,322', .70),
          CategoryBar('Travel', '₱25,200', .42),
          CategoryBar('Utilities', '₱5,242', .20),
        ])),
        const SizedBox(height: 18),
        const Text('Top Vendors by Total Spend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        InvoiceTable(invoices: DemoData.invoices.take(4).toList(), compact: true),
      ])),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;

  ImageProvider? getProfileImage() {
    final imageBase64 = AppSession.currentUser?.profilePicture ?? '';

    if (imageBase64.isEmpty) return null;

    try {
      return MemoryImage(base64Decode(imageBase64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser;

    return PageFrame(
      title: 'Profile',
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white,
              backgroundImage: getProfileImage(),
              child: getProfileImage() == null
                  ? Image.asset(Assets.user, height: 54)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user?.fullName ?? 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text('Edit ✎', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'User Information',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ProfileRow(
              icon: Icons.badge,
              label: 'User ID',
              value: user?.userId ?? '-',
            ),
            ProfileRow(
              icon: Icons.alternate_email,
              label: 'Email',
              value: user?.email ?? '-',
            ),
            ProfileRow(
              icon: Icons.phone,
              label: 'Phone Number',
              value: user?.phone ?? '-',
            ),
            ProfileRow(
              icon: Icons.workspace_premium,
              label: 'Subscription',
              value: user?.plan ?? 'Free',
              trailing: Icons.chevron_right,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.purple),
                  const SizedBox(width: 12),
                  const Text(
                    'Notification',
                    style: TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  Switch(
                    value: notifications,
                    activeColor: AppColors.purple,
                    onChanged: (v) => setState(() => notifications = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: ProfileRow(
                icon: Icons.settings,
                label: 'API Configuration',
                value: 'n8n Settings',
                trailing: Icons.chevron_right,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'LOGOUT',
              onTap: () {
                AppSession.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white)), const Expanded(child: Text('Invoice Details', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const Icon(Icons.delete_outline, color: AppColors.purple)]),
            const SizedBox(height: 10),
            Row(children: [CircleAvatar(backgroundColor: AppColors.purple, child: Text(invoice.vendor[0], style: const TextStyle(color: Colors.white))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(invoice.vendor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(invoice.category, style: const TextStyle(color: AppColors.muted))]), const Spacer(), Chip(label: Text(invoice.category, style: const TextStyle(color: Colors.white, fontSize: 11)), backgroundColor: AppColors.purple.withOpacity(.35))]),
            const SizedBox(height: 14),
            Text(invoice.amount, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            Text('${invoice.date}  •  ${invoice.time}', style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 18),
            Expanded(
              child: AppCard(
                child: Center(
                  child: Container(
                    width: 230,
                    padding: const EdgeInsets.all(18),
                    color: Colors.white,
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.black, fontSize: 11),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('7 ELEVEN PHILIPPINES', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Text('Sample Scanned Receipt'),
                          const Divider(color: Colors.black),
                          receiptLine('Hotdog Sandwich', '₱85.00'),
                          receiptLine('Bottled Water', '₱35.00'),
                          receiptLine('Coffee', '₱65.00'),
                          receiptLine('Convenience Fee', '₱65.67'),
                          const Divider(color: Colors.black),
                          receiptLine('TOTAL', invoice.amount, bold: true),
                          const SizedBox(height: 16),
                          const Text('THANK YOU!'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Extracted Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AppCard(child: Column(children: [DetailLine('Vendor', invoice.vendor), DetailLine('Category', invoice.category), DetailLine('Amount', invoice.amount), DetailLine('Date', invoice.date), DetailLine('Time', invoice.time)])),
            const SizedBox(height: 14),
            PrimaryButton(label: 'Edit Details', onTap: () {}),
          ]),
        ),
      ),
    );
  }

  Widget receiptLine(String left, String right, {bool bold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(left, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Text(right, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))]);
}

class BudgetDialog extends StatefulWidget {
  const BudgetDialog({super.key});
  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  int preset = 1;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Set Budget Limit', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white70))]),
          const Text('Set your monthly budget limit to track and manage your spending.', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          const Text('Monthly Budget Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('₱ 2,500', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(color: AppColors.purple),
          Row(children: List.generate(4, (i) { final values = ['₱1,000', '₱2,500', '₱5,000', '₱10,000']; return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: ChoiceChip(label: Text(values[i], style: const TextStyle(fontSize: 10)), selected: preset == i, selectedColor: AppColors.purple, onSelected: (_) => setState(() => preset = i)))); })),
          const SizedBox(height: 18),
          AppCard(child: const Row(children: [Icon(Icons.calendar_month, color: AppColors.purple), SizedBox(width: 12), Expanded(child: Text('Budget Period\nMonthly', style: TextStyle(color: Colors.white))), Icon(Icons.keyboard_arrow_down, color: AppColors.muted)])),
          const SizedBox(height: 12),
          AppCard(child: const Row(children: [Icon(Icons.refresh, color: AppColors.purple), SizedBox(width: 12), Expanded(child: Text('Your budget will reset automatically every month.', style: TextStyle(color: Colors.white)))])),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save Budget', onTap: () => Navigator.pop(context)),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.muted)))),
        ]),
      ),
    );
  }
}

class AppInput extends StatelessWidget {
  final String hint;
  final String icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AppInput({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(icon, height: 18, width: 18),
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(height: 48, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))));
}

class PlanCard extends StatelessWidget {
  final String title, price;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;
  const PlanCard({super.key, required this.title, required this.price, required this.features, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), height: 190, decoration: BoxDecoration(color: selected ? const Color(0xFFF5EFFA) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.purple : Colors.grey.shade300, width: selected ? 2 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)), Text(price, style: const TextStyle(color: AppColors.purple, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 8), ...features.map((f) => Padding(padding: const EdgeInsets.only(top: 7), child: Row(children: [Icon(Icons.check_circle, color: selected ? AppColors.purple : Colors.grey, size: 14), const SizedBox(width: 4), Expanded(child: Text(f, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)))])))])));
  }
}

class NavItem extends StatelessWidget {
  final String asset, label;
  final bool active;
  final VoidCallback onTap;
  const NavItem({super.key, required this.asset, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(asset, width: 26, height: 26, opacity: AlwaysStoppedAnimation(active ? 1 : .55)), Text(label, style: TextStyle(color: active ? AppColors.purple : Colors.grey, fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal))]));
}

class StatCard extends StatelessWidget {
  final String label, value;
  const StatCard({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)), const SizedBox(height: 8), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]));
}

class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)), child: child);
}

class InvoiceTable extends StatelessWidget {
  final List<Invoice> invoices;
  final bool clickable, compact;
  const InvoiceTable({super.key, required this.invoices, this.clickable = false, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return AppCard(child: Column(children: [
      if (!compact) const Row(children: [Expanded(child: Text('Vendor', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 12))), Expanded(child: Text('Category', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 12))), Text('Amount', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.bold, fontSize: 12))]),
      if (!compact) const Divider(color: Color(0xFF3A3846)),
      ...invoices.map((invoice) => InkWell(
        onTap: clickable ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoice: invoice))) : null,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [
          Container(width: 22, height: 22, decoration: BoxDecoration(color: const Color(0xFFC8B190), borderRadius: BorderRadius.circular(3)), child: const Icon(Icons.receipt_long, size: 14, color: AppColors.bg)),
          const SizedBox(width: 8),
          Expanded(child: Text(invoice.vendor, style: const TextStyle(color: Colors.white, fontSize: 12))),
          Expanded(child: Text(invoice.category, style: const TextStyle(color: Colors.white, fontSize: 12))),
          Text(invoice.amount, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ])),
      )),
    ]));
  }
}

class FilterChipLite extends StatelessWidget {
  final String label;
  const FilterChipLite(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.purple.withOpacity(.25), borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)));
}

class CategoryBar extends StatelessWidget {
  final String label, amount;
  final double value;
  const CategoryBar(this.label, this.amount, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: value, minHeight: 12, backgroundColor: const Color(0xFF4A4554), valueColor: const AlwaysStoppedAnimation(AppColors.purple)))), const SizedBox(width: 8), Text(amount, style: const TextStyle(color: AppColors.muted, fontSize: 12))]));
}

class ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final IconData? trailing;
  final VoidCallback? onTap;
  const ProfileRow({super.key, required this.icon, required this.label, required this.value, this.trailing, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: InkWell(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: AppColors.purple), 
        const SizedBox(width: 14), 
        Text(label, style: const TextStyle(color: Colors.white70)), 
        const Spacer(), 
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)), 
        if (trailing != null) Icon(trailing, color: AppColors.purple)
      ]),
    ),
  );
}

class DetailLine extends StatelessWidget {
  final String label, value;
  const DetailLine(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Text(label, style: const TextStyle(color: AppColors.muted)), const Spacer(), Text(value, style: const TextStyle(color: Colors.white))]));
}

BoxDecoration pillDecoration() => BoxDecoration(color: const Color(0xFFF5EFFA), borderRadius: BorderRadius.circular(8));

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(.10)..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final points = <Offset>[
      Offset(0, size.height * .85),
      Offset(size.width * .17, size.height * .35),
      Offset(size.width * .36, size.height * .70),
      Offset(size.width * .55, size.height * .55),
      Offset(size.width * .75, size.height * .12),
      Offset(size.width, size.height * .70),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) { path.lineTo(p.dx, p.dy); }
    final fill = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    final fillPaint = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.purple.withOpacity(.75), AppColors.purple.withOpacity(.05)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(path, Paint()..color = AppColors.purple..strokeWidth = 3..style = PaintingStyle.stroke);
    for (final p in points) { canvas.drawCircle(p, 4, Paint()..color = AppColors.lightPurple); }
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: AppColors.muted, fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width * i / 5 - 8, size.height - 2));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
