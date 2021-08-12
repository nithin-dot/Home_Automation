import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:quiver/iterables.dart';
import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import 'package:custom_switch_button/custom_switch_button.dart';
import 'package:http/http.dart' as http;
import 'package:lab_automation/json.dart';

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  bool getbool1 = false;
  bool getbool2 = false;

  // ignore: missing_return
  Future<List<Getdata>> getData() async {
    List<Getdata> list;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.none) {
      Future.delayed(Duration(seconds: 5), () {
        getData();
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      try {
        String link = "http://10.10.110.2:4000/appjson";
        var res = await http.get(Uri.encodeFull(link), headers: {
          "Accept": "application/json"
        }).timeout(Duration(seconds: 5), onTimeout: () {
          getData();
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        });
        // .timeout(const Duration(milliseconds: 230), onTimeout: () {
        //   getData();
        //   throw TimeoutException(
        //       'The connection has timed out, Please try again!');
        // });
        // print(res.body);
        if (res.statusCode == 200) {
          setState(() {
            var data = json.decode(res.body);
            var rest = data as List;
            list = rest.map<Getdata>((json) => Getdata.fromJson(json)).toList();
          });
          // print(rest);
        }
        return list;
      } on Exception catch (e) {
        if (e.toString().contains('SocketException')) {
          getData();
        }
        //do something else
      }
    }
  }

  // ignore: missing_return
  Future<String> display(id, state) async {
    var url = 'http://10.10.110.2/labswitches/updateF.php?id=$id&val=$state';
    // ignore: unused_local_variable
    var response = await http.get(url);
  }

  void initState() {
    super.initState();
    getData();
  }

  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List list1 = [];
    List list2 = [];
    List list3 = [];

    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'IOT AUTOMATION',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                for (var i in range(snapshot.data.length)) {
                  // var k = i - snapshot.data.length;

                  // print(i);
                  if (snapshot.data[i].sname.contains("AUTO/MANUAL")) {
                    // print(snapshot.data[i].id);
                    list1.add(i);
                  }
                }

                list1.add(snapshot.data.length);
                list3.length = list1.length - 1;
                for (var i in range(list1.length - 1)) {
                  for (var m in range(list1[i], list1[i + 1])) {
                    list2.add(m);

                    // print(m);
                  }

                  // print(list2);
                  list2.removeAt(0);
                  list3[i] = list2;
                  list2 = [];
                }
              } else {}
              return snapshot.data != null
                  ? PageView(
                      controller: _controller,
                      children: [
                        for (var i in range(list3.length))
                          Page_1(context, snapshot.data, i, list1, list3),
                        // Page_2(context, snapshot.data),
                      ],
                    )
                  : Align(
                      widthFactor: double.infinity,
                      heightFactor: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 40,
                          ),
                          Text(
                            "Make sure you connected with Our Network",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 12,
                          ),
                        ],
                      ),
                    );
            }));
  }

  // ignore: non_constant_identifier_names
  ListView Page_1(
      BuildContext context, List<Getdata> getdata, i, list1, list3) {
    return ListView(
      children: [
        _automatic(context, getdata, list1[i]),
        GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
            crossAxisCount: 2,
            children: [
              for (var i in list3[i])
                GestureDetector(
                  onTap: () {
                    setState(() {
                      display(
                          getdata[i].id,
                          getdata[i].val == "ON"
                              ? getdata[i].val = "OFF"
                              : getdata[i].val = "ON");
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: getdata[i].val == "ON"
                                ? Offset(-3, 3)
                                : Offset(-3, -3), //(x,y)
                            blurRadius: 6.0,
                          ),
                          BoxShadow(
                            color: Colors.white,
                            offset: getdata[i].val == "ON"
                                ? Offset(3, -3)
                                : Offset(-3, -3), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        color: getdata[i].val == "ON"
                            ? Colors.blue
                            : Colors.white),
                    padding: const EdgeInsets.all(8),
                    child: Align(
                      widthFactor: double.infinity,
                      heightFactor: double.infinity,
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * .4,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                // height: SizeConfig.blockSizeVertical * 4,
                                width: SizeConfig.blockSizeHorizontal * 6,
                              ),
                              Icon(
                                getdata[i].sname.contains("LIGHT") ||
                                        getdata[i].sname.contains("FAN")
                                    ? getdata[i].sname.contains("LIGHT")
                                        ? Icons.lightbulb_outline
                                        : Icons.ac_unit_outlined
                                    : null,
                                color: getdata[i].val == "ON"
                                    ? Colors.white
                                    : Colors.blue,
                                size: SizeConfig.blockSizeHorizontal * 9,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                            // width: SizeConfig.blockSizeHorizontal * 50,
                          ),
                          // Row(
                          //   children: [
                          Column(
                            children: [
                              Container(
                                width: SizeConfig.blockSizeHorizontal * 30,
                                child: Text(getdata[i].sname,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: getdata[i].val == "ON"
                                          ? Colors.white
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 4,
                                    )),
                              )
                              //   ],
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                            // width: SizeConfig.blockSizeHorizontal * 50,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomSwitchButton(
                                backgroundColor: getdata[i].val == "ON"
                                    ? Colors.white
                                    : Colors.blue,
                                unCheckedColor: getdata[i].val == "ON"
                                    ? Colors.blue
                                    : Colors.white,
                                animationDuration: Duration(milliseconds: 400),
                                checkedColor: getdata[i].val == "ON"
                                    ? Colors.blue
                                    : Colors.white,
                                checked: getdata[i].val == "ON" ? true : false,
                              ),
                              SizedBox(
                                  // height: SizeConfig.blockSizeVertical * 4,
                                  width: SizeConfig.blockSizeHorizontal * 5.5)
                            ],
                          ),
                        ],
                      ),
                    ),

                    // color: Colors.teal[100],
                  ),
                )
            ]),
      ],
    );
  }

  Padding _automatic(BuildContext context, getdata, int list1) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            // getdata[list3[data]].val = !switch_automatic[data].switchval;
            // print(switch_automatic[data].id);
            // print(switch_automatic[data].switchval);
            display(
                getdata[list1].id,
                getdata[list1].val == "ON"
                    ? getdata[list1].val = "OFF"
                    : getdata[list1].val = "ON");
          });
        },
        child: Container(
          height: SizeConfig.blockSizeVertical * 10,
          width: SizeConfig.blockSizeHorizontal * 5,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 3,
              ),
              Text(
                getdata[list1].sname,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        getdata[list1].val == "ON" ? Colors.white : Colors.blue,
                    fontSize: SizeConfig.blockSizeVertical * 2.9),
              ),
              SizedBox(
                // height: SizeConfig.blockSizeVertical * 4,
                width: SizeConfig.blockSizeHorizontal * 15,
              ),
              CustomSwitchButton(
                backgroundColor:
                    getdata[list1].val == "ON" ? Colors.white : Colors.blue,
                unCheckedColor:
                    getdata[list1].val == "ON" ? Colors.blue : Colors.white,
                animationDuration: Duration(milliseconds: 400),
                checkedColor:
                    getdata[list1].val == "ON" ? Colors.blue : Colors.white,
                checked: getdata[list1].val == "ON" ? true : false,
              ),
              SizedBox(
                // height: SizeConfig.blockSizeVertical * 4,
                width: SizeConfig.blockSizeHorizontal * 1,
              ),
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: getdata[list1].val == "ON"
                      ? Offset(-3, 3)
                      : Offset(-3, -3), //(x,y)
                  blurRadius: 6.0,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: getdata[list1].val == "ON"
                      ? Offset(3, -3)
                      : Offset(-3, -3), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              color: getdata[list1].val == "ON" ? Colors.blue : Colors.white),
        ),
      ),
    );
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}
