import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_styles.dart';
import '../providers/friends_provider.dart';
import '../models/user_model.dart';
import '../models/promise_request_model.dart';
import '../services/database_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog() {
    final emailController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Friend'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the exact email of your friend.'),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'friend@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSearching
                    ? null
                    : () async {
                        if (emailController.text.isEmpty) return;

                        setState(() => isSearching = true);

                        final provider = Provider.of<FriendsProvider>(
                          context,
                          listen: false,
                        );

                        final error = await provider.sendRequest(
                          emailController.text,
                        );

                        if (mounted) {
                          setState(() => isSearching = false);
                          Navigator.pop(context);

                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent!'),
                                backgroundColor: AppStyles.successGreen,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: AppStyles.errorRed,
                              ),
                            );
                          }
                        }
                      },
                child: const Text('Send Request'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRequestsDialog(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) {
        final db = Provider.of<DatabaseService>(context, listen: false);
        return AlertDialog(
          title: Text('Requests from ${friend.displayName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<PromiseRequestModel>>(
              stream: db.getPromiseRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter requests from this friend
                final allRequests = snapshot.data ?? [];
                final requests = allRequests
                    .where((r) => r.senderUid == friend.uid)
                    .toList();

                if (requests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No pending promise requests."),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    return Card(
                      color: AppStyles.nearWhite,
                      child: ListTile(
                        title: Text(req.title, style: AppStyles.labelLarge),
                        subtitle: Text(req.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: AppStyles.successGreen,
                              ),
                              onPressed: () async {
                                await db.acceptPromiseRequest(req);
                                if (mounted) Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Promise accepted!"),
                                    backgroundColor: AppStyles.successGreen,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppStyles.errorRed,
                              ),
                              onPressed: () async {
                                await db.declinePromiseRequest(req.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppStyles.white,
          labelColor: AppStyles.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            // FRIEND COUNT TAB
            StreamBuilder<List<UserModel>>(
              stream: provider.friendsStream,
              builder: (_, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Tab(text: 'My Friends ($count)');
              },
            ),

            // REQUEST COUNT TAB
            StreamBuilder<List<UserModel>>(
              stream: provider.requestsStream,
              builder: (_, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Tab(text: 'Requests ($count)');
              },
            ),
          ],
        ),
      ),

      // TAB CONTENT
      body: TabBarView(
        controller: _tabController,
        children: [_friendsTab(provider), _requestsTab(provider)],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriendDialog,
        backgroundColor: AppStyles.primaryPurple,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Friend', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ---------------- FRIENDS TAB ----------------
  Widget _friendsTab(FriendsProvider provider) {
    return StreamBuilder<List<UserModel>>(
      stream: provider.friendsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data!;

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  "No friends yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final initials = friend.displayName.isNotEmpty
                ? friend.displayName[0].toUpperCase()
                : '?';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppStyles.accentPink,
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(friend.displayName, style: AppStyles.bodyLarge),
                subtitle: Text(friend.email, style: AppStyles.bodySmall),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.assignment_ind_outlined,
                    color: AppStyles.primaryPurple,
                  ),
                  tooltip: 'Promise Requests',
                  onPressed: () => _showRequestsDialog(friend),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- REQUESTS TAB ----------------
  Widget _requestsTab(FriendsProvider provider) {
    return StreamBuilder<List<UserModel>>(
      stream: provider.requestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;

        if (requests.isEmpty) {
          return const Center(child: Text("No pending requests."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final initials = req.displayName.isNotEmpty
                ? req.displayName[0].toUpperCase()
                : '?';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppStyles.primaryPurple,
                      child: Text(
                        initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            req.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: AppStyles.successGreen,
                        size: 30,
                      ),
                      onPressed: () => provider.acceptRequest(req),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: AppStyles.errorRed,
                        size: 30,
                      ),
                      onPressed: () => provider.declineRequest(req.uid),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
