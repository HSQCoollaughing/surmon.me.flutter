import 'dart:async';
import 'package:flutter/material.dart';

import 'package:surmon/common/list_view_item.dart';
import 'package:surmon/components/list_refresh.dart' as listComp;
import 'package:surmon/components/pagination.dart';
import 'package:surmon/components/archive-iem.dart';
import 'package:surmon/components/disclaimer_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/net_utils.dart';

GlobalKey<DisclaimerMsgState> key;

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  save(bool flag) async{
    //print('=============save=========$flag');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('disclaimer', flag.toString());
  }

  Future<String> get() async {
    var value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    value = prefs.getString('disclaimer');
    return value;
  }

  @override
  void initState() {
    super.initState();
    if(key == null) {
      //print('=============111=========${key}');
      delayed();
    }
    key = GlobalKey<DisclaimerMsgState>();

  }

  /*
  * 判断是否需要弹出免责声明,已经勾选过不在显示,就不会主动弹
  * */
  Future delayed() async {
    await new Future.delayed(const Duration(seconds: 1));
//    if (this.mounted) {
//      setState(() {
//        print('test=======>${key.currentState}');
//        key.currentState.showAlertDialog(context);
//        //key.currentState.init(context);
//      });
//    }
    Future<String> flag = get();
    flag.then((String value) {
      //print('=============get=========$value');
      if(value.toString() == 'false'){ // 如果没有勾选下次开启
        key.currentState.showAlertDialog(context);
      }
    });
  }

  Future<Map> getIndexListData([Map<String, dynamic> params]) async {
    const juejin_flutter = 'https://api.surmon.me/article';
    // var pageIndex = (params is Map) ? params['pageIndex'] : 0;
    // final _param  = {'page':1,'pageSize':20,'sort':'rankIndex'};

    var response = await NetUtils.get(juejin_flutter);
    var responseList = response['result']['data'];
    // var pageTotal = response['d']['total'];
    // if (!(pageTotal is int) || pageTotal <= 0) {
    //   pageTotal = 0;
    // }
    // pageIndex += 1;
    List resultList = new List();
    for (int i = 0; i < responseList.length; i++) {
      try {
        // HomePageItem cellData = new HomePageItem.fromJson(responseList[i]);
        // resultList.add(cellData);
        // resultList.add({});
      } catch (e) {
        // No specified type, handles all
      }
    }
    Map<String, dynamic> result = {"list":resultList, 'total':0, 'pageIndex': 1};
    return result;
  }

  Widget makeCard(index,item){

    var myTitle = '${item.title}';
    var myUsername = '${'👲'}: ${item.username} ';
    var codeUrl = '${item.detailUrl}';
    return new ListViewItem(itemUrl:codeUrl,itemTitle: myTitle,data: myUsername,);
  }

  headerView(){
    return
      Column(
        children: <Widget>[
        Stack(
        //alignment: const FractionalOffset(0.9, 0.1),//方法一
        children: <Widget>[
            Pagination(),
            Positioned(//方法二
            top: 10.0,
            left: 0.0,
            child: DisclaimerMsg(key:key,pWidget:this)
            ),
          ]),
        SizedBox(height: 1, child:Container(color: Theme.of(context).primaryColor)),
        SizedBox(height: 10),
        ],
      );

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Column(
        children: <Widget>[
//          new Stack(
//            //alignment: const FractionalOffset(0.9, 0.1),//方法一
//            children: <Widget>[
//            Pagination(),
//            Positioned(//方法二
//              top: 10.0,
//              left: 0.0,
//              child: DisclaimerMsg(key:key,pWidget:this)
//            ),
//          ]),
//          SizedBox(height: 2, child:Container(color: Theme.of(context).primaryColor)),
          new Expanded(
            //child: new List(),
            child: listComp.ListRefresh(getIndexListData,makeCard,headerView)
          )
        ]

    );
  }
}


