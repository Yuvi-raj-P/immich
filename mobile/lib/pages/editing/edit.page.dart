import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:immich_mobile/entities/asset.entity.dart';
import 'package:immich_mobile/widgets/common/immich_image.dart';
import 'package:immich_mobile/widgets/common/immich_toast.dart';
import 'package:auto_route/auto_route.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/providers/album/album.provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

/// A stateless widget that provides functionality for editing an image.
///
/// This widget allows users to edit an image provided either as an [Asset] or
/// directly as an [Image]. It ensures that exactly one of these is provided.
///
/// It also includes a conversion method to convert an [Image] to a [Uint8List] to save the image on the user's phone
/// They automatically navigate to the [HomePage] with the edited image saved and they eventually get backed up to the server.
@immutable
@RoutePage()
class EditImagePage extends ConsumerWidget {
  final Asset asset;
  final Image image;
  final bool isEdited;

  const EditImagePage({
    super.key,
    required this.asset,
    required this.image,
    required this.isEdited,
  });

  Future<Uint8List> _imageToUint8List(Image image) async {
    final Completer<Uint8List> completer = Completer();
    image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) {
              info.image
                  .toByteData(format: ImageByteFormat.png)
                  .then((byteData) {
                if (byteData != null) {
                  completer.complete(byteData.buffer.asUint8List());
                } else {
                  completer.completeError('Failed to convert image to bytes');
                }
              });
            },
            onError: (exception, stackTrace) =>
                completer.completeError(exception),
          ),
        );
    return completer.future;
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).canvasColor,
          title: const Text('Saving Image'),
          content: const Text(
            'The edited image will be saved to your gallery first, then will be backed up to the server eventually.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Image imageWidget =
        Image(image: ImmichImage.imageProvider(asset: asset));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        backgroundColor: Theme.of(context).canvasColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done_rounded,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            onPressed: isEdited
                ? () async {
                    _showSaveDialog(context);
                    try {
                      final Uint8List imageData =
                          await _imageToUint8List(image);
                      if (Platform.isIOS) {
                        await PhotoManager.editor.saveImage(
                          imageData,
                          title:
                              "${asset.fileName.substring(0, asset.fileName.length - 4)}_edited.jpg",
                        );
                      } else {
                        final directory = await getExternalStorageDirectory();
                        final dcimPath =
                            '${directory!.parent.parent.parent.parent.path}/DCIM';
                        final fileName =
                            "${asset.fileName.substring(0, asset.fileName.length - 4)}_edited.jpg";
                        final filePath = '$dcimPath/$fileName';
                        final file = File(filePath);
                        await file.writeAsBytes(imageData);
                        await ref
                            .read(albumProvider.notifier)
                            .getDeviceAlbums();
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } catch (e) {
                      ImmichToast.show(
                        durationInSecond: 6,
                        context: context,
                        msg: 'Error: ${e.toString()}',
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Column(
        children: <Widget>[
          Expanded(
            child: image,
          ),
          Container(
            height: 80,
            color: Theme.of(context).bottomAppBarTheme.color,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 60, right: 10, left: 10, top: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Platform.isAndroid
                    ? Icons.crop_rotate_rounded
                    : Icons.crop_rotate_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                context.pushRoute(
                  CropImageRoute(asset: asset, image: imageWidget),
                );
              },
            ),
            Text('Crop', style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
      ),
    );
  }
}
