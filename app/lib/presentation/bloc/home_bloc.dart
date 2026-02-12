import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async{
      final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/1');
      final response = await http.get(url);
      
    });
  }
}
