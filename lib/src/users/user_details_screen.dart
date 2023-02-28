import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/auth.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({this.map});

  final Map<String, dynamic>? map;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: JsonViewerWidget(widget.map!),
            ),
          ),
          _userClaims(),
        ],
      ),
    );
  }

  Widget _userClaims() {
    final uid = widget.map!['uid'] as String?;

    // Snackbar needed a context
    return Builder(
      builder: (BuildContext context) {
        return Wrap(
          spacing: 6,
          alignment: WrapAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final claim = await showStringDialog(
                  context: context,
                  title: 'Add Membership',
                  message: 'Enter a membership id to make this user a member.',
                );

                if (Utils.isNotEmpty(claim)) {
                  final bool result = await auth.addClaimToUid(uid, claim);

                  if (result) {
                    if (context.mounted) {
                      Utils.showSnackbar(
                        context,
                        '$uid as now is a member of $claim',
                      );

                      Navigator.of(context).pop(true);
                    }
                  } else {
                    if (context.mounted) {
                      Utils.showSnackbar(
                        context,
                        'An error occurred',
                        error: true,
                      );
                    }
                  }
                }
              },
              child: const Text('Add Membership'),
            ),
            ElevatedButton(
              onPressed: () async {
                final claim = await showStringDialog(
                  context: context,
                  title: 'Remove Membership',
                  message:
                      'Enter a membership id to remove this user as as a member.',
                );

                if (Utils.isNotEmpty(claim)) {
                  final bool result = await auth.removeClaimForUid(uid, claim);

                  if (result) {
                    if (context.mounted) {
                      Utils.showSnackbar(
                        context,
                        '$claim membership has been removed for $uid',
                      );

                      Navigator.of(context).pop(true);
                    }
                  } else {
                    if (context.mounted) {
                      Utils.showSnackbar(
                        context,
                        'An error occurred',
                        error: true,
                      );
                    }
                  }
                }
              },
              child: const Text('Remove Membership'),
            ),
          ],
        );
      },
    );
  }
}
