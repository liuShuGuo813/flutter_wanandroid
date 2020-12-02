import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/utils/theme_util.dart';

class LoadingDialog extends StatefulWidget {
  String loadingText;
  bool outSizeDismiss;

  Function dismissDialog;


  LoadingDialog({this.loadingText = "loading...", this.outSizeDismiss = true, this.dismissDialog});

  @override
  _LoadingDialogState createState() {
    return _LoadingDialogState();
  }
}

class _LoadingDialogState extends State<LoadingDialog> {

  _dismissDialog(){
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if(widget.dismissDialog != null){
      widget.dismissDialog((){
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.outSizeDismiss ? _dismissDialog() : null,
      child: Material(
        type: MaterialType.transparency, //背景透明
        child: Center(
          child: SizedBox(
            width: 120.0,
            height: 120.0,
            child: Container(
              decoration: ShapeDecoration(
                  color: ThemeUtils.dark ? Color(0xba000000) : Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(8.0)
                      )
                  )
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(),
                  new Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      widget.loadingText,
                      style: TextStyle(
                          fontSize: 12.0
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}