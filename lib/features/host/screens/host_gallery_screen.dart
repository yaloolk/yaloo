// lib/features/host/screens/host_gallery_screen.dart
// ✅ FIXED - Works with HostProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';

class HostGalleryScreen extends StatefulWidget {
  const HostGalleryScreen({super.key});

  @override
  State<HostGalleryScreen> createState() => _HostGalleryScreenState();
}

class _HostGalleryScreenState extends State<HostGalleryScreen> {
  bool _isUploading = false;
  final Set<String> _deleting = {};
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final provider = context.read<HostProvider>();

      // Upload photos one by one (you'll need to implement this in provider)
      for (final file in files) {
        // TODO: Add uploadGalleryPhoto method to HostProvider
        // await provider.uploadGalleryPhoto(file);
      }

      if (mounted) {
        await context.read<HostProvider>().loadProfile(forceRefresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} photo(s) uploaded'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    setState(() => _deleting.add(photoId));

    try {
      // TODO: Add deleteGalleryPhoto method to HostProvider
      // final provider = context.read<HostProvider>();
      // await provider.deleteGalleryPhoto(photoId);

      if (mounted) {
        await context.read<HostProvider>().loadProfile(forceRefresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting.remove(photoId));
    }
  }

  void _confirmDelete(String photoId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(photoId);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Gallery',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(14.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_photo_alternate, color: Colors.blue),
              onPressed: _uploadPhotos,
            ),
        ],
      ),
      body: Consumer<HostProvider>(
        builder: (context, provider, _) {
          // Note: You'll need to add a 'gallery' getter to HostProvider
          // that returns List<Map<String, dynamic>> from profile
          final gallery = <Map<String, dynamic>>[]; // TODO: Get from provider

          if (gallery.isEmpty) {
            return _buildEmpty();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gallery.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddTile();
                final photo = gallery[index - 1];
                return _buildPhotoTile(photo);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhotos,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAddTile() {
    return GestureDetector(
      onTap: _uploadPhotos,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 24, color: Colors.blue),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(Map<String, dynamic> photo) {
    final id = photo['id'] as String;
    final url = photo['url'] as String;
    final isDeleting = _deleting.contains(id);

    return GestureDetector(
      onLongPress: () => _confirmDelete(id),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[100],
                child: Icon(Icons.broken_image, color: Colors.grey[300]),
              ),
            ),
          ),
          if (isDeleting)
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _confirmDelete(id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add photos to showcase your place',
            style: TextStyle(color: Colors.grey[300], fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadPhotos,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}