import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/gamification_provider.dart';

class StoreInventoryScreen extends StatefulWidget {
  final bool initialShowStore;

  const StoreInventoryScreen({super.key, this.initialShowStore = true});

  // Publicly accessible for other screens to resolve Icons
  static final List<Map<String, dynamic>> storeItems = [
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
      "name": "Trophy Avatar",
      "price": 120,
      "icon": Icons.emoji_events_outlined,
      "owned": false,
      "category": "Avatars",
    },
    {
      "name": "Star Avatar",
      "price": 180,
      "icon": Icons.star_border,
      "owned": false,
      "category": "Avatars",
    },
  ];

  @override
  State<StoreInventoryScreen> createState() => _StoreInventoryScreenState();
}

class _StoreInventoryScreenState extends State<StoreInventoryScreen> {
  late bool showStore;

  @override
  void initState() {
    super.initState();
    showStore = widget.initialShowStore;
  }

  final List<String> categories = ["All", "Badges", "Avatars"];

  String selectedCategory = "All";

  // storeItems moved to StoreInventoryScreen class

  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Store"),
            centerTitle: true,
            actions: [
              Row(
                children: [
                  Icon(Icons.monetization_on, color: AppStyles.warningOrange),
                  const SizedBox(width: 4),
                  Text(
                    "${provider.stats.coins}",
                    style: AppStyles.bodyLarge.copyWith(
                      color: const Color.fromARGB(255, 253, 253, 253),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 12),
              _buildTopSwitch(),
              const SizedBox(height: 20),
              if (showStore) _buildCategorySelector(),
              const SizedBox(height: 20),
              Expanded(
                child: showStore
                    ? _buildStoreGrid(provider)
                    : _buildInventoryGrid(provider),
              ),
            ],
          ),
        );
      },
    );
  }

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

  Widget _buildStoreGrid(GamificationProvider provider) {
    // Filter out items that are not in the current categories list
    final validItems = StoreInventoryScreen.storeItems
        .where(
          (i) =>
              categories.contains(i["category"]) || categories.contains("All"),
        )
        .toList();

    final filtered = selectedCategory == "All"
        ? validItems
        : validItems.where((i) => i["category"] == selectedCategory).toList();

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
        final isOwned = provider.hasItem(item["name"]);

        return GestureDetector(
          onTap: () => _openStoreDrawer(item, isOwned, provider),
          child: _itemCard(
            icon: item["icon"],
            name: item["name"],
            owned: isOwned,
          ),
        );
      },
    );
  }

  Widget _buildInventoryGrid(GamificationProvider provider) {
    final userInventory = StoreInventoryScreen.storeItems
        .where((item) => provider.hasItem(item["name"]))
        .toList();

    if (userInventory.isEmpty) {
      return Center(
        child: Text("Your inventory is empty", style: AppStyles.bodyMedium),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: .85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: userInventory.length,
      itemBuilder: (_, i) {
        final item = userInventory[i];

        return GestureDetector(
          onTap: () => _openInventoryDrawer(item),
          child: _itemCard(icon: item["icon"], name: item["name"]),
        );
      },
    );
  }

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

  void _openStoreDrawer(
    Map<String, dynamic> item,
    bool isOwned,
    GamificationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;

        return SizedBox(
          width: width,
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
                isOwned
                    ? const Text("You already own this item.")
                    : ElevatedButton(
                        onPressed: () => _buy(item, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryPurple,
                          foregroundColor: Colors.white,
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

  void _openInventoryDrawer(Map<String, dynamic> item) {
    final provider = Provider.of<GamificationProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) {
        final width = MediaQuery.of(context).size.width;

        return SizedBox(
          width: width,
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
                  onPressed: () async {
                    if (item["category"] == "Badges") {
                      await provider.equipBadge(item["name"]);
                    } else if (item["category"] == "Avatars") {
                      await provider.equipAvatar(item["name"]);
                    }

                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${item["name"]} equipped!"),
                        backgroundColor: AppStyles.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.successGreen,
                    foregroundColor: Colors.white,
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

  void _buy(Map<String, dynamic> item, GamificationProvider provider) async {
    final int price = item["price"];
    final String itemId = item["name"];

    final success = await provider.buyItem(itemId, price);

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Purchased ${item["name"]}!" : "Not enough coins!",
        ),
        backgroundColor: success ? AppStyles.successGreen : AppStyles.errorRed,
      ),
    );
  }
}
