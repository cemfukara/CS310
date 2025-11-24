/*import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Store Screen - In-app store for badges, themes, and rewards
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'All';
  int _coins = 500;

  final List<String> _categories = ['All', 'Badges', 'Themes', 'Powerups', 'Avatars'];

  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Achiever Badge',
      'description': 'For completing 100 promises',
      'price': 0,
      'icon': Icons.military_tech,
      'owned': true,
      'category': 'Badges'
    },
    {
      'name': 'Consistency Crown',
      'description': 'Maintain 30-day streak',
      'price': 250,
      'icon': Icons.stars,
      'owned': false,
      'category': 'Badges'
    },
    {
      'name': 'Dark Theme Pro',
      'description': 'Premium dark theme',
      'price': 150,
      'icon': Icons.palette,
      'owned': false,
      'category': 'Themes'
    },
    {
      'name': 'Ocean Blue Theme',
      'description': 'Calming blue theme',
      'price': 150,
      'icon': Icons.palette,
      'owned': false,
      'category': 'Themes'
    },
    {
      'name': 'Double Points',
      'description': 'Earn 2x points for 1 week',
      'price': 100,
      'icon': Icons.bolt,
      'owned': false,
      'category': 'Powerups'
    },
    {
      'name': 'Skip Promise',
      'description': 'Skip one promise without penalty',
      'price': 80,
      'icon': Icons.skip_next,
      'owned': false,
      'category': 'Powerups'
    },
    {
      'name': 'Ninja Avatar',
      'description': 'Mysterious ninja profile avatar',
      'price': 120,
      'icon': Icons.person,
      'owned': false,
      'category': 'Avatars'
    },
    {
      'name': 'Galaxy Avatar',
      'description': 'Cosmic galaxy profile avatar',
      'price': 180,
      'icon': Icons.person,
      'owned': false,
      'category': 'Avatars'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: AppStyles.warningOrange),
                  const SizedBox(width: 4),
                  Text('$_coins', style: AppStyles.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Filter
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: AppStyles.paddingSmall),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: AppStyles.nearWhite,
                      selectedColor: AppStyles.primaryPurple,
                      labelStyle: AppStyles.labelMedium.copyWith(
                        color: isSelected ? AppStyles.white : AppStyles.darkGray,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Store Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppStyles.paddingMedium),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            color: AppStyles.primaryPurple,
                            size: AppStyles.iconSizeLarge,
                          ),
                          const SizedBox(height: AppStyles.paddingSmall),
                          Text(
                            'Items Owned',
                            style: AppStyles.bodySmall,
                          ),
                          Text(
                            '${_items.where((item) => item['owned']).length}',
                            style: AppStyles.headingSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppStyles.paddingMedium),
                      child: Column(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: AppStyles.warningOrange,
                            size: AppStyles.iconSizeLarge,
                          ),
                          const SizedBox(height: AppStyles.paddingSmall),
                          Text(
                            'Your Coins',
                            style: AppStyles.bodySmall,
                          ),
                          Text(
                            _coins.toString(),
                            style: AppStyles.headingSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Store Items Grid
            Text('Featured Items', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            ..._buildStoreItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStoreItems() {
    final filteredItems = _selectedCategory == 'All'
        ? _items
        : _items.where((item) => item['category'] == _selectedCategory).toList();

    if (filteredItems.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingXLarge),
            child: Text('No items available', style: AppStyles.bodyMedium),
          ),
        ),
      ];
    }

    return filteredItems.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppStyles.primaryPurple.withOpacity(0.1),
                    borderRadius: AppStyles.borderRadiusSmallAll,
                  ),
                  child: Icon(
                    item['icon'],
                    color: AppStyles.primaryPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: AppStyles.bodyLarge),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: AppStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: item['owned']
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyles.paddingSmall,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppStyles.successGreen.withOpacity(0.1),
                            borderRadius: AppStyles.borderRadiusSmallAll,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppStyles.successGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Owned',
                                style: AppStyles.labelSmall
                                    .copyWith(color: AppStyles.successGreen),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _buyItem(item['name'], item['price']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryPurple,
                            foregroundColor: AppStyles.white,
                          ),
                          child: Text(
                            '${item['price']} 🪙',
                            style: AppStyles.labelMedium,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _buyItem(String itemName, int price) {
    if (_coins >= price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Item?'),
          content: Text(
            'Purchase "$itemName" for $price coins?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _coins -= price;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully purchased "$itemName"!'),
                    backgroundColor: AppStyles.successGreen,
                  ),
                );
              },
              child: const Text('Buy'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough coins to purchase this item'),
          backgroundColor: AppStyles.dangerRed,
        ),
      );
    }
  }
}
*/
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class StoreInventoryScreen extends StatefulWidget {
  const StoreInventoryScreen({super.key});

  @override
  State<StoreInventoryScreen> createState() => _StoreInventoryScreenState();
}

class _StoreInventoryScreenState extends State<StoreInventoryScreen> {
  bool showStore = true; // true = Store, false = Inventory
  int coins = 500;

  /// CATEGORIES
  final List<String> categories = [
    "All",
    "Badges",
    "Themes",
    "Powerups",
    "Avatars",
  ];

  String selectedCategory = "All";

  /// STORE ITEMS
  final List<Map<String, dynamic>> storeItems = [
    {
      "name": "Achiever Badge",
      "price": 0,
      "icon": Icons.military_tech,
      "owned": true,
      "category": "Badges",
    },
    {
      "name": "Consistency Crown",
      "price": 250,
      "icon": Icons.stars,
      "owned": false,
      "category": "Badges",
    },
    {
      "name": "Dark Theme Pro",
      "price": 150,
      "icon": Icons.palette,
      "owned": false,
      "category": "Themes",
    },
    {
      "name": "Ocean Blue Theme",
      "price": 150,
      "icon": Icons.palette,
      "owned": false,
      "category": "Themes",
    },
    {
      "name": "Double Points",
      "price": 100,
      "icon": Icons.bolt,
      "owned": false,
      "category": "Powerups",
    },
    {
      "name": "Skip Promise",
      "price": 80,
      "icon": Icons.skip_next,
      "owned": false,
      "category": "Powerups",
    },
    {
      "name": "Ninja Avatar",
      "price": 120,
      "icon": Icons.person,
      "owned": false,
      "category": "Avatars",
    },
    {
      "name": "Galaxy Avatar",
      "price": 180,
      "icon": Icons.person,
      "owned": false,
      "category": "Avatars",
    },
  ];

  /// INVENTORY ITEMS — fake random simulation
  late List<Map<String, dynamic>> inventoryItems;

  @override
  void initState() {
    super.initState();
    _generateInventory();
  }

  void _generateInventory() {
    final random = Random();
    inventoryItems = List.generate(10, (i) {
      final base = storeItems[random.nextInt(storeItems.length)];
      return {
        "id": random.nextInt(999999),
        "name": base["name"],
        "icon": base["icon"],
        "category": base["category"],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store"),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: AppStyles.warningOrange),
              const SizedBox(width: 4),
              Text("$coins", style: AppStyles.bodyLarge),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// Store / Inventory Toggle
          _buildTopSwitch(),

          const SizedBox(height: 20),

          if (showStore) _buildCategorySelector(),

          const SizedBox(height: 20),

          Expanded(
            child: showStore ? _buildStoreGrid() : _buildInventoryGrid(),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // TOP SWITCH UI
  // ───────────────────────────────────────────────
  Widget _buildTopSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _switchButton("Store", true),
        const SizedBox(width: 12),
        _switchButton("Inventory", false),
      ],
    );
  }

  Widget _switchButton(String label, bool isStore) {
    final active = (isStore == showStore);

    return GestureDetector(
      onTap: () => setState(() => showStore = isStore),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppStyles.primaryPurple : AppStyles.nearWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppStyles.primaryPurple, width: 2),
        ),
        child: Text(
          label,
          style: AppStyles.bodyMedium.copyWith(
            color: active ? AppStyles.white : AppStyles.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // CATEGORY SELECTOR
  // ───────────────────────────────────────────────
  Widget _buildCategorySelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppStyles.primaryPurple : AppStyles.nearWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: AppStyles.bodyMedium.copyWith(
                  color: selected ? AppStyles.white : AppStyles.darkGray,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  // STORE GRID
  // ───────────────────────────────────────────────
  Widget _buildStoreGrid() {
    final filtered = selectedCategory == "All"
        ? storeItems
        : storeItems.where((i) => i["category"] == selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final item = filtered[i];

        return GestureDetector(
          onTap: () => _openStoreDrawer(item),
          child: _itemCard(
            icon: item["icon"],
            name: item["name"],
            owned: item["owned"],
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // INVENTORY GRID
  // ───────────────────────────────────────────────
  Widget _buildInventoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: inventoryItems.length,
      itemBuilder: (_, i) {
        final item = inventoryItems[i];

        return GestureDetector(
          onTap: () => _openInventoryDrawer(item),
          child: _itemCard(icon: item["icon"], name: item["name"]),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // SHARED ITEM CARD UI
  // ───────────────────────────────────────────────
  Widget _itemCard({
    required IconData icon,
    required String name,
    bool owned = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyles.nearWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppStyles.primaryPurple.withOpacity(0.15),
            radius: 30,
            child: Icon(icon, color: AppStyles.primaryPurple, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // STORE DRAWER
  // ───────────────────────────────────────────────
  void _openStoreDrawer(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        final price = item["price"];
        final owned = item["owned"];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item["icon"], size: 80, color: AppStyles.primaryPurple),
              const SizedBox(height: 16),
              Text(item["name"], style: AppStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                "Category: ${item["category"]}",
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 20),

              owned
                  ? const Text("You already own this item.")
                  : ElevatedButton(
                      onPressed: () => _buy(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryPurple,
                        foregroundColor: AppStyles.white,
                      ),
                      child: Text("Buy for $price 🪙"),
                    ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // INVENTORY DRAWER
  // ───────────────────────────────────────────────
  void _openInventoryDrawer(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item["icon"], size: 80, color: AppStyles.primaryPurple),
              const SizedBox(height: 16),
              Text(item["name"], style: AppStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                "Category: ${item["category"]}",
                style: AppStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.successGreen,
                  foregroundColor: AppStyles.white,
                ),
                child: const Text("Equip"),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  // BUY LOGIC
  // ───────────────────────────────────────────────
  void _buy(Map<String, dynamic> item) {
    final int price = item["price"];
    if (coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Not enough coins!"),
          backgroundColor: AppStyles.errorRed,
        ),
      );
      return;
    }

    Navigator.pop(context); // close sheet

    setState(() {
      coins -= price;
      item["owned"] = true;
      inventoryItems.add({
        "id": Random().nextInt(999999),
        "name": item["name"],
        "icon": item["icon"],
        "category": item["category"],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Purchased ${item["name"]}!"),
        backgroundColor: AppStyles.successGreen,
      ),
    );
  }
}
