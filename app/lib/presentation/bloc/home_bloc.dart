import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async{
      final url = Uri.parse('https://raw.githubusercontent.com/MarkusGutierrez10/json/refs/heads/main/proyecto');
      final response = await http.get(url);
      emit(HomeLoadInProgress());
      await Future.delayed(const Duration(seconds: 5));
      if(response.statusCode == 200){
        emit(HomeLoadSuccess());
      } else {
        emit(HomeLoadFailure());
      }
    });
  }
}
