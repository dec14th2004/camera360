import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stop_notify_state.dart';

class StopNotifyCubit extends Cubit<StopNotifyState> {
  StopNotifyCubit() : super(StopNotifyInitial());

  void selectRetry() {
    emit(const StopNotifyActionSelected('Retry'));
  }

  void selectComplete() {
    emit(const StopNotifyActionSelected('Complete'));
  }
}