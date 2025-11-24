import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

/// Friends Screen - Connect and share promises with friends
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _searchQuery = '';
  final List<Map<String, String>> _friends = [
    {
      'name': 'Sarah Johnson',
      'status': 'Active',
      'sharedPromises': '3',
      'avatar': 'SJ'
    },
    {
      'name': 'Mike Chen',
      'status': 'Active',
      'sharedPromises': '5',
      'avatar': 'MC'
    },
    {
      'name': 'Emma Davis',
      'status': 'Inactive',
      'sharedPromises': '2',
      'avatar': 'ED'
    },
  ];

  final List<Map<String, String>> _friendRequests = [
    {'name': 'Alex Turner', 'avatar': 'AT', 'mutual': '3'},
    {'name': 'Jordan Lee', 'avatar': 'JL', 'mutual': '2'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isSmallScreen ? AppStyles.paddingMedium : AppStyles.paddingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppStyles.borderRadiusSmallAll,
                ),
              ),
            ),
            const SizedBox(height: AppStyles.paddingLarge),

            // Friend Requests Section
            Text('Friend Requests', style: AppStyles.headingSmall),
            const SizedBox(height: AppStyles.paddingMedium),
            ..._buildFriendRequests(),
            const SizedBox(height: AppStyles.paddingXLarge),

            // Friends Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Friends (${_friends.length})', style: AppStyles.headingSmall),
                ElevatedButton.icon(
                  onPressed: _showAddFriendDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            ..._buildFriendsList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFriendRequests() {
    return _friendRequests.map((request) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppStyles.primaryPurple,
                  child: Text(
                    request['avatar']!,
                    style: const TextStyle(color: AppStyles.white),
                  ),
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request['name']!, style: AppStyles.bodyLarge),
                      Text(
                        '${request['mutual']!} mutual friends',
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _respondToRequest(request['name']!, true),
                  child: const Text('Accept'),
                ),
                TextButton(
                  onPressed: () => _respondToRequest(request['name']!, false),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFriendsList() {
    final filteredFriends = _friends
        .where((friend) =>
            friend['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filteredFriends.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppStyles.paddingXLarge),
            child: Text(
              _searchQuery.isEmpty ? 'No friends yet' : 'No friends found',
              style: AppStyles.bodyMedium,
            ),
          ),
        ),
      ];
    }

    return filteredFriends.map((friend) {
      final isActive = friend['status'] == 'Active';
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.paddingMedium),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppStyles.accentPink,
                      child: Text(
                        friend['avatar']!,
                        style: const TextStyle(color: AppStyles.white),
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppStyles.successGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppStyles.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppStyles.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friend['name']!, style: AppStyles.bodyLarge),
                      Text(
                        '${friend['sharedPromises']!} shared promises',
                        style: AppStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('View Profile')),
                    const PopupMenuItem(child: Text('View Promises')),
                    const PopupMenuItem(
                      child: Text('Remove Friend'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _respondToRequest(String name, bool accept) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accept
              ? 'You are now friends with $name'
              : 'Friend request declined',
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter friend name or email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Friend request sent to ${controller.text}'),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
