import "package:flutter/material.dart";
import 'package:cached_network_image/cached_network_image.dart';

class MorokoshiCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  const MorokoshiCachedNetworkImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(
          value: downloadProgress.progress,
        ),
        errorWidget: (context, url, error) => Image.asset("images/noimage.png"),
      ),
    );
  }
}
