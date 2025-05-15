class Todo {
  List<Todos>? todos;

  Todo({this.todos});

  Todo.fromJson(Map<String, dynamic> json) {
    if (json['todos'] != null) {
      todos = <Todos>[];
      json['todos'].forEach((v) {
        todos!.add(Todos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (todos != null) {
      data['todos'] = todos!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Todos {
  String? sId;
  String? title;
  String? description;
  bool? completed;
  String? priority;
  int? iV;

  Todos(
      {this.sId,
      this.title,
      this.description,
      this.completed,
      this.priority,
      this.iV});

  Todos.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    completed = json['completed'];
    priority = json['priority'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['completed'] = completed;
    data['priority'] = priority;
    data['__v'] = iV;
    return data;
  }
}
