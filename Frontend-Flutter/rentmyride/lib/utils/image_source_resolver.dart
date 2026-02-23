import 'dart:convert';

import 'package:flutter/material.dart';

const String kDefaultVehicleFallbackAsset =
    'assets/images/Tesla_Model_3_white_electric_car_null_1771667568328.jpg';

ImageProvider<Object>? imageProviderFromSource(String? source) {
  final value = source?.trim() ?? '';
  if (value.isEmpty) return null;

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return NetworkImage(value);
  }

  if (value.startsWith('assets/')) {
    return AssetImage(value);
  }

  if (value.startsWith('data:image/')) {
    final commaIndex = value.indexOf(',');
    if (commaIndex == -1) return null;
    try {
      final bytes = base64Decode(value.substring(commaIndex + 1));
      if (bytes.isEmpty) return null;
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  return null;
}

ImageProvider<Object> imageProviderWithFallback(
  String? source, {
  String fallbackAsset = kDefaultVehicleFallbackAsset,
}) {
  return imageProviderFromSource(source) ?? AssetImage(fallbackAsset);
}
