import 'package:chat_app/chat/provider/provider.dart';
import 'package:chat_app/chat/widgets/user_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  Future<void> onRefresh() async {
    // clear friendship cache before refreshing
    ref.invalidate(userProvider);
    ref.invalidate(requestsProvider);
    // wait a bit for the provider to refresh
    await Future.delayed(Duration(milliseconds: 500));
  }
  @override
  Widget build(BuildContext context) {
    // wait the auto-refresh provider to trigger refreshes
    ref.watch(autoRefreshProvider);
    final userAsync = ref.watch(filteredUsersProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("All Users"),
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: TextField(
                  onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: "Search user by name or email...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                        onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                        icon: Icon(Icons.clear),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    )
                  ),
                ),
            )
        ),
      ),
      body: userAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(strokeWidth: 2,),
          ),
          data: (users) {
            if (users.isEmpty && searchQuery.isNotEmpty) {
              return Center(child: Text('No users found matching your search'));
            }
            
            if (users.isEmpty) {
              return Center(child: Text('No other users found'));
            }
            return RefreshIndicator(
              onRefresh: onRefresh,
              // child: ListView.builder(
              //   padding: const EdgeInsets.all(16),
              //   physics: AlwaysScrollableScrollPhysics(),
              //   itemCount: users.length,
              //     itemBuilder: (context, index) {
              //       final user = users[index];
              //       return UserListTile(user: user);
              //     }
              // ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserListTile(user: user);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 13),
                ),
            );
          },
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load profile',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProvider),
                  child: const Text("Retry"),
                )
              ],
            ),
        ),
      ),
    );
  }
}
