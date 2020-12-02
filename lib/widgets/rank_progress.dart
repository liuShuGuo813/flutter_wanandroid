import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';

class RankProgress extends StatefulWidget {

  double end;
  double height;
  RankProgress({this.height = 50.0,this.end = 0.0});

  @override
  _RankProgressState createState() {
    return _RankProgressState();
  }
}

class _RankProgressState extends State<RankProgress> with
  TickerProviderStateMixin{

  AnimationController _animationController;
  Animation _animation;
  bool isCompleted = false;
  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    final Animation curve =
    CurvedAnimation(parent: _animationController, curve: Curves.linear);
    _animation = Tween(begin: 0.0, end: widget.end).animate(curve)
    //添加了状态监听
      ..addStatusListener((state) {
        //当动画结束时执行动画反转
        if (state == AnimationStatus.completed) {
          setState(() {
            isCompleted = true;
          });
          //当动画在开始处停止再次从头开始执行动画
        } else if (state == AnimationStatus.dismissed) {

        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color setProgressColor(){
    if(ThemeUtils.dark){
      return Colors.grey[700];
    }else{
      return Color.fromARGB(255, 228, 228, 228);
    }
  }


  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
    child: AnimatedBuilder(animation: _animationController, builder: (context,child){
      return LinearProgressIndicator(
        backgroundColor: ThemeUtils.dark ?  Colors.grey[800] : Color.fromARGB(255, 241, 241, 241),
        valueColor: new AlwaysStoppedAnimation<Color>(
            setProgressColor()
        ),
//        value: isCompleted ? widget.end : _animation.value,
        value: _animation.value,
      );
    }),
    );
  }
}