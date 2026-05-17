import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/login_screen.dart';

void main() => runApp(
  DevicePreview(
    enabled: true,
    builder: (context) => const ResiBotApp(),
  ),
);

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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
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
        onTap: clickable ? () {
          // Import and navigate to InvoiceDetailsScreen when needed
          // This will be handled in the screen files that use this table
        } : null,
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
