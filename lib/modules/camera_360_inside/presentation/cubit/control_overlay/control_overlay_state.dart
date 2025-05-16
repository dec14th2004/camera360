part of 'control_overlay_cubit.dart';

class ControlOverlayState extends Equatable {
  final bool showOverlay;
  const ControlOverlayState({required this.showOverlay});
  @override
  List<Object?> get props => [showOverlay];
}