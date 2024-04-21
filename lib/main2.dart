import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  var project_Name = 'Project Name';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Statistics'),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Project',
            ),
          ],
          backgroundColor: Color.fromARGB(255, 243, 148, 5),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${project_Name}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ) //프로젝트 이름이 들어가는 칼럼
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        '  Project TODO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ), //프로젝트 투두 텍스트
                Row(
                  children: [
                    Container(
                      height: 400,
                      //child: ListView.builder(itemBuilder: itemBuilder),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Text(
                        '  Routine ToDO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ), //프로젝트 투두 텍스트
                Row(
                  children: [
                    Container(
                      height: 200,
                      //child: ListView.builder(itemBuilder: itemBuilder),
                    ),
                  ],
                ),
              ],
            ), //Project TO DO및 리스트가 들어갈 Column
          ],
        ),
      ),
    );
  }
}
