class Remembrance{

  // Attributes
  int? _color; 
  String? _title;
  String? _content;


  //=====================================================================
  // Constructor
  Remembrance({required int? color, required String? title, required String? content}){ 
    this._color=color;
    this._title=title;
    this._content=content;
   }


  //=====================================================================
  // getter and setter

  // color
  get getRemembranceColor{
    return _color;
  }

  set setRemembranceColor(int? color){
    _color=color;
  }

  //-----------------------

  // title
  get getRemembranceTitle{
    return _title;
  }

  void setRemembranceTitle(String? title){
    _title=title;
  }

  //-----------------------

  // content
  get getRemembranceContent{
    return _content;
  }

  void setRemembranceContent(String? content){
    _content=content;
  }

  
  //=====================================================================
  // Method


  // toString
  @override
  String toString() {
    return "Remembrance color: "+"$_color"+", "+"Remembrance title: "+"$_title"+", "+"Remembrance content: "+"$_content";
  }


  // convert Remembrance to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
    'color': _color,
    'title': _title,
    'content': _content,
  };

  // convert a Map (decoded from JSON) back into an Remembrance
  factory Remembrance.fromJson(Map<String, dynamic> jsonData) {
    return Remembrance(
      color: jsonData['color'],
      title: jsonData['title'],
      content: jsonData['content'],
    );
  }
  
}

  