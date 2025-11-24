import 'package:cloud_firestore/cloud_firestore.dart';

String formatFecha(Timestamp timestamp) {
  final fecha = timestamp.toDate();
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/'
      '${fecha.year}';
}
