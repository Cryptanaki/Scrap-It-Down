
import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'account_screen.dart';
import 'package:scrap_it_down/services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    // index 0 is the categories home built in build();
    const DetailsScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset('assets/icons/app_icon.png', width: 36, height: 36),
        ),
        title: const Text('Scrap It Down', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: _selectedIndex == 2
            ? [
                ValueListenableBuilder<bool>(
                  valueListenable: AuthService.instance.signedIn,
                  builder: (context, signedIn, _) {
                    if (!signedIn) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Log out',
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await AuthService.instance.signOut();
                        if (!mounted) return;
                        setState(() {});
                        messenger.showSnackBar(const SnackBar(content: Text('Signed out')));
                      },
                    );
                  },
                ),
              ]
            : null,
      ),
      body: _selectedIndex == 0 ? _buildCategories(context) : _pages[_selectedIndex - 1],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = <Map<String, dynamic>>[
      {'label': 'scrap/Metal', 'icon': Icons.recycling},
      {'label': 'e-waste', 'icon': Icons.electrical_services},
      {'label': 'Jewelry', 'icon': Icons.diamond},
      {'label': 'Coin', 'icon': Icons.monetization_on},
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => DetailsScreen(title: cat['label'] as String)),
              );
            },
            child: Card(
              color: Colors.black,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    cat['label'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
