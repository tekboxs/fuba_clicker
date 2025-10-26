import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuba_clicker/main.dart';
import '../models/user_data.dart';
import '../models/auth_response.dart';
import '../models/ranking_entry.dart';
import '../core/utils/obfuscation.dart';

class ApiService {
  static const String baseUrl =
      'https://fubaclicker-srv-production.up.railway.app';
  static const Duration timeout = Duration(seconds: 60);
  static const int maxRetries = 3;

  late final Dio _dio;
  String? _jwt;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));


    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final jwt = await TokenService().readMethod('jwt');

        _jwt ??= jwt;

        if (_jwt != null) {
          options.headers['Authorization'] = 'Bearer $_jwt';
        }

        // if (_rt != null) {
        //   options.headers['refresh_token'] = '$_rt';
        // }

        // Debug: verificar headers sendo enviados
        debugPrint('[]>> Headers sendo enviados: ${options.headers}');

        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _jwt = null;
        }
        handler.next(error);
      },
    ));
  }

  void setJwt(String? jwt) {
    _jwt = jwt;
  }

  void setRefreshToken(String? rt) {
    debugPrint('[]>> Refresh token definido: ${rt != null ? "SIM" : "NÃO"}');
  }

  Future<T> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    bool useObfuscation = false,
  }) async {
    int retries = 0;

    while (retries < maxRetries) {
      try {
        Response response;
        Map<String, dynamic>? requestData = body;

        if (useObfuscation && body != null) {
          requestData = {'data': ObfuscationUtils.obfuscate(body)};
          log("[]>> requestData: 	${requestData.toString()}");
        }

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _dio.get(endpoint);
            break;
          case 'POST':
            response = await _dio.post(endpoint, data: requestData);
            break;
          case 'PUT':
            response = await _dio.put(endpoint, data: requestData);
            break;
          default:
            throw Exception('Método HTTP não suportado: $method');
        }

        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          if (response.data == null) {
            return fromJson != null ? fromJson({}) : {} as T;
          }

          Map<String, dynamic> responseData;

          if (response.data is Map<String, dynamic>) {
            responseData = response.data as Map<String, dynamic>;
          } else if (response.data is List) {
            return response.data as T;
          } else {
            responseData = {'data': response.data};
          }

          if (useObfuscation && responseData.containsKey('data')) {
            try {
              final deobfuscatedData =
                  ObfuscationUtils.deobfuscate(responseData['data']);
              return fromJson != null
                  ? fromJson(deobfuscatedData)
                  : deobfuscatedData as T;
            } catch (e) {
              return fromJson != null
                  ? fromJson(responseData)
                  : responseData as T;
            }
          }

          return fromJson != null ? fromJson(responseData) : responseData as T;
        } else {
          String errorMessage = 'Erro HTTP ${response.statusCode}';
          if (response.data is Map<String, dynamic>) {
            final errorData = response.data as Map<String, dynamic>;
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('error')) {
              errorMessage = errorData['error'];
            }
          }
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: errorMessage,
          );
        }
      } catch (e) {
        retries++;
        if (retries >= maxRetries || e is DioException) {
          if (e is DioException) {
            String errorMessage = 'Erro de conexão';
            if (e.response?.data is Map<String, dynamic>) {
              final errorData = e.response!.data as Map<String, dynamic>;
              if (errorData.containsKey('message')) {
                errorMessage = errorData['message'];
              } else if (errorData.containsKey('error')) {
                errorMessage = errorData['error'];
              }
            } else if (e.message != null) {
              errorMessage = e.message!;
            }
            throw Exception(errorMessage);
          }
          rethrow;
        }
        await Future.delayed(Duration(seconds: retries));
      }
    }

    throw Exception('Falha após $maxRetries tentativas');
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      // useObfuscation: true,
    );

    final authResponse = AuthResponse.fromJson(response);

    if (authResponse.rt != null) {
      setRefreshToken(authResponse.rt);
    }

    return authResponse;
  }

  Future<void> register(String email, String username, String password) async {
    await _makeRequest(
      'POST',
      '/auth/register',
      body: {
        'email': email,
        'username': username,
        'password': password,
      },
    );
  }

  Future<UserData> getUserData() async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'GET',
        '/user/',
        useObfuscation: true,
      );

      return UserData.fromJson(response);
    } catch (e) {
      debugPrint('[]>> getUserData error: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    data['fuba'] = data['fuba'].toString();
    await _makeRequest(
      'PUT',
      '/user/',
      body: data,
      useObfuscation: true,
    );
  }

  Future<List<RankingEntry>> getRanking() async {
    final response = await _makeRequest<List<dynamic>>(
      'GET',
      '/ranking/',
      useObfuscation: false,
    );

    return response.map((item) => RankingEntry.fromJson(item)).toList();
  }
}
