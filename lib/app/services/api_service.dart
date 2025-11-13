import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fuba_clicker/main.dart';
import '../models/user_data.dart';
import '../models/auth_response.dart';
import '../models/ranking_entry.dart';
import '../core/utils/obfuscation.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl =
      'https://fubaclicker-srv-production.up.railway.app';
  static const Duration timeout = Duration(seconds: 60);
  static const int maxRetries = 3;

  late final Dio _dio;
  String? _jwt;
  bool _isRelogging = false;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
      },
      extra: {
        'withCredentials': kIsWeb,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final jwt = await TokenService().readMethod('jwt');

        _jwt ??= jwt;

        if (_jwt != null) {
          options.headers['Authorization'] = 'Bearer $_jwt';
        }

        if (kIsWeb) {
          options.extra['withCredentials'] = true;
        }

        debugPrint('[]>> Headers sendo enviados: ${options.headers}');

        handler.next(options);
      },
      onResponse: (response, handler) async {
        final headersLower = <String, String>{
          for (final entry in response.headers.map.entries)
            entry.key.toLowerCase(): entry.value.first,
        };
        final newToken = headersLower['authorization'] ??
            response.headers.value('x-new-token');

        if (newToken != null && newToken.isNotEmpty) {
          final token = newToken.replaceFirst('Bearer ', '').trim();
          await TokenService().writeMethod('jwt', token);
          _jwt = token;
          debugPrint('[]>> Novo JWT salvo automaticamente');
        }

        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRelogging) {
          _jwt = null;

          try {
            _isRelogging = true;
            final authService = AuthService();
            await authService.init();
            final reloginSuccess = await authService.autoRelogin();

            if (reloginSuccess) {
              final jwt = await TokenService().readMethod('jwt');
              _jwt = jwt;

              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $_jwt';

              try {
                final response = await _dio.fetch(requestOptions);
                handler.resolve(response);
                _isRelogging = false;
                return;
              } catch (e) {
                _isRelogging = false;
              }
            } else {
              _isRelogging = false;
            }
          } catch (e) {
            debugPrint('[]>> Erro ao tentar relogin automático: $e');
            _isRelogging = false;
          }
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
          } else if (response.data is String) {
            try {
              final parsedData = jsonDecode(response.data as String);
              if (parsedData is Map<String, dynamic>) {
                responseData = parsedData;
              } else {
                responseData = {'data': parsedData};
              }
            } catch (e) {
              log('[]>> Erro ao fazer parse da resposta string: $e');
              log('[]>> Resposta recebida: ${response.data}');
              responseData = {'data': response.data};
            }
          } else {
            responseData = {'data': response.data};
          }

          if (useObfuscation && responseData.containsKey('data')) {
            try {
              final dataField = responseData['data'];
              if (dataField is String && dataField.isNotEmpty) {
                final deobfuscatedData =
                    ObfuscationUtils.deobfuscate(dataField);
                return fromJson != null
                    ? fromJson(deobfuscatedData)
                    : deobfuscatedData as T;
              } else {
                log('[]>> Campo data não é uma string válida: $dataField');
                return fromJson != null
                    ? fromJson(responseData)
                    : responseData as T;
              }
            } catch (e) {
              log('[]>> Erro ao desofuscar resposta: $e');
              log('[]>> Dados recebidos: ${responseData['data']}');
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

            if (e.type == DioExceptionType.badResponse) {
              if (e.response?.data != null) {
                if (e.response!.data is Map<String, dynamic>) {
                  final errorData = e.response!.data as Map<String, dynamic>;
                  if (errorData.containsKey('message')) {
                    errorMessage = errorData['message'];
                  } else if (errorData.containsKey('error')) {
                    errorMessage = errorData['error'];
                  }
                } else if (e.response!.data is String) {
                  final responseString = e.response!.data as String;
                  if (responseString.isNotEmpty) {
                    try {
                      final errorData =
                          jsonDecode(responseString) as Map<String, dynamic>;
                      if (errorData.containsKey('message')) {
                        errorMessage = errorData['message'];
                      } else if (errorData.containsKey('error')) {
                        errorMessage = errorData['error'];
                      }
                    } catch (_) {
                      errorMessage = 'Resposta inválida do servidor';
                    }
                  }
                }
              }
            } else if (e.type == DioExceptionType.unknown) {
              final originalError = e.error;
              if (originalError is FormatException) {
                errorMessage =
                    'Erro ao processar resposta do servidor: formato inválido';
                log('[]>> Erro de parse JSON: ${originalError.message}');
                log('[]>> Resposta recebida: ${e.response?.data}');
              } else if (e.message != null &&
                  e.message!.contains('JSON Parse error')) {
                errorMessage =
                    'Erro ao processar resposta do servidor: formato inválido';
                log('[]>> Erro de parse JSON: ${e.message}');
                log('[]>> Resposta recebida: ${e.response?.data}');
              } else if (e.message != null) {
                errorMessage = e.message!;
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
    if (data.containsKey('fuba') && data['fuba'] != null) {
      data['fuba'] = data['fuba'].toString();
    }
    if (data.containsKey('achievementStats') &&
        data['achievementStats'] == null) {
      data['achievementStats'] = {};
    }
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

    return response.map((item) {
      final data = ObfuscationUtils.deobfuscate(item['data']);
      data['username'] = item['username'];
      data['profilePicture'] =
          item['profilePicture'] ?? data['profilePicture'] ?? '';
      return RankingEntry.fromJson(data);
    }).toList();
  }

  Future<List<RankingEntry>> getInscribedRanking() async {
    final response = await _makeRequest<List<dynamic>>(
      'GET',
      '/ranking/inscribed',
      useObfuscation: false,
    );

    return response.map((item) {
      final data = ObfuscationUtils.deobfuscate(item['data']);
      data['username'] = item['username'];
      data['profilePicture'] =
          item['profilePicture'] ?? data['profilePicture'] ?? '';
      return RankingEntry.fromJson(data);
    }).toList();
  }

  Future<UserData> inscribeUser() async {
    try {
      final response = await _makeRequest<Map<String, dynamic>>(
        'POST',
        '/inscribe',
        useObfuscation: true,
      );

      return UserData.fromJson(response);
    } catch (e) {
      debugPrint('[]>> inscribeUser error: $e');
      rethrow;
    }
  }
}
