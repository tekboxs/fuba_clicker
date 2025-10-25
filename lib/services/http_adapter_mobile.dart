import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureHttpAdapter(Dio dio) {
  dio.httpClientAdapter = IOHttpClientAdapter();
}
