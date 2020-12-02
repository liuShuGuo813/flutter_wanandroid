import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> with
    SingleTickerProviderStateMixin{

  AnimationController _animationController;
  Animation _animation;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 2000));
    _animation = Tween(begin: 0.0,end: 1.0).animate(_animationController);

    _animation.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false);
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: FadeTransition(
        opacity: _animation,
        child: Image.asset(
          Utils.getImgPath('flutter'),
        ),
      ),
    );
  }
}