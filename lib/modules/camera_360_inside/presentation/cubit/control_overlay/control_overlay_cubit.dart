
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'control_overlay_state.dart';
class ControlOverlayCubit extends Cubit<ControlOverlayState> {
  ControlOverlayCubit() :
        super(const ControlOverlayState(showOverlay: true));

  void toggleOverlay() {
    emit(ControlOverlayState(showOverlay: !state.showOverlay));
  }
  void showOverlay() {
    emit(const ControlOverlayState(showOverlay: true));
  }
  void hideOverlay() {
    emit(const ControlOverlayState(showOverlay: false));
  }
}


