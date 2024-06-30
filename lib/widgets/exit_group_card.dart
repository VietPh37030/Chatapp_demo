import 'package:chatapp_firebase/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';

class ExitGroupCard extends StatelessWidget {
  const ExitGroupCard({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
          title: 'Thoát nhóm',
          icon: Icons.exit_to_app,
          iconContainerColor: Colors.red,
          onTap: () {
            // exit group
            showMyAnimatedDialog(
              context: context,
              title: 'Thoát nhóm',
              content: 'Bạn có muốn rời nhóm?',
              textAction: 'Thoát',
              onActionTap: (value) async {
                if (value) {
                  // exit group
                  final groupProvider = context.read<GroupProvider>();
                  await groupProvider.exitGroup(uid: uid).whenComplete(() {
                    showSnackBar(context, 'Đã rời khỏi nhóm');
                    // navigate to first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}
