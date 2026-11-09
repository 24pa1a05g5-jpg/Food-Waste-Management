import 'package:flutter/material.dart';

void main() => runApp(const SavoraApp());

class SavoraApp extends StatelessWidget {
  const SavoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D6A4F),
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFFE07A3F),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w800),
          titleLarge: TextStyle(fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class FoodItem {
  FoodItem({required this.name, required this.category, required this.daysLeft, required this.icon});

  final String name;
  final String category;
  final int daysLeft;
  final IconData icon;
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<FoodItem> _pantry = [
    FoodItem(name: 'Spinach', category: 'Vegetables', daysLeft: 1, icon: Icons.eco_outlined),
    FoodItem(name: 'Greek yogurt', category: 'Dairy', daysLeft: 2, icon: Icons.icecream_outlined),
    FoodItem(name: 'Whole wheat bread', category: 'Bakery', daysLeft: 3, icon: Icons.bakery_dining_outlined),
    FoodItem(name: 'Bananas', category: 'Fruit', daysLeft: 4, icon: Icons.spa_outlined),
  ];

  void _addFood() async {
    final FoodItem? item = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddFoodSheet(),
    );
    if (item != null) setState(() => _pantry.add(item));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(pantry: _pantry, onAddFood: _addFood),
      PantryPage(pantry: _pantry, onAddFood: _addFood),
      const DonatePage(),
      const ProfilePage(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: _addFood,
              icon: const Icon(Icons.add),
              label: const Text('Add food'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.kitchen_outlined), selectedIcon: Icon(Icons.kitchen), label: 'Pantry'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Donate'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(color: Colors.black.withValues(alpha: .58))),
          ],
        ]),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.pantry, required this.onAddFood});
  final List<FoodItem> pantry;
  final VoidCallback onAddFood;

  @override
  Widget build(BuildContext context) {
    final urgent = pantry.where((item) => item.daysLeft <= 2).toList();
    return ListView(padding: const EdgeInsets.only(bottom: 100), children: [
      const PageHeader(title: 'Hello, Maya', subtitle: 'Small choices make a big difference.'),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ImpactCard(),
      ),
      const SectionTitle(title: 'Use these soon', action: 'See pantry'),
      if (urgent.isEmpty)
        const EmptyMessage(message: 'Everything in your pantry is fresh!')
      else
        ...urgent.map((item) => FoodTile(item: item)),
      const SectionTitle(title: 'Your next best meal'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFE4F3E9), borderRadius: BorderRadius.circular(24)),
          child: Row(children: [
            const CircleAvatar(radius: 29, backgroundColor: Color(0xFFFFE1C8), child: Icon(Icons.restaurant_menu, color: Color(0xFFE07A3F), size: 30)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Creamy spinach toast', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text('Uses spinach, yogurt & bread'),
              const SizedBox(height: 10),
              const Text('View recipe  →', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
            ])),
          ]),
        ),
      ),
      const SectionTitle(title: 'Quick actions'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(child: ActionCard(icon: Icons.add_circle_outline, label: 'Add food', onTap: onAddFood)),
          const SizedBox(width: 12),
          Expanded(child: ActionCard(icon: Icons.delete_outline, label: 'Log waste', onTap: () => showSnack(context, 'Waste log opened — great job staying mindful!'))),
        ]),
      ),
    ]);
  }
}

class ImpactCard extends StatelessWidget {
  const ImpactCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF40916C)]),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('THIS MONTH', style: TextStyle(color: Color(0xFFC9F2D8), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          const Text('You saved 12 meals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25)),
          const SizedBox(height: 18),
          Row(children: const [
            ImpactMetric(value: '₹680', label: 'saved'),
            SizedBox(width: 34),
            ImpactMetric(value: '5.4 kg', label: 'CO₂ avoided'),
            SizedBox(width: 34),
            ImpactMetric(value: '82%', label: 'goal'),
          ]),
        ]),
      );
}

class ImpactMetric extends StatelessWidget {
  const ImpactMetric({super.key, required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Color(0xFFC9F2D8), fontSize: 12)),
      ]);
}

class PantryPage extends StatelessWidget {
  const PantryPage({super.key, required this.pantry, required this.onAddFood});
  final List<FoodItem> pantry;
  final VoidCallback onAddFood;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.only(bottom: 100), children: [
        PageHeader(title: 'My pantry', subtitle: '${pantry.length} items tracked'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your food', prefixIcon: const Icon(Icons.search),
              filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SectionTitle(title: 'Expiry date'),
        if (pantry.isEmpty) EmptyMessage(message: 'Your pantry is empty. Add your first item!', action: onAddFood) else ...pantry.map((item) => FoodTile(item: item)),
      ]);
}

class FoodTile extends StatelessWidget {
  const FoodTile({super.key, required this.item});
  final FoodItem item;
  @override
  Widget build(BuildContext context) {
    final isUrgent = item.daysLeft <= 2;
    final label = item.daysLeft == 0 ? 'Use today' : '${item.daysLeft} days left';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          leading: CircleAvatar(backgroundColor: const Color(0xFFE4F3E9), child: Icon(item.icon, color: const Color(0xFF2D6A4F))),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(item.category),
          trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: isUrgent ? const Color(0xFFFFE4D6) : const Color(0xFFE4F3E9), borderRadius: BorderRadius.circular(9)), child: Text(label, style: TextStyle(fontSize: 12, color: isUrgent ? const Color(0xFFB44716) : const Color(0xFF2D6A4F), fontWeight: FontWeight.w700))),
        ),
      ),
    );
  }
}

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.only(bottom: 28), children: [
        const PageHeader(title: 'Share the good', subtitle: 'Connect surplus food to people who need it.'),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(height: 160, decoration: BoxDecoration(color: const Color(0xFFE4F3E9), borderRadius: BorderRadius.circular(24)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.location_on, size: 42, color: Color(0xFF2D6A4F)), SizedBox(height: 8), Text('3 donation points near you', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))])))),
        const SectionTitle(title: 'Nearby partners'),
        const PartnerTile(name: 'Community Fridge', distance: '0.8 km away', icon: Icons.kitchen_outlined),
        const PartnerTile(name: 'Hope Foundation', distance: '1.6 km away', icon: Icons.volunteer_activism_outlined),
        const PartnerTile(name: 'City Food Bank', distance: '3.2 km away', icon: Icons.home_work_outlined),
      ]);
}

class PartnerTile extends StatelessWidget {
  const PartnerTile({super.key, required this.name, required this.distance, required this.icon});
  final String name, distance;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFFFE1C8), child: Icon(icon, color: const Color(0xFFE07A3F))), title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(distance), trailing: OutlinedButton(onPressed: () => showSnack(context, 'Donation request started for $name'), child: const Text('Donate')))));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [
        const PageHeader(title: 'My profile', subtitle: 'Growing better habits, one meal at a time.'),
        const Center(child: CircleAvatar(radius: 42, backgroundColor: Color(0xFFE4F3E9), child: Text('M', style: TextStyle(fontSize: 34, color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)))),
        const SizedBox(height: 10),
        const Center(child: Text('Maya Sharma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
        const SectionTitle(title: 'Settings'),
        const SettingTile(icon: Icons.notifications_outlined, title: 'Expiry reminders'),
        const SettingTile(icon: Icons.flag_outlined, title: 'Monthly goals'),
        const SettingTile(icon: Icons.help_outline, title: 'Help & food tips'),
      ]);
}

class SettingTile extends StatelessWidget { const SettingTile({super.key, required this.icon, required this.title}); final IconData icon; final String title; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Card(child: ListTile(leading: Icon(icon, color: const Color(0xFF2D6A4F)), title: Text(title), trailing: const Icon(Icons.chevron_right)))); }
class SectionTitle extends StatelessWidget { const SectionTitle({super.key, required this.title, this.action}); final String title; final String? action; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 25, 20, 12), child: Row(children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const Spacer(), if (action != null) Text(action!, style: const TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold))])); }
class ActionCard extends StatelessWidget { const ActionCard({super.key, required this.icon, required this.label, required this.onTap}); final IconData icon; final String label; final VoidCallback onTap; @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: const Color(0xFFE07A3F)), const SizedBox(height: 16), Text(label, style: const TextStyle(fontWeight: FontWeight.w700))]))); }
class EmptyMessage extends StatelessWidget { const EmptyMessage({super.key, required this.message, this.action}); final String message; final VoidCallback? action; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(20), child: Center(child: Column(children: [Text(message), if (action != null) TextButton(onPressed: action, child: const Text('Add food'))]))); }

class AddFoodSheet extends StatefulWidget { const AddFoodSheet({super.key}); @override State<AddFoodSheet> createState() => _AddFoodSheetState(); }
class _AddFoodSheetState extends State<AddFoodSheet> {
  final _nameController = TextEditingController(); int _days = 3; String _category = 'Vegetables';
  @override void dispose() { _nameController.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.fromLTRB(20, 22, 20, MediaQuery.of(context).viewInsets.bottom + 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add food item', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 18), TextField(controller: _nameController, autofocus: true, decoration: const InputDecoration(labelText: 'Food name', border: OutlineInputBorder())), const SizedBox(height: 14), DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()), items: const ['Vegetables', 'Fruit', 'Dairy', 'Bakery', 'Cooked food', 'Other'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => _category = value!)), const SizedBox(height: 14), Text('Use within $_days day${_days == 1 ? '' : 's'}'), Slider(value: _days.toDouble(), min: 1, max: 14, divisions: 13, label: '$_days days', onChanged: (value) => setState(() => _days = value.round())), const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { final name = _nameController.text.trim(); if (name.isNotEmpty) Navigator.pop(context, FoodItem(name: name, category: _category, daysLeft: _days, icon: Icons.inventory_2_outlined)); }, child: const Text('Save item')))]));
}

void showSnack(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
