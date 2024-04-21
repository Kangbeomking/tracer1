import 'package:flutter/material.dart';
import 'data/dataBase.dart';
import 'data/dataModel.dart';

void main() {
  runApp(MyApp()); // 앱 시작점, MyApp 위젯을 실행합니다.
}

// MyApp 위젯은 앱의 최상위 레벨 위젯입니다.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // MaterialApp의 홈은 HomeScreen 위젯입니다.
    );
  }
}

// HomeScreen 위젯은 StatefulWidget으로, 상태 변경이 가능합니다.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// _HomeScreenState는 HomeScreen의 상태를 관리합니다.
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스를 저장합니다.

  // 각 탭에 해당하는 페이지 위젯들을 저장하는 리스트입니다.
  final List<Widget> _pages = [
    Page1(),
    Page2(),
    Page3(),
  ];

  // 탭이 탭될 때 호출되는 함수, 선택된 탭의 인덱스를 업데이트합니다.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack은 모든 자식을 쌓아두고 선택된 인덱스의 위젯만 표시합니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 하단 네비게이션 바
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
        currentIndex: _selectedIndex, // 현재 선택된 인덱스를 표시합니다.
        onTap: _onItemTapped, // 아이템이 탭될 때 _onItemTapped를 호출합니다.
      ),
    );
  }
}

// Page1 위젯은 홈 페이지를 표현합니다.

// Page2 위젯은 비즈니스 페이지를 표현합니다.

class Page1 extends StatelessWidget {
  var project_Name = 'Project Name';
  DatabaseManager dbManager = DatabaseManager();

  @override
  Widget build(BuildContext context) {
    // MaterialApp은 가능한 가장 상위에 위치해야 하므로,
    // 이 예제 코드에서 MaterialApp을 삭제하고 위젯 트리의 최상단에 위치시켜야 합니다.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                project_Name,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '  Project TODO',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbManager.getActions(), // DatabaseManager 인스턴스를 통한 데이터 조회
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.data != null && snapshot.data!.isEmpty) {
                    // 데이터가 비어있는 경우
                    return Center(child: Text('No actions to display'));
                  }
                  // 데이터가 있는 경우
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.red, Colors.yellow, Colors.white],
                          ),
                        ),
                        child: ListTile(
                          title: Text(item['contents']),
                          subtitle: Text('Progress: ${item['progress']}%'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Details'),
                                  content: Text(
                                      'Action: ${item['contents']}\nProgress: ${item['progress']}%'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  // 데이터가 로딩 중인 경우
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}

class Page3 extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<Page3> {
  late Future<List<Map<String, dynamic>>> keyResults;

  @override
  void initState() {
    super.initState();
    keyResults = DatabaseManager().getKeyResults();
  }

  void addKeyResult(String content) async {
    final db = await DatabaseManager().database;
    // 새 KeyResult 추가 SQL 쿼리 실행
    // KeyResults 인스턴스를 생성합니다.
    var keyResult = KeyResults(contents: content);
    await DatabaseManager().insertKeyResult(keyResult);

    // 삽입 후 UI를 업데이트하기 위해 setState 호출
    setState(() {
      // 데이터베이스에서 새로운 keyResults 리스트를 가져오는 로직.
      // 이 future는 FutureBuilder에 의해 사용됩니다.
      keyResults = DatabaseManager().getKeyResults();
    });
  }

  void navigateToKeyResultDetail(Map<String, dynamic> keyResult) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => KeyResultDetailPage(
        keyResultId: keyResult['id'],
        keyResultContent: keyResult['contents'],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('projectName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: keyResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(child: Text('No KeyResults available'));
                  }
                  return ListView(
                    children: snapshot.data!.map((keyResult) {
                      return Card(
                        child: ListTile(
                          title: Text(keyResult['contents']),
                          trailing: Text('${keyResult['progress']}%'),
                          onTap: () {
                            navigateToKeyResultDetail(keyResult);
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                // 'Add a new keyresult' 버튼 로직
                String content = await _showAddKeyResultDialog(context);
                if (content.isNotEmpty) {
                  addKeyResult(content);
                }
              },
              child: Text('Add a new keyresult'),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _showAddKeyResultDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New KeyResult'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter KeyResult content',
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop('');
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                ),
              ],
            );
          },
        ) ??
        '';
  }
}

class KeyResultDetailPage extends StatefulWidget {
  final int keyResultId; // KeyResult의 고유 ID
  final String keyResultContent; // KeyResult의 내용

  KeyResultDetailPage(
      {Key? key, required this.keyResultId, required this.keyResultContent})
      : super(key: key);
  @override
  _KeyResultDetailPageState createState() => _KeyResultDetailPageState();
}

class _KeyResultDetailPageState extends State<KeyResultDetailPage> {
  late Future<List<Map<String, dynamic>>> subGoals;

  @override
  void initState() {
    super.initState();
    // 현재 KeyResult에 대한 SubGoals를 로드합니다.
    // 이는 데이터베이스 쿼리 함수가 될 것입니다.
    subGoals = DatabaseManager().getSubGoalsFor(widget.keyResultId);
  }

  // SubGoal 상세 페이지로 이동하는 함수
  void navigateToSubGoalDetail(Map<String, dynamic> subGoal) {
    // 여기에 로직 구현...
  }

  // SubGoal 추가 또는 연결하는 함수
  void addOrLinkSubGoal() async {
    // 사용자에게 'LINK' 또는 'ADD NEW' 옵션을 선택할 수 있는 대화창을 표시합니다.
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SubGoal Options'),
          content: Text(
              'Would you like to link existing SubGoals or add a new one?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'LINK'),
              child: Text('LINK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'ADD NEW'),
              child: Text('ADD NEW'),
            ),
          ],
        );
      },
    );

    // 대화창에서 선택된 옵션에 따라 적절한 함수를 호출합니다.
    if (result == 'LINK') {
      // 'LINK'를 선택한 경우, 기존 SubGoal과 연결하는 페이지로 이동합니다.
      navigateToLinkSubGoalsPage();
    } else if (result == 'ADD NEW') {
      // 'ADD NEW'를 선택한 경우, 새로운 SubGoal을 추가하기 위한 입력 대화창을 표시합니다.
      addNewSubGoal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keyResultContent),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: subGoals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(child: Text('No SubGoals available'));
            }
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                var subGoal = snapshot.data![index];
                return ListTile(
                  title: Text(subGoal['content']),
                  subtitle: Text(
                      'Weight: ${subGoal['weight']} Progress: ${subGoal['progress']}%'),
                  onTap: () => navigateToSubGoalDetail(subGoal),
                );
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // SubGoal 추가 또는 연결하는 함수 호출
          addOrLinkSubGoal();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void navigateToLinkSubGoalsPage() {
    // SubGoals과 KeyResult를 연결하는 페이지로 이동하는 로직을 구현합니다.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LinkSubGoalsPage(keyResultId: widget.keyResultId),
      ),
    );
  }

  void subgaol(String content) async {
    final db = await DatabaseManager().database;
    // 새 KeyResult 추가 SQL 쿼리 실행
    // KeyResults 인스턴스를 생성합니다.
    var subgoal = Sub_goal(contents: content);
    await DatabaseManager().insertSubGoal(subgoal);

    // 삽입 후 UI를 업데이트하기 위해 setState 호출
    setState(() {
      // 데이터베이스에서 새로운 keyResults 리스트를 가져오는 로직.
      // 이 future는 FutureBuilder에 의해 사용됩니다.
      subGoals = DatabaseManager().getSubGoals();
    });
  }

  void addNewSubGoal() async {
    // 새 SubGoal의 내용을 입력받기 위한 대화창을 생성합니다.
    final TextEditingController subGoalController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New SubGoal'),
          content: TextField(
            controller: subGoalController,
            decoration: InputDecoration(hintText: 'Enter subgoal content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final content = subGoalController.text;
                var sub_goal = Sub_goal(contents: content);
                if (content.isNotEmpty) {
                  try {
                    // 데이터베이스에 새로운 SubGoal 추가하고 성공 시 UI 업데이트
                    await DatabaseManager().insertSubGoal(sub_goal);
                    Navigator.pop(context, 'ADD');
                    setState(() {}); // UI 업데이트를 위한 setState 호출
                  } catch (e) {
                    // 에러 처리 로직
                    print(e); // 콘솔에 에러 출력
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    // 'Add' 버튼을 클릭하여 새 SubGoal이 추가된 경우, SubGoals 리스트를 업데이트합니다.
    if (result == 'ADD') {
      setState(() {
        subGoals = DatabaseManager().getSubGoalsFor(widget.keyResultId);
      });
    }
  }

  // 현재 KeyResult를 삭제하는 함수
  void deleteKeyResult() async {
    // 데이터베이스에서 KeyResult 삭제 로직 구현...
    Navigator.of(context).pop(); // 삭제 후 이전 페이지로 돌아갑니다.
  }
}

class LinkSubGoalsPage extends StatefulWidget {
  final int keyResultId; // 현재 KeyResult의 고유 ID

  LinkSubGoalsPage({Key? key, required this.keyResultId}) : super(key: key);

  @override
  _LinkSubGoalsPageState createState() => _LinkSubGoalsPageState();
}

class _LinkSubGoalsPageState extends State<LinkSubGoalsPage> {
  late Future<List<Map<String, dynamic>>> availableSubGoals;

  @override
  void initState() {
    super.initState();
    // 현재 KeyResult와 연결되지 않은 SubGoals를 로드하는 메서드를 호출합니다.
    availableSubGoals =
        DatabaseManager().getAvailableSubGoals(widget.keyResultId);
  }

  // 선택된 SubGoals을 현재의 KeyResult와 연결하는 메서드
  void linkSubGoalsToKeyResult(List<int> selectedSubGoalIds) {
    for (int subGoalId in selectedSubGoalIds) {
      // 데이터베이스에 연결 정보를 저장
      DatabaseManager()
          .insertKeyResultSubGoal(widget.keyResultId, subGoalId, 1);
    }
    Navigator.pop(context); // 작업 완료 후 이전 화면으로 돌아갑니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link SubGoals to KeyResult'), // 앱 바 제목 설정
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: availableSubGoals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}')); // 에러 발생 시 에러 메시지 표시
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                      'No available SubGoals')); // 사용 가능한 SubGoals가 없을 때 메시지 표시
            }
            // 데이터 로드 성공 시 체크박스 리스트로 SubGoals 표시
            return ListView(
              children: snapshot.data!.map((subGoal) {
                return CheckboxListTile(
                  title: Text(subGoal['contents']), // SubGoal 내용
                  value: subGoal['isSelected'], // 체크박스 선택 상태
                  onChanged: (bool? value) {
                    setState(() {
                      subGoal['isSelected'] = value; // 사용자 입력에 따라 상태 업데이트
                    });
                  },
                );
              }).toList(),
            );
          } else {
            return CircularProgressIndicator(); // 데이터 로딩 중 표시
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          """
          // 선택된 SubGoals의 ID를 추출하여 연결
          List<int> selectedSubGoalIds = snapshot.data!
              .where((subGoal) => subGoal['isSelected'] == true)
              .map<int>((subGoal) => subGoal['id'])
              .toList();
          linkSubGoalsToKeyResult(selectedSubGoalIds);"""; // 연결 실행
        },
        child: Icon(Icons.link),
        tooltip: 'Link Selected SubGoals', // 플로팅 액션 버튼 툴팁
      ),
    );
  }
}
