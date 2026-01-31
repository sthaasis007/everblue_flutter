import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget to display profile picture given the backend stored path.
/// Example input: `/public/profile_picture/profile_123abc.jpg`
class ProfilePictureDisplay extends StatelessWidget {
  final String? profilePath;
  final double size;
  final String baseUrl;

  const ProfilePictureDisplay({Key? key, this.profilePath, this.size = 72, this.baseUrl = 'http://localhost:3000'}) : super(key: key);

  String? _toFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    final full = _toFullUrl(profilePath);
    if (full == null) {
      return CircleAvatar(radius: size / 2, child: Icon(Icons.person, size: size * 0.6));
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: full,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(width: size, height: size, alignment: Alignment.center, child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => CircleAvatar(radius: size / 2, child: Icon(Icons.error, size: size * 0.6)),
      ),
    );
  }
}
