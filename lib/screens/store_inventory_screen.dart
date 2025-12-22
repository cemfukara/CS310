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
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: double.infinity, // <-- force full width
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width, // <-- full width
          child: Padding(
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
                item["owned"]
                    ? const Text("You already own this item.")
                    : ElevatedButton(
                        onPressed: () => _buy(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryPurple,
                          foregroundColor: AppStyles.white,
                        ),
                        child: Text("Buy for ${item["price"]} 🪙"),
                      ),
              ],
            ),
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
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
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
