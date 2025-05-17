import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class LoadingState extends Equatable {
  final Uint8List byteStream;
  final String? error;

  const LoadingState({required this.byteStream, this.error});

    LoadingState copyWith({Uint8List? byteStream}) {
    return LoadingState(
      byteStream: byteStream ?? this.byteStream,
      error: error ?? error,
    );
  }

  @override
  List<Object?> get props => [byteStream, error];
}