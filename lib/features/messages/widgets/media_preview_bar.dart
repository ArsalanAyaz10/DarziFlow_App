import 'dart:io';
import 'package:flutter/material.dart';

class MediaPreviewBar extends StatelessWidget {
  final File file;
  final String mediaType;
  final VoidCallback onRemove;

  const MediaPreviewBar({
    super.key,
    required this.file,
    required this.mediaType,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: colors.surfaceContainerHighest,
      child: Row(
        children: [
          // Preview thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: mediaType == 'image'
                ? Image.file(
                    file,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      mediaType == 'video'
                          ? Icons.videocam_outlined
                          : Icons.insert_drive_file_outlined,
                      size: 28,
                      color: colors.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.path.split(Platform.pathSeparator).last,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
