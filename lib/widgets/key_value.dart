import 'package:flutter/material.dart';

Widget KeyValueWidget(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(k, style: const TextStyle(color: Colors.black87)),
        ),
        // const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
