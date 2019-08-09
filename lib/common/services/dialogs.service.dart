import 'package:rxdart/rxdart.dart';

class DialogsService {
  final _dialogSequence = BehaviorSubject<bool>.seeded(false);
  
  setDialogState(bool dialogState) async {
    _dialogSequence.add(dialogState);
  }

  Observable<bool> get dialogState => _dialogSequence.stream;

  dispose() {
    _dialogSequence.close();
  }
}

final dialogsBlock = DialogsService();
