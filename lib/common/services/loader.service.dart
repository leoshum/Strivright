import 'package:rxdart/rxdart.dart';

class Loading {
  final _loaderSequence = BehaviorSubject<bool>.seeded(false);
  Observable<bool> get isLoading => _loaderSequence.stream;

  setLoaderState(bool isLoading) async {
    _loaderSequence.add(isLoading);
  }
  dispose() {
    _loaderSequence.close();
  }
}

final loaderBlock = Loading();
