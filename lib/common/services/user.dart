import 'package:rxdart/rxdart.dart';

class UserBloc {
  final _userSequence = ReplaySubject<String>();

  Observable<String> get userUid => _userSequence.stream;

  setUserUid(String userUid) async {
    _userSequence.add(userUid);
  }

  dispose() {
    _userSequence.close();
  }
}

final userBlock = UserBloc();