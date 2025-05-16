import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class LoadingState extends Equatable {
  final Uint8List byteStream;

  const LoadingState({required this.byteStream});

  @override
  List<Object?> get props => [byteStream];

  @override
  bool? get stringify => true;

  LoadingState copyWith({Uint8List? byteStream}) {
    return LoadingState(
      byteStream: byteStream ?? this.byteStream,
    );
  }
}