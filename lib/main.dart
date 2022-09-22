import 'package:flutter/material.dart';
import 'package:flutter55/AllPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Flutter55());
}

class Flutter55 extends StatefulWidget {
  const Flutter55({Key? key}) : super(key: key);

  @override
  _Flutter55State createState() => _Flutter55State();
}

class _Flutter55State extends State<Flutter55> {
  int? selectedId;
  final textController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

 @override
  void initState() {
    super.initState();
    

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: scaffoldKey,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Column(children: [
               TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.book_online_rounded,color: Colors.blue[200])),                  
                  Tab(icon: Icon(Icons.upcoming,color: Colors.blue[200])),
                  Tab(icon: Icon(Icons.new_label,color: Colors.blue[200])),
                ],
              )],),
          ),
          body: Column(
            children:const<Widget> [
              Expanded(
                child: TabBarView(
                  children: [
                    ZeroPage(),
                    FirstPage(),
                    SecondPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
