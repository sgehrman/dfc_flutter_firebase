import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_utils.dart';
import 'package:dfc_flutter_firebase/src/users/user_details_screen.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  Future<List<Map<dynamic, dynamic>>?>? _future;

  @override
  void initState() {
    super.initState();

    _future = FirebaseUtils.users();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: FutureBuilder<List<Map<dynamic, dynamic>>?>(
        future: _future,
        builder: (context, snap) {
          var hasData = false;

          if (snap.hasError) {
            print('snap.hasError');
            print(snap);
          }

          if (snap.hasData && !snap.hasError) {
            hasData = true;
          }

          if (hasData) {
            final list = snap.data!;

            return ListView.separated(
              itemBuilder: (context, index) {
                final item = list[index];

                final displayName = item.strVal('displayName');
                final email = item.strVal('email');
                final uid = item.strVal('uid');
                final photoUrl = item.strVal('photoURL');
                final customClaims =
                    item.mapVal<String, dynamic>('customClaims');

                var title = '';
                title += displayName.isNotEmpty ? displayName : '';
                if (title.isNotEmpty) {
                  title += email.isNotEmpty ? ' / $email' : '';
                } else {
                  title += email.isNotEmpty ? email : '';

                  // impossible for uid to be empty
                  title += title.isEmpty ? uid : '';
                }

                final metadata = item['metadata'] as Map;
                final subtitle = Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Last Login: ${metadata['lastSignInTime']}"),
                      if (customClaims != null) Text(customClaims.toString()),
                    ],
                  ),
                );

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: Utils.isNotEmpty(photoUrl)
                        ? Image.network(photoUrl).image
                        : null,
                    child: Utils.isEmpty(photoUrl)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(title),
                  subtitle: subtitle,
                  onTap: () async {
                    final modified = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(
                          map: Map<String, dynamic>.from(item),
                        ),
                      ),
                    );

                    if (modified ?? false) {
                      _future = FirebaseUtils.users();

                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: list.length,
            );
          } else {
            return LoadingWidget(color: Theme.of(context).primaryColor);
          }
        },
      ),
    );
  }
}
