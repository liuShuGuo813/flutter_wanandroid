import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/data/model/user_score_model.dart';

///我的积分页面Item
class ItemUserScore extends StatefulWidget {

  final UserScoreBean item;

  const ItemUserScore(this.item);

  @override
  _ItemUserScoreState createState() {
    return _ItemUserScoreState();
  }
}

class _ItemUserScoreState extends State<ItemUserScore> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserScoreBean item = widget.item;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.reason,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      item.desc,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
              Text(
                '+${item.coinCount}',
                style: TextStyle(fontSize: 16.0, color: Colors.cyan),
              )
            ],
          ),
        ),
      ],
    );
  }
}