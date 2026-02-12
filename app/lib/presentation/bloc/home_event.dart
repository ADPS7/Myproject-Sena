part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeSearchPressed extends HomeEvent{}
