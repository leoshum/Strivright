import 'package:rxdart/rxdart.dart';

class UserBloc {
  final _userSequence = ReplaySubject<dynamic>(maxSize: 1);

  Observable<dynamic> get user => _userSequence.stream;

  setUserUid(dynamic user) async {
    _userSequence.add(user);
  }

  dispose() {
    _userSequence.close();
  }
}

final userBlock = UserBloc();
