import 'package:dio/dio.dart';
import 'http_adapter_web.dart' if (dart.library.io) 'http_adapter_mobile.dart' as adapter;

void configureHttpAdapter(Dio dio) {
  adapter.configureHttpAdapter(dio);
}
