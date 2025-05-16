part of 'stop_notify_cubit.dart';

abstract class StopNotifyState extends Equatable {
  const StopNotifyState();

  @override
  List<Object?> get props => [];
}

class StopNotifyInitial extends StopNotifyState {}

class StopNotifyActionSelected extends StopNotifyState {
  final String action;

  const StopNotifyActionSelected(this.action);

  @override
  List<Object?> get props => [action];
}