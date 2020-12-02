import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/history_model.dart';
import 'package:flutter_wanandroid/data/model/hot_word_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/common_util.dart';
import 'package:flutter_wanandroid/utils/db_util.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/utils/utils.dart';

import 'hot_Result_screen.dart';

///搜索页面
class SearchScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends BaseWidgetState<SearchScreen> {
  TextEditingController _editingController;
  FocusNode _editingFocusNode = FocusNode(); //控制输入框焦点
  List<Widget> actions = List(); //输入框右侧组件
  String keyWord = ""; //输入内容
  List<HotWordBean> _hotWordList = List();

  var db = DatabaseUtil();
  List<HistoryBean> _historyList = List();

  @override
  void initState() {
    super.initState();
    setAppBarVisible(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showLoading();
    getSearchHotList();
    getHistoryList();

    _editingController = TextEditingController(text: keyWord);
    _editingController.addListener(() {
      if (_editingController.text == null || _editingController.text == "") {
        setState(() {
          actions = [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  textChanged();
                })
          ];
        });
      } else {
        setState(() {
          actions = [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _editingController.clear();
                  textChanged();
                }),
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  textChanged();
                })
          ];
        });
      }
    });
  }

  void textChanged() {
    _editingFocusNode.unfocus();
    if (_editingController.text == null || _editingController.text == "") {
    } else {
      saveHistory(_editingController.text).then((value) {
        RouteUtil.push(context, HotResultScreen(_editingController.text));
      });
    }
  }

  /// 保存搜索记录
  Future saveHistory(String text) async {
    int _id = -1;
    _historyList.forEach((bean) {
      if (bean.name == text) _id = bean.id;
    });
    if (_id != -1) await db.deleteById(_id);
    HistoryBean bean = HistoryBean();
    bean.name = text;
    await db.insertItem(bean);
    await getHistoryList();
  }

  /// 获取历史搜索记录
  Future getHistoryList() async {
    var list = await db.queryList();
    setState(() {
      _historyList.clear();
      _historyList.addAll(HistoryBean.fromMapList(list));
    });
    print(list.toString());
  }

  /// 获取搜索热词
  Future getSearchHotList() async {
    apiService.getSearchHotList((HotWordModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        showContent();
        setState(() {
          _hotWordList.clear();
          _hotWordList.addAll(model.data);
        });
      } else {
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      showError();
    });
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      elevation: 0.4,
      title: TextField(
        focusNode: _editingFocusNode,
        controller: _editingController,
        autofocus: false,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: "请输入关键词",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none),
      ),
      actions: actions,
    );
  }

  @override
  attachContentWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        //触摸内容区域收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: contentView(_hotWordList),
      ),
    );
  }

  Widget contentView(List<HotWordBean> list) {
    List<Widget> widgets = List();
    for (var item in _hotWordList) {
      widgets.add(
          FlatButton(
              child: Text(item.name,style: TextStyle(fontSize: 12.0),),
              color: ThemeUtils.dark ? ThemeUtils.getThemeData().primaryColor : Color.fromARGB(255, 235, 235, 235),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              onPressed: () {
                saveHistory(item.name).then((value) {
                  RouteUtil.push(context, HotResultScreen(item.name));
                });
              })
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            "热门搜索",
            style: TextStyle(fontSize: 16.0, color: Colors.cyan),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 1,
            alignment: WrapAlignment.start,
            children: widgets,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            "历史搜索",
            style: TextStyle(fontSize: 16.0, color: Colors.cyan),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          itemBuilder: itemHistoryView,
          itemCount: _historyList.length,
          physics: AlwaysScrollableScrollPhysics(),
        )
      ],
    );
  }

  Widget itemHistoryView(BuildContext context, int index) {
    var item = _historyList[index];
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10,bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  onTap: (){
                    RouteUtil.push(context, HotResultScreen(item.name));
                  },
                ),
              ),
              InkWell(
                child: Icon(
                  Icons.clear,
                  color: Colors.grey[600],
                  size: 16,
                ),
                onTap: (){
                  db.deleteById(item.id);
                  setState(() {
                    _historyList.removeAt(index);
                  });
                },
              )
            ],
          ),
        ),
        Divider(
          height: 1,
        )
      ],
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading();
    getSearchHotList();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
