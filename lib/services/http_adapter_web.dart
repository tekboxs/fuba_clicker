import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

void configureHttpAdapter(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
