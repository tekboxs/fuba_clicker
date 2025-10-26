import 'package:flutter/material.dart';

class AppAsyncBuilder<T> extends StatefulWidget {
  final Future<T>? future;
  final Widget Function(T data)? onData;
  final Widget Function(Object? error)? onError;
  final Widget Function()? onEmpty;
  final Widget? loadingWidget;

  const AppAsyncBuilder({
    super.key,
    this.future,
    this.onData,
    this.onError,
    this.onEmpty,
    this.loadingWidget,
  });

  @override
  State<AppAsyncBuilder<T>> createState() => _AppAsyncBuilderState<T>();
}

class _AppAsyncBuilderState<T> extends State<AppAsyncBuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (widget.onError != null) {
            return widget.onError!.call(snapshot.error);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erro: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          final resultData = snapshot.data;

          if (resultData == null) {
            return widget.onError?.call(resultData) ?? const SizedBox();
          }

          if (resultData is Map) {
            if ((resultData as Map).isEmpty) {
              return widget.onEmpty?.call() ?? const SizedBox();
            }
          }

          if (resultData is List) {
            if (resultData.isEmpty) {
              return widget.onEmpty?.call() ?? const SizedBox();
            }
          }

          return widget.onData?.call(resultData) ?? const SizedBox();
        }

        return const SizedBox();
      },
    );
  }
}
