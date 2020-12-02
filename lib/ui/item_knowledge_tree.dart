import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/data/model/knowledge_tree_model.dart';
import 'package:flutter_wanandroid/ui/knowledge_detail_screen.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';

class ItemKnowledgeTree extends StatefulWidget {
  final KnowledgeTreeBean item;

  const ItemKnowledgeTree(this.item);

  @override
  _ItemKnowledgeTreeState createState() {
    return _ItemKnowledgeTreeState();
  }
}

class _ItemKnowledgeTreeState extends State<ItemKnowledgeTree> {
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
    KnowledgeTreeBean item = widget.item;
    return InkWell(
      onTap: () {
        RouteUtil.push(context, KnowledgeDetailScreen(item));
      },
      child: Container(
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
              child: itemChildrenView(item, item.children),
            )
          ],
        ),
      ),
    );
  }

  Widget itemChildrenView(
      KnowledgeTreeBean item, List<KnowledgeTreeChildBean> list) {
    List<Widget> titles = [];
    for (var i = 0; i < list.length; i++) {
      var value = list[i];
      value.setIndex(i);
      titles.add(
        FlatButton(
          child: Text(value.name,style: TextStyle(fontSize: 12.0),),
            color: ThemeUtils.dark ? ThemeUtils.getThemeData().primaryColor : Color.fromARGB(255, 235, 235, 235),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            onPressed: () {
              RouteUtil.push(
                  context,
                  KnowledgeDetailScreen(
                    item,
                    index: value.index,
                  ));
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
