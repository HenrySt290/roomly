import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/api_config.dart';

/// Image Upload Service
/// Handles image picking, compression, and uploading to server
class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  /// Returns compressed file path or null if cancelled
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1920,
    double maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      final File imageFile = File(pickedFile.path);
      
      // Compress the image
      return await compressImage(imageFile);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Compress image to reduce file size (< 500KB target)
  static Future<File?> compressImage(File imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      final File? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 75,
        minWidth: 1024,
        minHeight: 768,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        final fileSize = await compressedFile.length();
        print('Compressed image size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
        
        // If still too large, compress again with lower quality
        if (fileSize > 500 * 1024) {
          return await FlutterImageCompress.compressAndGetFile(
            compressedFile.absolute.path,
            targetPath,
            quality: 60,
            minWidth: 800,
            minHeight: 600,
            format: CompressFormat.jpeg,
          );
        }
        
        return compressedFile;
      }

      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Upload single image to server
  /// Returns image URL on success
  static Future<String?> uploadToServer({
    required File imageFile,
    required String endpoint,
    String? authToken,
    Function(double progress)? onProgress,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add auth header if token provided
      if (authToken != null && authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      
      request.headers['Accept'] = 'application/json';
      request.headers['X-App-Version'] = '1.0.0';
      request.headers['X-Platform'] = 'android';

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      );

      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Adjust based on your API response structure
        return responseData['url'] ?? 
               responseData['data']?['url'] ?? 
               responseData['image_url'];
      } else {
        print('Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images in parallel
  /// Returns list of image URLs
  static Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String endpoint,
    String? authToken,
    Function(int completed, int total)? onProgress,
  }) async {
    final List<String> uploadedUrls = [];
    int completed = 0;

    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadToServer(
        imageFile: imageFiles[i],
        endpoint: endpoint,
        authToken: authToken,
      );

      if (url != null) {
        uploadedUrls.add(url);
      }

      completed++;
      if (onProgress != null) {
        onProgress(completed, imageFiles.length);
      }
    }

    return uploadedUrls;
  }

  /// Validate image file (type and size)
  static bool validateImage(File imageFile, {
    int maxSizeMB = 5,
    List<String> allowedTypes = const ['jpg', 'jpeg', 'png', 'webp'],
  }) {
    try {
      final fileSize = imageFile.lengthSync();
      final fileName = imageFile.path.toLowerCase();
      
      // Check size
      if (fileSize > maxSizeMB * 1024 * 1024) {
        print('Image too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        return false;
      }

      // Check type
      final extension = path.extension(fileName).replaceAll('.', '');
      if (!allowedTypes.contains(extension)) {
        print('Invalid image type: $extension');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  /// Delete local temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = await tempDir.list().toList();
      
      for (final entity in files) {
        if (entity is File) {
          final fileName = entity.path.toLowerCase();
          if (fileName.contains('.jpg') || 
              fileName.contains('.jpeg') || 
              fileName.contains('.png') ||
              fileName.contains('.webp')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }
}
