import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/upload_image_usecase.dart';
import 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  List<Uint8List> images; // Make images mutable
  final UploadImageUsecase uploadImageUseCase;

  LoadingCubit({required this.images, required this.uploadImageUseCase})
      : super(LoadingState(byteStream: Uint8List(0)));

  // Method to update images and trigger upload
  Future<void> uploadImages(List<Uint8List> newImages) async {
    images = newImages;
    await _uploadImages();
  }

  Future<void> _uploadImages() async {
    try {
      if (images.isEmpty) {
        emit(LoadingState(byteStream: Uint8List(0)));
        return;
      }

      final result = await uploadImageUseCase.call(UploadImagePanoramaUsecaseParams(images: images));

      if (result.isSuccess) {
        final byteStream = result.data.imagePanorama;
        emit(LoadingState(byteStream: byteStream));
      } else {
        emit(LoadingState(byteStream: Uint8List(0), error: result.message));
      }
    } catch (e) {
      emit(LoadingState(byteStream: Uint8List(0), error: e.toString()));
    }
  }
}