import 'dart:ui' as Ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:Server/misc.dart';

class Board {
  Ui.Image image;
  List<Offset> points = [];
  bool baking = false;
  final Size curSize = Ui.Size(4000, 4000);

  void applyUpdate(Data data) {
    addPoint(Ui.Offset(data['dx'], data['dy']));
  }

  void addPoint(Offset offset) async {
    points.add(offset);

    if (points.length > 50 && !baking) {
      baking = true;
      var recorder = Ui.PictureRecorder();
      var canvas = Ui.Canvas(recorder);
      var numPoints = points.length;
      BoardPainter(image, points).paint(canvas, curSize);
      var picture = recorder.endRecording();
      var newImage = await picture.toImage(
        curSize.width.ceil(),
        curSize.height.ceil(),
      );
      if (baking) {
        image = newImage;
        points.removeRange(0, numPoints);
        baking = false;
      }
    }
  }

  Future<Data> export() async {
    Data data = Data();
    List<double> x = List();
    List<double> y = List();
    for (var i in points) {
      x.add(i.dx);
      y.add(i.dy);
    }
    data['pointsX'] = x;
    data['pointsY'] = y;
    if (image != null) {
      data['image'] = (await image.toByteData(format: Ui.ImageByteFormat.png))
          .buffer
          .asUint8List();
    }
    return data;
  }
}

class BoardPainter extends CustomPainter {
  final Ui.Image image;
  final List<Offset> points;

  BoardPainter(this.image, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint(),
      );
    }
    double dotSize = 8;
    if (size.height < size.width) {
      dotSize *= size.height;
    } else {
      dotSize *= size.width;
    }
    dotSize /= 1000;
    for (var i in points) {
      var temp = Offset(i.dx * size.width, i.dy * size.height);
      canvas.drawCircle(temp, dotSize, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(BoardPainter old) => true;
}
