import 'package:flutter/material.dart';

class LikeButtonWidget extends StatefulWidget {

  bool isLike = false;
  Function onClick;

  LikeButtonWidget({this.isLike, this.onClick});

  @override
  _LikeButtonWidgetState createState() {
    return _LikeButtonWidgetState();
  }
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> with
  TickerProviderStateMixin{

  AnimationController _animationController;
  Animation _animation;
  double size = 24.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 150));
    _animation = Tween(begin: size,end: size * 0.5).animate(_animationController);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: LikeAnimation(
        animation: _animation,
        animationController: _animationController,
        isLike: widget.isLike,
        onClick: widget.onClick,
      ),
    );
  }
}

class LikeAnimation extends AnimatedWidget implements StatefulWidget {
  AnimationController animationController;
  Animation animation;
  bool isLike = false;
  Function onClick;


  LikeAnimation(
    {this.animationController, this.animation, this.isLike, this.onClick})
      : super(listenable: animationController);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        isLike ? Icons.favorite : Icons.favorite_border,
        size: animation.value,
        color: isLike ? Colors.red : Colors.grey[600],
      ),
      onTapUp: (drawDownDetail){
        Future.delayed(Duration(milliseconds: 100),(){
          animationController.reverse();
          onClick();
        });
      },
      onTapDown: (drawDownDetail){
        animationController.forward();
      },
    );
  }
  
}