import 'dart:io';

import 'package:flutter/material.dart';

import '../utilities/assets_manager.dart';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({super.key,required this.finalFileImage,required this.radius,required this.onPressed,});

  final File? finalFileImage;
  final double radius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return  finalFileImage == null
          ? Stack(
        children: [
           CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage(AssetsManager.userImage),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              //TO:Sử lí hành động
              onTap: onPressed,
              child:  CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      )
          : Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage:
            FileImage(File(finalFileImage!.path)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: onPressed,
              child:  CircleAvatar(
                radius: radius,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
  }
}
