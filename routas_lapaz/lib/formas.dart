import 'package:flutter/material.dart';

class PeatonCustomPainter extends CustomPainter {
  Color color;
  double x, y;

  PeatonCustomPainter(this.color,this.x,this.y);
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Path m=new Path();

    canvas.translate(-x, -y);
    double w = size.width;
    double h = size.height;
    m.moveTo(x+2.05*w/4, y+1.65*h/8);

    m.lineTo(x+3.28*w/4, y+2.6*h/8);
    m.lineTo(x+3.3*w/4, y+4.3*h/8);
    m.cubicTo(x+3.3*w/4, y+4.4*h/8,x+3.15*w/4, y+4.8*h/8, x+3*w/4, y+4.3*h/8);
    m.lineTo(x+3.0*w/4, y+3.05*w/8);
    m.lineTo(x+2.5*w/4,y+2.7*h/8);

    m.lineTo(x+2.85*w/4, y+4.6*h/8);
    m.lineTo(x+3.43*w/4, y+8.5*h/8);
    m.cubicTo(x+3.44*w/4, y+8.6*h/8, x+3.3*w/4, y+9.5*h/8, x+3*w/4, y+8.75*h/8);
    m.lineTo(x+2.53*w/4, y+5.5*h/8);
    m.lineTo(x+2.4*w/4, y+5.38*h/8);
    m.lineTo(x+1.95*w/4, y+6.65*h/8);
    m.lineTo(x+1.73*w/4, y+8.62*h/8);
    m.cubicTo(x+1.73*w/4, y+8.62*h/8, x+1.4*w/4, y+9.1*h/8, x+1.3*w/4, y+8.4*h/8);
    m.lineTo(x+1.55*w/4, y+6.24*h/8);
    m.lineTo(x+2.05*w/4, y+4.8*h/8);
    m.lineTo(x+1.73*w/4, y+3.21*h/8);
    m.lineTo(x+1.53*w/4, y+4.1*h/8);
    m.lineTo(x+0.8*w/4, y+4.67*h/8);
    m.cubicTo(x+0.8*w/4, y+4.67*h/8, x+0.5*w/4, y+4.55*h/8, x+0.7*w/4, y+4.05*h/8);
    m.lineTo(x+1.33*w/4, y+3.5*h/8);
    m.lineTo(x+1.67*w/4, y+2*h/8);
    m.cubicTo(x+1.67*w/4, y+2*h/8, x+1.75*w/4, y+1.66*h/8, x+2.05*w/4, y+1.65*h/8);


    
    
    
  paint.color=color;
    canvas.drawPath(m, paint);
    canvas.drawCircle(Offset(x + 1.65*w/4, y + 0.95 * h / 9), w/10.5, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PeatonIcono extends StatelessWidget {
  final double size;
  final Color color;
  double x, y;  
  PeatonIcono({this.size = 48.0,required this.color,required this.x,required this.y});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: PeatonCustomPainter(color,x,y),
    );
  }
}


class AutoCustomPainter extends CustomPainter {
  final Color color;
  double x,y;
  AutoCustomPainter(this.color,this.x,this.y);

  @override
  void paint(Canvas canvas, Size size) {
        final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double w = size.width/6;
    double h = size.height/6;

    // Cuerpo del auto
    //final Rect body = Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.8, h * 0.3);
    //final RRect roundedBody = RRect.fromRectAndRadius(body, Radius.circular(10));
    //canvas.drawRRect(roundedBody, paint);
    canvas.translate(-x+25, -y+20);
   
    // Cabina
    final Path cabina = Path();
    cabina.moveTo(-x-3.2*w/8, -y-17.2*h/8);
    cabina.lineTo(x+12.5*w/8,-y-17.2*h /8);
    cabina.cubicTo(x+12.5*w/8,-y-17.2*h /8,x+15*w/8,-y-18*h/8,x+16.5*w/8,-y-14.15*h /8);
    cabina.lineTo(x+19.4*w/8,-y-7*h /8);
    cabina.cubicTo(x+19.2*w/8,-y-7*h /8, x+22.4*w/8, -y-7*h/8, x+23*w/8, -y-3.2*h/8);
    cabina.lineTo(x+23*w/8, y+6.5*h/8);
    cabina.lineTo(x+19.8*w/8, y+6.5*h/8);
    cabina.lineTo(x+19.8*w/8, y+11*h/8);
    cabina.cubicTo(x+19.8*w/8, y+11*h/8, x+17.8*w/8, y+14.3*h/8,x+14.55*w/8, y+11*h/8);
    cabina.lineTo(x+14.55*w/8, y+6.8*h/8);
    cabina.lineTo(-x-4.8*w/8, y+6.8*h/8);
    cabina.lineTo(-x-4.8*w/8, y+11*h/8);
    cabina.cubicTo(-x-4.8*w/8, y+11*h/8, -x-7.5*w/8, y+14.3*h/8,-x-10.2*w/8, y+11*h/8);
    cabina.lineTo(-x-10.2*w/8, y+7*h/8);
    cabina.lineTo(-x-13.2*w/8, y+7*h/8);
    cabina.lineTo(-x-13.2*w/8, y-2.5*h/8);
    cabina.cubicTo(-x-13.2*w/8, y-2.5*h/8, -x-14.1*w/8, y-6*h/8, -x-9.9*w/8, y-6.9*h/8);
    cabina.lineTo(-x-7.3*w/8, y-13.9*h/8);
    cabina.cubicTo(-x-7.3*w/8, y-13.9*h/8, -x-7*w/8, -y-16.5*h/8, -x-3.2*w/8, -y-17.2*h/8);
    cabina.close();

    canvas.drawPath(cabina, paint);
    final Paint paint2 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final Path ventana=Path();
    ventana.moveTo(-x-3.9*w/8,-y-14*h/8);
    ventana.lineTo(-x+13.5*w/8,-y-14*h/8);
    ventana.lineTo(-x+16.3*w/8,-y-7.4*h/8);
    ventana.lineTo(-x-6.5*w/8,-y-7*h/8);

    ventana.close();
    canvas.drawPath(ventana, paint2);
    canvas.drawCircle(Offset(x - 3.75*w/4, y - 1.8 * h / 9), w/3.5, paint2);
    canvas.drawCircle(Offset(x + 8.6*w/4, y - 1.8 * h / 9), w/3.5, paint2);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AutoIcono extends StatelessWidget {
  final double size;
  final Color color;
  final double x,y;
  const AutoIcono({super.key, this.size = 100.0, required this.color, required this.x,required this.y});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: AutoCustomPainter(color,x,y),
    );
  }
}
