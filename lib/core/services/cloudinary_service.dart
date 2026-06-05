import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/env.dart';

/// Thrown when a Cloudinary upload fails. [code] is a stable identifier the
/// caller can map to a localized message; [detail] carries the raw cause.
class CloudinaryException implements Exception {
  CloudinaryException(this.code, [this.detail]);

  final String code;
  final String? detail;

  @override
  String toString() => 'CloudinaryException($code): $detail';
}

/// Uploads bytes to Cloudinary using an **unsigned upload preset**. The API
/// secret is never present in the client — only the public cloud name and the
/// preset name (see [Env.cloudinaryCloudName] / [Env.cloudinaryUploadPreset]).
///
/// Returns the `secure_url` of the stored asset.
class CloudinaryService {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Uploads [bytes] under [folder] with the given [fileName].
  ///
  /// [resourceType] is Cloudinary's resource type: `image` for photos,
  /// `raw` for non-media files (e.g. PDFs), or `auto` to let Cloudinary infer.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    String resourceType = 'auto',
  }) async {
    if (!Env.hasCloudinary) {
      throw CloudinaryException('cloudinary_not_configured',
          'CLOUDINARY_CLOUD_NAME / CLOUDINARY_UPLOAD_PRESET are not set.');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${Env.cloudinaryCloudName}/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = Env.cloudinaryUploadPreset
      ..fields['folder'] = folder
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request);
    } catch (e) {
      throw CloudinaryException('cloudinary_network_error', e.toString());
    }

    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw CloudinaryException('cloudinary_upload_failed',
          'HTTP ${streamed.statusCode}: $body');
    }

    final secureUrl = (jsonDecode(body) as Map<String, dynamic>)['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw CloudinaryException('cloudinary_no_url', body);
    }
    return secureUrl;
  }
}
