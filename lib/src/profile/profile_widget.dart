import 'package:avatar_glow/avatar_glow.dart';
import 'package:dfc_flutter/dfc_flutter_web.dart';
import 'package:dfc_flutter_firebase/src/firebase/firebase_user_provider.dart';
import 'package:dfc_flutter_firebase/src/profile/profile_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget();

  Widget _userImageWidget(
    BuildContext context,
    FirebaseUserProvider userProvider,
  ) {
    Widget image;
    Color backColor = Colors.white;

    if (userProvider.photoUrl.isNotEmpty) {
      image = Image.network(userProvider.photoUrl);
      backColor = Colors.transparent;
    } else {
      image = const Icon(Icons.person, size: 90, color: Colors.black54);
    }

    return AvatarGlow(
      endRadius: 80, //required
      glowColor: Colors.blue,

      child: Material(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: const CircleBorder(),
        child: CircleAvatar(
          backgroundColor: backColor,
          radius: 60,
          child: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<FirebaseUserProvider>(context);
    String userName = 'Profile';

    if (userProvider.hasUser) {
      userName = userProvider.identity;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          children: [
            _userImageWidget(context, userProvider),
            Text(userName, style: Theme.of(context).textTheme.headline5),
            Text(
              userProvider.email,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              userProvider.phoneNumber,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              'id: ${userProvider.userId}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              'admin: ${userProvider.isAdmin}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final ProfileData? data =
                    await showEmailEditProfileDialog(context);

                if (data != null) {
                  try {
                    if (Utils.isNotEmpty(data.name)) {
                      await userProvider.updateProfile(
                        data.name,
                        data.photoUrl,
                      );
                    }

                    if (Utils.isNotEmpty(data.email)) {
                      await userProvider.updateEmail(data.email);
                    }
                  } catch (error) {
                    print('Error saving user name/email: $error');
                  }
                }
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
