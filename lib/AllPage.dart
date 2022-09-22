import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter55/Grocery.dart';
import 'package:flutter55/Db.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'dart:io';
import 'package:intl/intl.dart';
/*page1*/

class ZeroPage extends StatefulWidget {
  const ZeroPage({Key? key}) : super(key: key);

  @override
  State<ZeroPage> createState() => _ZeroPageState();
}

class _ZeroPageState extends State<ZeroPage> {
  final _saved = <Grocery>[];
  final Map<int, double> entries = HashMap();
  final edit1 = TextEditingController();
  double tongcong = 0.0;
  var f = NumberFormat("#,##0.00", "en_US");

  bool _doitjustone = false;
  List<Grocery> _list = [];
  List<Grocery> _filteredlist = <Grocery>[];

  double tinhtong() {
    tongcong = 0.0;
    setState(() {
      entries.forEach((key, value) {
        tongcong += _saved[key].dongia * value;
      });
    });
    return tongcong;
  }

  void _filterList(value) {
    setState(() {
      _filteredlist = _list
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // final scaffoldKey = GlobalKey<ScaffoldState>();
  // int? selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: scaffoldKey,
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () {
            _pushSaved();
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  Widget _buildSuggestions() {
    return Column(
      children: <Widget>[
        Container(
          height: 42,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.black26),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: Colors.amber[900]),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              _filterList(value);
              // developer.log(value, name: '1234');
            },
          ),
        ),
        Expanded(
            child: FutureBuilder<List<Grocery>>(
                future: DatabaseHelper.instance.getGroceries(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Grocery>> listgrocery) {
                  if (!listgrocery.hasData) {
                    return const Center(child: Text('Loading...'));
                  } else {
                    if (listgrocery.data!.isEmpty) {
                      return const Center(child: Text('không có dữ liệu.'));
                    } else {
                      if (!_doitjustone) {
                        _list = listgrocery.data!;
                        _filteredlist = _list;
                        _doitjustone = !_doitjustone;
                      }
                      return ListView.builder(
                        itemCount: _filteredlist.length,
                        itemBuilder: (BuildContext context, int index) {
                          Grocery item = _filteredlist[index];
                          return Center(
                            child: Card(child: _buildRow(item)),
                          );
                        },
                      );
                    }
                  }
                }))
      ],
    );
  }

  Widget _buildRow(Grocery grocery) {
    final alreadySaved = _saved.contains(grocery);
    return Column(children: [
      ListTile(
        leading: Icon(
          alreadySaved ? Icons.star : Icons.star_border,
          size: 30.0,
          color: alreadySaved ? Colors.amber[900] : null,
          semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              _saved.remove(grocery);
            } else {
              _saved.add(grocery);
            }
          });
        },
        title: Text(grocery.name),
        subtitle: Text(grocery.donvi),
        trailing: Text(grocery.dongia.toString()),
        isThreeLine: true,
      ),
    ]);
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          YYDialog.init(context);
          final tiles = _saved.map(
            (Grocery) {
              return ListTile(
                tileColor: entries.containsKey(_saved.indexOf(Grocery))
                    ? Colors.amberAccent
                    : null,
                leading: Text((_saved.indexOf(Grocery) + 1).toString()),
                minLeadingWidth: 6,
                title: Text(Grocery.name),
                subtitle: Text(Grocery.donvi),
                trailing: Text(Grocery.dongia.toString()),
                onTap: () {
                  setState(() {
                    edit1.clear();
                    YYDialogDemo(context, Grocery);
                  });
                },
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.redAccent,
              title: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text('Tổng Tiền :',style: TextStyle(fontSize: 16.0),textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: Text(f.format(tongcong),style: const TextStyle(fontSize: 16.0), textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
            body: Center(
              child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: constraints.maxHeight * 1,
                                width: constraints.maxWidth * 0.8,
                                child: Center(
                                  child: ListView(children: divided),
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  color: Colors.white70,
                                  height: constraints.maxHeight * 1,
                                  width: constraints.maxWidth * 0.2,
                                  child: ListView.builder(
                                      itemCount: entries.length,
                                      itemBuilder: (context, index) {
                                        int key = entries.keys.elementAt(index);
                                        return Container(
                                          height: 60,
                                          margin: const EdgeInsets.fromLTRB(
                                              6, 6, 3, 6),
                                          padding: const EdgeInsets.all(0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.amberAccent,
                                              border: Border.all(
                                                  color: Colors
                                                      .grey, // Set border color
                                                  width:
                                                      1.9), // Set border width
                                              borderRadius: const BorderRadius
                                                      .all(
                                                  Radius.circular(
                                                      3.0)), // Set rounded corner radius
                                              boxShadow: const [
                                                BoxShadow(
                                                    blurRadius: 3,
                                                    color: Colors.black,
                                                    offset: Offset(1, 3))
                                              ] // Make rounded corner of border
                                              ),
                                          child: Text(
                                              "* " + entries[key].toString()),
                                        );
                                      })),
                            ],
                          )
                        ],
                      )),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.white70,
                foregroundColor: null,
                child: const Icon(Icons.calculate, color: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context);
                  tinhtong();
                  _pushSaved();
                }),
          );
        },
      ),
    );
  }

  YYDialog YYDialogDemo(BuildContext context, Grocery grocery) {
    return YYDialog().build(context)
      ..borderRadius = 8.0
      ..gravity = Gravity.top
      ..gravityAnimationEnable = true
      ..margin = const EdgeInsets.fromLTRB(64.0, 128.0, 64.0, 0.0)
      ..widget(
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'số lượng',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
              controller: edit1,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 26.0,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
        ),
      )
      ..divider()
      ..doubleButton(
        padding: const EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "hủy bỏ",
        color1: Colors.redAccent,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {
          Null;
        },
        text2: "xác nhận",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () {
          setState(() {
            entries.update(
                _saved.indexOf(grocery), ((value) => double.parse(edit1.text)),
                ifAbsent: () => double.parse(edit1.text));
          });
        },
      )
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..show();
  }
}

/*page2*/

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int? selectedId;
  final _masp = TextEditingController();
  final _tensp = TextEditingController();
  final _donvi = TextEditingController();
  final giamoi = TextEditingController();

  bool _doitjustone = false;
  List<Grocery> _list = [];
  List<Grocery> _filteredlist = <Grocery>[];

  void _filterList(value) {
    setState(() {
      _filteredlist = _list
          .where((element) =>
              element.masp.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 8, 16, 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                  child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.search, size: 32.0),
                                  // hintText: 'how about this',
                                  labelText: 'mã sp',
                                ),
                                controller: _tensp,
                                onChanged: (value) {
                                  _filterList(value);
                                },
                              )),
                              Expanded(
                                  child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.price_change),
                                  hintText: 'bấm vào nút bên cạnh để thây đổi',
                                  labelText: 'Giá mới',
                                ),
                                controller: giamoi,
                                keyboardType: TextInputType.number,
                              )),
                              IconButton(

                                  onPressed: () async {
                                    if( selectedId != null){
                                      await DatabaseHelper.instance.update(
                                        Grocery(
                                            id: selectedId,
                                            masp: _masp.text,
                                            name: _tensp.text,
                                            dongia:
                                            double.parse(giamoi.text),
                                            donvi: _donvi.text),
                                      );
                                    }
                                    _filteredlist =await DatabaseHelper.instance.getGroceries();
                                    setState(() {
                                      _tensp.clear();
                                      _donvi.clear();
                                      giamoi.clear();
                                      selectedId = null;
                                    });


                                  },
                                  icon: const Icon(Icons.next_plan_outlined,
                                      color: Colors.blue))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Builder(builder: (context) {
                            YYDialog.init(context);
                            return Center(
                              child: Container(
                                height: 500,
                                child: FutureBuilder<List<Grocery>>(
                                    future:
                                        DatabaseHelper.instance.getGroceries(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<List<Grocery>> snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: Text('Loading...'));
                                      } else {
                                        if (snapshot.data!.isEmpty) {
                                          return const Center(
                                              child: Text('không có dữ liệu.'));
                                        } else {
                                          if (!_doitjustone) {
                                            _list = snapshot.data!;
                                            _filteredlist = _list;
                                            _doitjustone = !_doitjustone;
                                          }
                                          return ListView.builder(
                                            itemCount: _filteredlist.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Grocery item =
                                                  _filteredlist[index];
                                              return Center(
                                                child: Card(
                                                  color: selectedId == item.id
                                                      ? Colors.white70
                                                      : Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                      color:
                                                          Colors.green.shade300,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          (item.masp)
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      12.0),
                                                        ),
                                                        subtitle: Text(
                                                            item.name,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        18.0)),
                                                        onTap: () {
                                                          setState(() {
                                                            if (selectedId ==
                                                                null) {
                                                              giamoi
                                                                  .text = (item
                                                                      .dongia)
                                                                  .toString();
                                                              selectedId =
                                                                  item.id;
                                                              _masp.text =
                                                                  item.masp;
                                                              _tensp.text =
                                                                  item.name;
                                                              _donvi.text =
                                                                  item.donvi;
                                                            } else {
                                                              giamoi.text = '';
                                                              selectedId = null;
                                                            }
                                                          });
                                                        },
                                                        onLongPress: () async {
                                                          YYDialogDemo2(
                                                              context, item);
                                                        },
                                                      ),
                                                      ButtonBar(
                                                        alignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text(
                                                                item.donvi),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Text((item
                                                                    .dongia)
                                                                .toString()),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            // children: snapshot.data!.map((grocery) {

                                            // }).toList(),
                                          );
                                        }
                                      }
                                    }),
                              ),
                            );
                          }),
                        )
                      ]),
                ),
              )),
        ));
  }


  YYDialog YYDialogDemo2(BuildContext context, Grocery grocery) {
    return YYDialog().build(context)
      ..borderRadius = 8.0
      ..gravity = Gravity.top
      ..gravityAnimationEnable = true
      ..margin = const EdgeInsets.fromLTRB(64.0, 128.0, 64.0, 0.0)
      ..widget(
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('xóa hả', textAlign: TextAlign.center),
          ),
        ),
      )
      ..divider()
      ..doubleButton(
        padding: const EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: true,
        text1: "hủy bỏ",
        color1: Colors.redAccent,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {
          Null;
        },
        text2: "xác nhận",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () {
          setState(() {
            DatabaseHelper.instance.remove(grocery.id!);
          });
        },
      )
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..show();
  }
}

/*page3*/

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int? selectedId;
  final masp = TextEditingController();
  final tensp = TextEditingController();
  final gia = TextEditingController();
  final donvi = TextEditingController();
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 12.0),
                TextField(
                  obscureText: false,
                  controller: masp,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 15.0),
                      hintText: "Mã Hàng Hóa",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  obscureText: false,
                  controller: tensp,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
                      hintText: "Tên Hàng Hóa",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  obscureText: false,
                  controller: gia,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
                      hintText: "Giá Hàng Hóa",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  obscureText: false,
                  controller: donvi,
                  decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
                      hintText: "Đơn Vị",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
                const SizedBox(height: 12.0),
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.green[600],
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
                    onPressed: () async {
                      selectedId != null
                          ? await DatabaseHelper.instance.update(
                              Grocery(
                                  id: selectedId,
                                  masp: masp.text,
                                  name: tensp.text,
                                  dongia: double.parse(gia.text),
                                  donvi: donvi.text),
                            )
                          : await DatabaseHelper.instance.add(
                              Grocery(
                                  masp: masp.text,
                                  name: tensp.text,
                                  dongia: double.parse(gia.text),
                                  donvi: donvi.text),
                            );
                      setState(() {
                        masp.clear();
                        tensp.clear();
                        gia.clear();
                        donvi.clear();
                        selectedId = null;
                      });
                    },
                    child: const Text(
                      "Lưu",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.orange[400],
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(50.0, 15.0, 50.0, 15.0),
                    onPressed: () {
                      setState(() {
                        masp.clear();
                        tensp.clear();
                        gia.clear();
                        donvi.clear();
                        selectedId = null;
                      });
                    },
                    child: const Text(
                      "Làm lại",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
