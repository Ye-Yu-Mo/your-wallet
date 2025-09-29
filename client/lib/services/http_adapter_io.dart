import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureDioAdapter(Dio dio) {
  final adapter = dio.httpClientAdapter;
  if (adapter is IOHttpClientAdapter) {
    adapter.createHttpClient = () {
      final client = HttpClient();
      // Force direct connection (no proxy), helpful when system has a global proxy.
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
  }
}

