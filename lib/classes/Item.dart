class Item{

  // Attributes
  String? _name; 
  int? _goal;
  int? _counter;
  int? _freqTime;


  //=====================================================================
  // Constructor
  Item({required String? name, int? goal=1, int? counter=0, int? freqTime=0}){ 
    this._name=name;
    this._goal=goal;
    this._counter=counter;
    this._freqTime=freqTime;
   }


  //=====================================================================
  // getter and setter

  // name
  get getItemName{
    return _name;
  }

  set setItemName(String? name){
    _name=name;
  }

  //-----------------------

  // goal
  get getItemGoal{
    return _goal;
  }

  void setItemGoal(int? goal){
    _goal=goal;
  }

  //-----------------------

  // counter
  get getItemCounter{
    return _counter;
  }

  void setItemCounter(int? counter){
    _counter=counter;
  }

  //-----------------------

  // freqency Time
  get getItemFreqTime{
    return _freqTime;
  }

  void setItemFreqTime(int? freqTime){
    _freqTime=freqTime;
  }

  
  //=====================================================================
  // Method


  // toString
  @override
  String toString() {
    return "Item name: "+"$_name"+", "+"Item goal: "+"$_goal"+", "+"Item counter: "+"$_counter"+", "+"Item freq_time: "+"$_freqTime";
  }


  // convert Item to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
    'name': _name,
    'goal': _goal,
    'counter': _counter,
    'freqTime': _freqTime,
  };

  // convert a Map (decoded from JSON) back into an Item
  factory Item.fromJson(Map<String, dynamic> jsonData) {
    return Item(
      name: jsonData['name'],
      goal: jsonData['goal'],
      counter: jsonData['counter'],
      freqTime: jsonData['freqTime'],
    );
  }
  
}

  