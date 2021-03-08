import 'dart:developer';

import 'package:azlistview/azlistview.dart';
import 'package:azlistview_example/common/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarModelsPage extends StatefulWidget {
  @override
  _CarModelsPageState createState() => _CarModelsPageState();
}

class _CarModelsPageState extends State<CarModelsPage> {
  List<ContactInfo> contactList = [];

  double susItemHeight = 24;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    rootBundle.loadString('assets/data/car_models.json').then((value) {
      List list = json.decode(value);
      list.forEach((v) {
        contactList.add(ContactInfo.fromJson(v));
      });
//      contactList = contactList.reversed.toList();
//      log('$contactList');
      _handleList(contactList);
    });
  }

  void _handleList(List<ContactInfo> list) {
    if (list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(contactList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(contactList);

    // add header.
    contactList.insert(0, ContactInfo(name: 'header', tagIndex: '选'));

    setState(() {});
  }

  Widget customHeader() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 32, top: 20, right: 32, bottom: 16),
          child: Image.asset(
            Utils.getImgPath('ic_car_models_header1'),
            fit: BoxFit.contain,
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 32, top: 0, right: 32, bottom: 16),
          child: Image.asset(
            Utils.getImgPath('ic_car_models_header2'),
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Car models',
          style: TextStyle(color: Color(0xFF171717)),
        ),
      ),
      body: AzListView(
        data: contactList,
        itemCount: contactList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) return customHeader();
          ContactInfo model = contactList[index];
          return Utils.getWeChatListItem(context, model,
              susHeight: susItemHeight);
        },
        susItemHeight: susItemHeight,
        susItemBuilder: (BuildContext context, int index) {
          ContactInfo model = contactList[index];
          if ('选' == model.getSuspensionTag()) {
            return Container();
          }
          return Utils.getSusItem(context, model.getSuspensionTag(),
              susHeight: susItemHeight);
        },
        indexBarData: ['选', ...kIndexBarData],
        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          selectTextStyle: TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
          selectItemDecoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xFF333333)),
          indexHintWidth: 96,
          indexHintHeight: 97,
          indexHintDecoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Utils.getImgPath('ic_index_bar_bubble_white')),
              fit: BoxFit.contain,
            ),
          ),
          indexHintAlignment: Alignment.centerRight,
          indexHintTextStyle: TextStyle(fontSize: 24.0, color: Colors.black87),
          indexHintOffset: Offset(-30, 0),
        ),
      ),
    );
  }
}
