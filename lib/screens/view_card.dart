import 'dart:io';

import 'package:flutter/material.dart';

class ViewCard extends StatefulWidget {
  final getImg;
  const ViewCard({Key key, this.getImg}) : super(key: key);

  @override
  _ViewCardState createState() => _ViewCardState();
}

class _ViewCardState extends State<ViewCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Image.file(File(widget.getImg)),
      ),
    );
  }
}
