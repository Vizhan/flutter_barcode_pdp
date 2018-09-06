import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class AnimApp extends StatefulWidget {
  @override
  AnimState createState() => AnimState();
}

class AnimState extends State<AnimApp> with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return LogoAnimation(
      animation: animation,
    );
//    return Center(
//      child: Container(
//        height: animation.value,
//        width: animation.value,
//        child: FlutterLogo(),
//      ),
//    );
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1000.0).animate(animationController);
//      ..addListener(() {
//        setState(() {});
//      });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class LogoAnimation extends AnimatedWidget {
  LogoAnimation({Key key, Animation animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation animation = listenable;
    return Center(
      child: Container(
        height: animation.value,
        width: animation.value,
        child: FlutterLogo(),
      ),
    );
  }
}
