import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/widgets/progress_view.dart';

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CustomCachedImage(
      {Key key, @required this.imageUrl, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return imageUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            placeholder: (context, url) => ProgressView(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
        : Container(
            height: 0,
          );
  }
}
