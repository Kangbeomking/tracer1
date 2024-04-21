import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'dataModel.dart';

/// 데이터베이스 관리를 위한 클래스
class DatabaseManager {
  static Database? _database;

  /// 데이터베이스 인스턴스를 싱글턴으로 관리하여 여러번 생성되지 않도록 함
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  /// 데이터베이스 파일 생성 및 테이블 구조를 초기화
  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'project_database.db');
    return await openDatabase(path, version: 1, onCreate: createTables);
  }

  /// 데이터베이스 테이블을 생성하는 메소드
  void createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE KeyResults (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contents TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Sub_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contents TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE Actionx (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contents TEXT,
        progress INTEGER
      );
    ''');
    await db.execute('''
      CREATE TABLE KeyResult_SubGoal (
        keyResultId INTEGER,
        subGoalId INTEGER,
        weight INTEGER,
        PRIMARY KEY (keyResultId, subGoalId),
        FOREIGN KEY (keyResultId) REFERENCES KeyResults(id),
        FOREIGN KEY (subGoalId) REFERENCES SubGoals(id)
      );
    ''');
    await db.execute('''
      CREATE TABLE SubGoal_Actions (
        subGoalId  INTEGER,
        actionId  INTEGER,
        weight INTEGER,
        PRIMARY KEY (subGoalId, actionId),
        FOREIGN KEY (subGoalId) REFERENCES SubGoals(id),
        FOREIGN KEY (actionId) REFERENCES Actionx(id)
      );
    ''');
  }

  /// KeyResults 객체를 데이터베이스에 삽입
  Future<void> insertKeyResult(KeyResults keyResult) async {
    final db = await database;
    await db.insert('KeyResults', keyResult.toMap());
  }

  /// Sub_goal 객체를 데이터베이스에 삽입
  Future<void> insertSubGoal(Sub_goal subGoal) async {
    final db = await database;
    await db.insert('Sub_goals', subGoal.toMap());
  }

  /// Actions 객체를 데이터베이스에 삽입
  Future<void> insertAction(Actionx action) async {
    final db = await database;
    await db.insert('Actionx', action.toMap());
  }

  /// KeyResult와 SubGoal 간의 다대다 관계를 관리하는 테이블에 데이터를 삽입하는 메소드
  Future<void> insertKeyResultSubGoal(
      int keyResultId, int subGoalId, int weight) async {
    final db = await database;
    await db.insert('KeyResult_SubGoal',
        {'keyResultId': keyResultId, 'subGoalId': subGoalId, 'weight': weight});
  }

  /// SubGoal과 Action 간의 다대다 관계를 관리하는 테이블에 데이터를 삽입하는 메소드
  Future<void> insertSubGoalAction(
      int subGoalId, int actionId, int weight) async {
    final db = await database;
    await db.insert('SubGoal_Actions',
        {'subGoalId': subGoalId, 'actionId': actionId, 'weight': weight});
  }

  // KeyResults 테이블에서 모든 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getKeyResults() async {
    final db = await database; // 데이터베이스 인스턴스를 가져옵니다.
    final List<Map<String, dynamic>> maps =
        await db.query('KeyResults'); // 데이터베이스에서 KeyResults 테이블을 쿼리합니다.
    return maps; // 쿼리 결과를 반환합니다.
  }

// Sub_goals 테이블에서 모든 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getSubGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Sub_goals');
    return maps;
  }

// Actions 테이블에서 모든 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getActions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Actionx');
    return maps;
  }

  // KeyResult ID에 해당하는 Sub_goals를 가져오는 메서드
  Future<List<Map<String, dynamic>>> getSubGoalsFor(int keyResultId) async {
    final db = await database;
    // KeyResult_SubGoal 테이블에서 keyResultId에 해당하는 모든 subGoalId를 가져옵니다.
    final List<Map<String, dynamic>> keyResultSubGoalsMaps = await db.query(
      'KeyResult_SubGoal',
      columns: ['subGoalId', 'weight'],
      where: 'keyResultId = ?',
      whereArgs: [keyResultId],
    );

    // 가져온 subGoalId를 사용하여 Sub_goals 테이블에서 Sub_goals 정보를 가져옵니다.
    List<Map<String, dynamic>> subGoals = [];
    for (var keyResultSubGoal in keyResultSubGoalsMaps) {
      final subGoalMaps = await db.query(
        'Sub_goals',
        where: 'id = ?',
        whereArgs: [keyResultSubGoal['subGoalId']],
      );

      // Sub_goals 정보와 weight를 결합합니다.
      if (subGoalMaps.isNotEmpty) {
        final subGoal = subGoalMaps.first;
        subGoal['weight'] = keyResultSubGoal['weight']; // weight 정보 추가
        subGoals.add(subGoal);
      }
    }

    return subGoals;
  }

  // 현재 KeyResult와 연결되지 않은 Sub_goals를 가져오는 메서드
  Future<List<Map<String, dynamic>>> getAvailableSubGoals(
      int keyResultId) async {
    final db = await database;
    // 먼저 현재 KeyResult와 연결된 모든 Sub_goal ID를 가져옵니다.
    final List<Map<String, dynamic>> linkedSubGoals = await db.query(
      'KeyResult_SubGoal',
      columns: ['subGoalId'],
      where: 'keyResultId = ?',
      whereArgs: [keyResultId],
    );

    // 연결된 Sub_goal ID 목록을 추출합니다.
    List<int> linkedSubGoalIds =
        linkedSubGoals.map((sg) => sg['subGoalId'] as int).toList();

    // 연결되지 않은 Sub_goals를 조회합니다.
    final String whereClause = linkedSubGoalIds.isNotEmpty
        ? 'id NOT IN (${linkedSubGoalIds.join(', ')})'
        : '1 = 1'; // 모든 Sub_goals를 가져오기 위한 조건 (연결된 Sub_goal이 없는 경우)

    final List<Map<String, dynamic>> availableSubGoals =
        await db.query('Sub_goals', where: whereClause);

    return availableSubGoals;
  }
}

/// main 함수는 앱의 시작점으로, 필요한 초기화 및 데이터 삽입 로직을 포함
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화 보장
  var dbManager = DatabaseManager(); // 데이터베이스 매니저 객체 생성

  // 샘플 데이터 객체 생성
  var keyResult = KeyResults(contents: 'Increase user engagement');
  var subGoal = Sub_goal(contents: 'Implement new UI features');
  var action = Actionx(contents: 'Design new user dashboard', progress: 50);

  // 데이터베이스에 샘플 데이터 삽입
  await dbManager.insertKeyResult(keyResult);
  await dbManager.insertSubGoal(subGoal);
  await dbManager.insertAction(action);

  // 조인 테이블에 관계 데이터 삽입
  await dbManager.insertKeyResultSubGoal(1, 1, 20);
  await dbManager.insertSubGoalAction(1, 1, 30);

  print('Data and relationships inserted successfully');
}
