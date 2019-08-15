import 'package:intl/intl.dart';

String formatDate(String datetime) {
  DateFormat formatter;
  List<String> time = datetime.split(' ');
  List<String> dateForFormat = time[0].substring(0, 10).split('-');
  if (dateForFormat[1].startsWith('0') && dateForFormat[2].startsWith('0')) {
    formatter = DateFormat('MM/dd/yy');
  } else if (dateForFormat[1].startsWith('0') &&
      !dateForFormat[2].startsWith('0')) {
    formatter = DateFormat('MM/dd/yy');
  } else {
    formatter = DateFormat('MM/dd/yy');
  }
  String res = formatter
      .format(DateTime(
          int.parse(time[0].substring(0, 4)),
          int.parse(time[0].substring(5, 7)),
          int.parse(time[0].substring(8, 10))))
      .toString();
  return res + ' ' + time[1];
}
