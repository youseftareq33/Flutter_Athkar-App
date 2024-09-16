import 'dart:convert';

import 'package:athkar_app/classes/Item.dart';
import 'package:athkar_app/pages/morning_remembrances_page.dart';
import 'package:athkar_app/pages/night_remembrances_page.dart';
import 'package:athkar_app/pages/pray_time_page.dart';
import 'package:athkar_app/pages/prays_ma2thora.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int colorHex=0xff0A5C36;
  TextDirection textDirection=TextDirection.rtl;
  bool isActiveColor=false;
  bool isFloat=true;
  bool isUpdated=false;
  int sum=0;
  int total=0;

  bool isHoldingIncrease = false;
  bool isHoldingDecrease = false;
  double ripple_effect_Opacity=0.14;

  final ScrollController itemController = ScrollController();
  TextEditingController newItemController = TextEditingController();
  final _formKey=GlobalKey<FormState>();

  List<Item> l_item=[];
  Item? selectedItem;
  Item? longPressedItem;

  setColor(int value) async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.setInt('color', value);
    getColor();
  }

  getColor() async{
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    setState(() {
      colorHex=prefs.getInt('color') ?? 0xff0A5C36;
    });    
  }
  // Function to store the list of items
  Future<void> storeItems(List<Item> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert each item to JSON and store as a List of Strings
    List<String> itemsJsonList = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('itemsKey', itemsJsonList);
  }

  // Function to retrieve the list of items
  Future<List<Item>> retrieveItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemsJsonList = prefs.getStringList('itemsKey'); // Retrieve JSON list from SharedPreferences
    if (itemsJsonList != null) {
      // Convert each JSON string back to Item
      return itemsJsonList.map((itemJson) => Item.fromJson(jsonDecode(itemJson))).toList();
    } else {
      return []; // Return empty list if no items are found
    }
  }

  Future<bool> isFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true; 
  }

  Future<void> setFirstTimeFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); 
  }
  

  void _openAddItemDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (BuildContext context) {
        return Align(

          alignment: Alignment.topCenter,

          child: Directionality(
            textDirection: textDirection,

            child: Dialog(
              insetPadding: EdgeInsets.only(bottom: 30), 

              child: Container(
                width: 300,
                height: 310,
                padding: EdgeInsets.all(20),
                
                child: Column(
                  children: [

                    // Top ------------------------------------------------------------- (close button and text)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Text(
                            "إضافة عنصر", 
                            style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.red, 
                            shape: BoxShape.circle, 
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white, size: 25,), 
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              newItemController.clear();
                              saveData();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),



                    // Center ------------------------------------------------------------- (Text Field)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 35),
                        child: Column(
                          children: [ 
                            Form(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "العنصر :  ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                        if(value!.isEmpty){
                                          return "الرجاء إدخال العنصر";
                                        }
                                        else{
                                          return null;
                                        }
                                      },
                                    controller: newItemController,
                                    decoration: InputDecoration(
                                      hintText: "أدخل العنصر الجديد",
                                      hintStyle: TextStyle(color: Colors.black),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.black,),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),



                    // Bottom ------------------------------------------------------------- (Done Button)                  
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() { 
                            if(_formKey.currentState!.validate()){
                                l_item.add(Item(name: newItemController.text));
                                saveData();
                                Navigator.of(context).pop();

                                Future.delayed(Duration(milliseconds: 100), () {
                                  if (itemController.hasClients) {
                                    itemController.animateTo(
                                      itemController.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                            }
                            newItemController.clear();

                            
                          });
                        },
                        label: Center(
                          child: Text(
                            'تم', 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> getData() async {
    bool firstTime = await isFirstTime();
    
    if (firstTime) {
      setState(() {
        l_item = [
          Item(name: "الإستغفار"),
          Item(name: "التسبيح"),
          Item(name: "الصلاة على النبي"),
        ];

        selectedItem = l_item[0];
      });
      
      await saveData(); 
      await setFirstTimeFlag(); 
    } else {
      List<Item> l_new_item = await retrieveItems();
      setState(() {
        if (l_new_item.isNotEmpty) {
          l_item = l_new_item;
          selectedItem = l_item[0];
        }
      });
    }

    getColor();
  }

  Future<void> saveData() async {
    await storeItems(l_item);
  }



  @override
  void initState() {
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {

    Color mainColor=Color(colorHex);
    sum=(selectedItem?.getItemFreqTime ?? 0) * (selectedItem?.getItemGoal ?? 0) + (selectedItem?.getItemCounter ?? 0);
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // app bar -----------------------------------
        appBar: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 10),

              child: PopupMenuButton<String>(
                icon: Icon(isActiveColor ? null : Icons.menu, color: Colors.white,),
                onSelected: (String value) {
                  if (value == 'op1') {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MorningRemembrancesPage(),
                        ),
                      );
                    });
                  } 
                  else if (value == 'op2') {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NightRemembrancesPage(),
                        ),
                      );
                    });
                  }
                  else if (value == 'op3') {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PraysMa2thoraPage(),
                        ),
                      );
                    });
                  }
                  else if (value == 'op4') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayTimePage(),
                      ),
                    );
                  }
                  else if (value == 'op5') {
                    setState(() {
                      isActiveColor=!isActiveColor;
                      isFloat=!isFloat;
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[200],
                elevation: 8,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  
                  // option 1: morning remembrances
                  const PopupMenuItem<String>(
                    value: 'op1',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
              
                        Icon(Icons.sunny, color: Color.fromARGB(255, 222, 152, 0)),
              
                        Text(
                          "أذكار الصباح",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
              
                      ],
                    ),
                  ),
              
                  const PopupMenuDivider(),
              
                  // option 2: evening remembrances
                  const PopupMenuItem<String>(
                    value: 'op2',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       
                        Icon(Icons.nightlight_round, color: Color.fromARGB(255, 30, 18, 71)),
              
                         Text(
                          "أذكار المساء",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
              
                      ],
                    ),
                  ),
              
                  const PopupMenuDivider(),
              
                  // option 3: pray
                  const PopupMenuItem<String>(
                    value: 'op3',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Icon(LineIcons.pray, color: Color.fromARGB(255, 126, 190, 30)),
              
                        Text(
                          "أدعية مأثورة",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
              
                      ],
                    ),
                  ),
              
                  const PopupMenuDivider(),
              
                  // option 4: Aladan
                  const PopupMenuItem<String>(
                    value: 'op4',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Icon(LineIcons.mosque, color: Color.fromARGB(255, 40, 180, 56)),
              
                        Text(
                          "مواعيد الصلاة",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
              
                      ],
                    ),
                  ),
              
                  const PopupMenuDivider(),
              
                  // option 5: change color
                  const PopupMenuItem<String>(
                    value: 'op5',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        
                        Icon(Icons.color_lens, color: Colors.redAccent),
              
                        Text(
                          "تغيير الألوان",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
              
                      ],
                    ),
                  ),
                 
                ],
              ),
            ),
          ],
        ),

        // app body -----------------------------------
        body: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: mainColor,
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(child: Text("الهدف", style: TextStyle(color: Colors.white, fontSize: 28),),),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      // increment goal button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedItem!.setItemGoal(selectedItem!.getItemGoal + 1);
                            isUpdated=true;
                          });
                        },
                        onLongPressStart: (details) async {
                          setState(() {
                            isHoldingIncrease = true;
                            isUpdated=true;
                          });
                          int elapsedTime = 0;

                          while (isHoldingIncrease) {
                            setState(() {
                              selectedItem!.setItemGoal(selectedItem!.getItemGoal + 1);
                            });

                            await Future.delayed(const Duration(milliseconds: 500));

                            elapsedTime += 500;
                            int speedTime=400;
                            if (elapsedTime >= 700) {
                              while (isHoldingIncrease) {
                                setState(() {
                                  selectedItem!.setItemGoal(selectedItem!.getItemGoal + 1);
                                });

                                if(speedTime>100){
                                  speedTime-=50;
                                  setState(() {
                                    ripple_effect_Opacity+=0.04;
                                  });
                                }

                                await Future.delayed(Duration(milliseconds: speedTime));
                              }
                            }
                          }
                        },
                        onLongPressEnd: (details) {
                          setState(() {
                            isHoldingIncrease = false;
                            ripple_effect_Opacity=0.14;
                          });
                        },
                        child: Material(
                          color: isHoldingIncrease ? Colors.white.withOpacity(ripple_effect_Opacity) : Colors.transparent, 
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedItem!.setItemGoal(selectedItem!.getItemGoal + 1);
                                isUpdated=true;
                              });
                            },
                            splashColor: isHoldingIncrease ? Colors.transparent : Colors.white.withOpacity(ripple_effect_Opacity), 
                            highlightColor: Colors.transparent, 
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 53, 
                              height: 53, 
                              child: Center(
                                child: Icon(Icons.add_circle, color: Colors.white, size: 37),
                              ),
                            ),
                          ),
                        ),
                      ),

                      

                      // goal text
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
                        child: Text("${selectedItem?.getItemGoal ?? 0}", style: TextStyle(color: Colors.white, fontSize: 32),),
                      ),


                      // decrement goal button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if(selectedItem!.getItemGoal>1 && selectedItem!.getItemGoal!=selectedItem!.getItemCounter){
                              selectedItem!.setItemGoal(selectedItem!.getItemGoal - 1);
                              isUpdated=true;
                            }
                          });
                        },
                        onLongPressStart: (details) async {
                          setState(() {
                            isHoldingDecrease = true;
                            isUpdated=true;
                          });
                          int elapsedTime = 0;

                          while (isHoldingDecrease) {
                            setState(() {
                              if(selectedItem!.getItemGoal>1 && selectedItem!.getItemGoal!=selectedItem!.getItemCounter){
                                selectedItem!.setItemGoal(selectedItem!.getItemGoal - 1);
                              }
                            });

                            await Future.delayed(const Duration(milliseconds: 500));

                            elapsedTime += 500;
                            int speedTime=400;
                            if (elapsedTime >= 700) {
                              while (isHoldingDecrease) {
                                setState(() {
                                  if(selectedItem!.getItemGoal>1 && selectedItem!.getItemGoal!=selectedItem!.getItemCounter){
                                    selectedItem!.setItemGoal(selectedItem!.getItemGoal - 1);
                                  }
                                });

                                if(speedTime>100){
                                  speedTime-=50;
                                  setState(() {
                                    ripple_effect_Opacity+=0.04;
                                  });
                                }

                                await Future.delayed(Duration(milliseconds: speedTime));
                              }
                            }
                          }
                        },
                        onLongPressEnd: (details) {
                          setState(() {
                            isHoldingDecrease = false;
                            ripple_effect_Opacity=0.14;
                          });
                        },
                        child: Material(
                          color: isHoldingDecrease ? Colors.white.withOpacity(ripple_effect_Opacity) : Colors.transparent, 
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if(selectedItem!.getItemGoal>1 && selectedItem!.getItemGoal!=selectedItem!.getItemCounter){
                                  selectedItem!.setItemGoal(selectedItem!.getItemGoal - 1);
                                  isUpdated=true;
                                }
                              });
                            },
                            splashColor: isHoldingDecrease ? Colors.transparent : Colors.white.withOpacity(ripple_effect_Opacity), 
                            highlightColor: Colors.transparent, 
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 53, 
                              height: 53, 
                              child: Center(
                                child: Icon(Icons.remove_circle, color: Colors.white, size: 37),
                              ),
                            ),
                          ),
                        ),
                      ), 
                    ],
                  ),


                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 18, right: 18, top: 3, bottom: 2),
                      child: ListView.builder(
                        controller: itemController,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemCount: l_item.length + 1, // +1 for the Add button
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Add button at the beginning
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _openAddItemDialog(); // Assuming this opens the dialog to add a new item
                                  },
                                  child: Container(
                                    height: 49,
                                    padding: EdgeInsets.only(left: 18, right: 18, top: 3, bottom: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color.fromARGB(255, 210, 203, 203).withOpacity(0.9),
                                        width: 2.0,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.16),
                                          spreadRadius: 1,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: Color.fromARGB(255, 230, 223, 223).withOpacity(0.9),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "إضافة",
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 230, 223, 223).withOpacity(0.9),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = l_item[index - 1]; 
                          final isLongPressed = longPressedItem == item;

                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  longPressedItem = item;
                                });
                              },
                              onTap: () {
                                setState(() {
                                  isLongPressed ? null : selectedItem = item;
                                  longPressedItem = null;
                                });
                              },
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 50,
                                      padding: EdgeInsets.only(left: 18, right: 18, top: 3, bottom: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${item.getItemName}",
                                          style: TextStyle(
                                            color: selectedItem == item ? mainColor : Colors.black,
                                            fontWeight: selectedItem == item ? FontWeight.bold : null,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    bottom: isLongPressed ? 26.5 : -50,
                                    left: isLongPressed ? -11.2 : -50,
                                    child: AnimatedOpacity(
                                      duration: Duration(milliseconds: 300),
                                      opacity: isLongPressed ? 1.0 : 0.0,
                                      child: IconButton(
                                        icon: Icon(Icons.remove_circle, size: 17),
                                        color: Colors.grey,
                                        onPressed: () {
                                          setState(() {
                                            l_item.remove(item);
                                            saveData();
                                            longPressedItem = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),



                ],
              ),
            ),


            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
      
                Text("${selectedItem?.getItemName ?? ""}" , style: TextStyle(color: mainColor, fontSize: 22),),
                
                const SizedBox(
                  height: 4,
                ),
      
                Text("${selectedItem?.getItemCounter ?? 0}" , style: TextStyle(color: mainColor, fontSize: 22),),
                
                const SizedBox(
                  height: 20,
                ),
      
                
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 5.0,
                  percent: (selectedItem?.getItemGoal ?? 0) > 0 ? (selectedItem?.getItemCounter ?? 0) / (selectedItem?.getItemGoal ?? 1) : 0,
                  center: GestureDetector(
                    onTap: (){
                      setState(() {
                        if(selectedItem!.getItemCounter<selectedItem!.getItemGoal){
                          selectedItem!.setItemCounter(selectedItem!.getItemCounter+1);
                        }
                        else{
                          selectedItem!.setItemCounter(1);
                          selectedItem!.setItemFreqTime(selectedItem!.getItemFreqTime+1);
                        }     
                        isUpdated=false;
                        saveData();
                      });
                    },
                    child: Icon(
                      Icons.touch_app,
                      size: 50.0,
                      color: mainColor,
                    ),
                  ),
                  backgroundColor: mainColor.withOpacity(0.2),
                  progressColor: mainColor,
                ),
                
      
                const SizedBox(
                  height: 20,
                ),
      
                Text("مرات التكرار : ${selectedItem?.getItemFreqTime ?? 0}" , style: TextStyle(color: mainColor, fontSize: 22),),
                
                const SizedBox(
                  height: 15,
                ),
      
                Text(
                  "المجموع : ${isUpdated ? total : total = sum}",
                  style: TextStyle(color: mainColor, fontSize: 22),
                ),                
                const SizedBox(
                  height: 20,
                ),
      
              ],
            ),

            Spacer(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Visibility(
                visible: isActiveColor,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isActiveColor=!isActiveColor;
                          isFloat=!isFloat;
                        });
                      },
                      label: Center(
                        child: Text(
                          'تم',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(colorHex),
                      ),
                    ),

                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xff0A5C36)),
                      value: 0xff0A5C36,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),

                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xff14212A)),
                      value: 0xff14212A,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),

                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xffffc401)),
                      value: 0xffffc401,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),

                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xffB1001C)),
                      value: 0xffB1001C,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),

                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xff12699e)),
                      value: 0xff12699e,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),
                      
                    Radio(
                      fillColor: WidgetStateColor.resolveWith((State)=>Color(0xff62249F)),
                      value: 0xff62249F,
                      groupValue: colorHex,
                      onChanged: (val){
                        setState(() {
                          setColor(val!);
                        });
                    }),
                      
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: Visibility(
          visible: isFloat,
          child: FloatingActionButton(
            onPressed: (){
              setState(() {
                selectedItem!.setItemGoal(1);
                selectedItem!.setItemCounter(0);
                selectedItem!.setItemFreqTime(0);
                sum=0;
                total=0;
                saveData();
              });
            },
            backgroundColor: mainColor,
            child: Icon(Icons.refresh, color: Colors.white,),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999), 
            ),
          ),
        ),
      ),
    );
  }
}