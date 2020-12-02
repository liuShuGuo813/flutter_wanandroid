import 'package:flutter/material.dart';

///通用的widget
abstract class BaseWidget extends StatefulWidget {
  BaseWidgetState baseWidgetState;
  @override
  BaseWidgetState createState() {
    baseWidgetState = attachState();
    return baseWidgetState;
  }

  BaseWidgetState attachState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends State<T>
  with AutomaticKeepAliveClientMixin{

  //导航栏是否显示
  bool _isAppBarShow = true;

  //错误页面
  bool _isErrorWidgetShow = false;
  String _errorMsg = '网络连接失败,请检查您的网络';
  String _errorImgPath = 'assets/images/ic_error.png';

  //空白页面
  bool _isEmptyWidgetShow = false;
  String _emptyMsg = '暂无数据';
  String _emptyImgPath = 'assets/images/ic_empty.png';

  //内容页面
  bool _isShowContent = false;

  //加载框
  bool _isLoadingWidgetShow = false;

  //错误页面和空页面显示的字体粗度
  FontWeight _fontWeight = FontWeight.w600;

  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _attachBaseAppBar(),
      body: Container(
          child: Stack(
            children: <Widget>[
              _attachBaseContentWidget(context),
              _attachBaseErrorWidget(),
              _attachBaseEmptyWidget(),
              _attachBaseLoadingWidget(),
            ],
          ),
      ),
      floatingActionButton: fabWidget(),
    );
  }

  @override
  bool get wantKeepAlive => true;

  ///导航栏 AppBar
  AppBar attachAppBar(){

  }

  PreferredSizeWidget _attachBaseAppBar(){
    return PreferredSize(
        child: Offstage(
          offstage: !_isAppBarShow,
          child: attachAppBar(),
        ),
        preferredSize: Size.fromHeight(56)
    );
  }

  ///内容视图
  Widget _attachBaseContentWidget(BuildContext context) {
    return Offstage(
      offstage: !_isShowContent,
      child: attachContentWidget(context),
    );
  }
  ///子类重写内容组件
  attachContentWidget(BuildContext context);

  //错误视图
  Widget _attachBaseErrorWidget() {
    return Offstage(
      offstage: !_isErrorWidgetShow,
      child: attachErrorWidget(),
    );
  }

  ///暴露出来的错误视图,子类可重写处理
  Widget attachErrorWidget(){
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,80),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(_errorImgPath,width: 120,height: 120,),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                _errorMsg,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: _fontWeight,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OutlineButton(
                  child: Text(
                    _errorMsg,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: _fontWeight,
                    ),
                  ),
                  onPressed: () => onClickErrorWidget()
              ),
            )
          ],
        ),
      ),
    );
  }

  ///错误视图点击重新加载
  void onClickErrorWidget();

  ///空数据视图
  Widget _attachBaseEmptyWidget() {
    return Offstage(
      offstage: !_isEmptyWidgetShow,
      child: attachEmptyWidget(),
    );
  }

  ///暴露出来的空内容视图,子类可重写处理
  Widget attachEmptyWidget(){
    return Container(
      padding: EdgeInsets.fromLTRB(0,0,0,100),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage(_errorImgPath),
              width: 150,
              height: 150,
              color: Colors.black12,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(
                _emptyMsg,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: _fontWeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///加载框视图
  Widget _attachBaseLoadingWidget() {
    return Offstage(
      offstage: !_isLoadingWidgetShow,
      child: attachLoadingWidget(),
    );
  }

  ///暴露出来的加载框视图,子类可重写处理
  Widget attachLoadingWidget(){
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }

  ///悬浮按钮
  Widget fabWidget() {
    return null;
  }

  /// 设置错误提示信息
  Future setErrorContent(String content) async {
    if (content != null) {
      setState(() {
        _errorMsg = content;
      });
    }
  }

  /// 设置空页面信息
  Future setEmptyContent(String content) async {
    if (content != null) {
      setState(() {
        _errorMsg = content;
      });
    }
  }

  /// 设置错误页面图片
  Future setErrorImg(String imgPath) async {
    if (imgPath != null) {
      setState(() {
        _errorImgPath = imgPath;
      });
    }
  }

  /// 设置空页面图片
  Future setEmptyImg(String imgPath) async {
    if (imgPath != null) {
      setState(() {
        _emptyImgPath = imgPath;
      });
    }
  }

  /// 设置导航栏显示或者隐藏
  setAppBarVisible(bool visible) async {
    setState(() {
      _isAppBarShow = visible;
    });
  }

  /// 显示展示的内容
  Future showContent() async {
    setState(() {
      _isShowContent = true;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示正在加载
  Future showLoading() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = true;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示空数据页面
  Future showEmpty() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = true;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示错误页面
  Future showError() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = true;
    });
  }


}