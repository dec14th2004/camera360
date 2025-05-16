import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/use_cases/upload_image_usecase.dart';
import 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final List<Uint8List> images;
  final UploadImageUsecase uploadImageUseCase;

  LoadingCubit({required this.images, required this.uploadImageUseCase})
      : super(LoadingState(byteStream: Uint8List(0))) {
    _uploadImages();
  }

  Future<void> _uploadImages() async {
    try {
      final result = await uploadImageUseCase.call(UploadImagePanoramaUsecaseParams(images: images));

      if (result.isSuccess) {
        final byteStream = result.data.imagePanorama;
        emit(LoadingState(byteStream: byteStream));
      } else if (result.isFailure) {
        emit(LoadingState(byteStream: Uint8List(0)));
      }
    } catch (e) {
      emit(LoadingState(byteStream: Uint8List(0)));
    }
  }
}