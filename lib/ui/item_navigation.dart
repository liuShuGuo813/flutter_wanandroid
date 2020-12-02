import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/data/model/knowledge_tree_model.dart';
import 'package:flutter_wanandroid/data/model/navigation_model.dart';
import 'package:flutter_wanandroid/ui/knowledge_detail_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';

class ItemNavigation extends StatefulWidget {
  final NavigationBean item;

  const ItemNavigation(this.item);

  @override
  _ItemNavigationState createState() {
    return _ItemNavigationState();
  }
}

class _ItemNavigationState extends State<ItemNavigation> {
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
    NavigationBean item = widget.item;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              item.name,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            child: itemChildrenView(item.articles),
          )
        ],
      ),
    );
  }

  Widget itemChildrenView(List<NavigationArticleBean> list) {
    List<Widget> titles = [];
    for (var i = 0; i < list.length; i++) {
      var value = list[i];
      titles.add(
        FlatButton(
          child: Text(value.title,style: TextStyle(fontSize: 12.0),),
            color: ThemeUtils.dark ? ThemeUtils.getThemeData().primaryColor : Color.fromARGB(255, 235, 235, 235),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            onPressed: () {
              RouteUtil.toWebView(context, value.link, value.title);
            }),
      );
    }

    return Wrap(
      spacing: 5,
      alignment: WrapAlignment.start,
      children: titles,
    );
  }
}
