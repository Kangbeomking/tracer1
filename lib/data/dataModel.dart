abstract class Data {
  int? id;
  String contents;

  Data({required this.contents});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contents': contents,
    };
  }
}

class KeyResults extends Data {
  KeyResults({required String contents}) : super(contents: contents);
}

class Sub_goal extends Data {
  Sub_goal({required String contents}) : super(contents: contents);
}

class Actionx extends Data {
  int? progress;
  Actionx({required String contents, this.progress})
      : super(contents: contents);
  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['progress'] = progress; // progress 필드도 맵에 추가
    return map;
  }
}
