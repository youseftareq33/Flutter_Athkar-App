import 'dart:convert';

import 'package:athkar_app/classes/Remembrance.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PraysMa2thoraPage extends StatefulWidget {
   PraysMa2thoraPage({super.key});

  @override
  State<PraysMa2thoraPage> createState() => _PraysMa2thoraPageState();
}

class _PraysMa2thoraPageState extends State<PraysMa2thoraPage> {

  TextDirection textDirection=TextDirection.rtl;

  final ScrollController remembranceController = ScrollController();
  TextEditingController newTitleRemembranceController = TextEditingController();
  TextEditingController newTextRemembranceController = TextEditingController();
  final _formKey=GlobalKey<FormState>();

  List<Remembrance> l_remembrance=[];
  Remembrance? selectedRemembrance;
  Remembrance? longPressedRemembrance;

  int colorHex=0xff0A5C36;
  bool userInteraction=false;

  // Function to store the list of Remembrance
  Future<void> storeRemembrances(List<Remembrance> remembrances) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert each item to JSON and store as a List of Strings
    List<String> remembrancesJsonList = remembrances.map((remembrance) => jsonEncode(remembrance.toJson())).toList();
    await prefs.setStringList('remembrancesKeyMa2thor', remembrancesJsonList);
  }

  // Function to retrieve the list of Remembrances
  Future<List<Remembrance>> retrieveRemembrances() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? remembrancesJsonList = prefs.getStringList('remembrancesKeyMa2thor'); 
    if (remembrancesJsonList != null) {
      // Convert each JSON string back to Remembrance
      return remembrancesJsonList.map((remembranceJson) => Remembrance.fromJson(jsonDecode(remembranceJson))).toList();
    } 
    else {
      return [];
    }
  }

  Future<bool> isFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTimeMa2thor') ?? true;
  }

  Future<void> setFirstTimeFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeMa2thor', false);
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
            child: StatefulBuilder( 
              builder: (BuildContext context, StateSetter setDialogState) {
                return Dialog(
                  insetPadding: EdgeInsets.only(bottom: 18),
                  child: Container(
                    width: 350,
                    height: 480,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Top ------------------------------------------------------------- (close button and text)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: Text(
                                "إضافة دعاء",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    newTitleRemembranceController.clear();
                                    newTextRemembranceController.clear();
                                    saveData(); 
                                    userInteraction=false;
                                    colorHex=0xff0A5C36;
                                    Navigator.of(context).pop(); 
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        // Center ------------------------------------------------------------- (Text Field)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "إختر اللون :  ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xff0A5C36)),
                                      value: 0xff0A5C36,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() { 
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xff14212A)),
                                      value: 0xff14212A,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xffffc401)),
                                      value: 0xffffc401,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xffB1001C)),
                                      value: 0xffB1001C,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xff12699e)),
                                      value: 0xff12699e,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                    Radio(
                                      fillColor: WidgetStateColor.resolveWith((State) => Color(0xff62249F)),
                                      value: 0xff62249F,
                                      groupValue: colorHex,
                                      onChanged: (val) {
                                        setDialogState(() {
                                          colorHex = val!;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),
                                Form(
                                  autovalidateMode: userInteraction ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "عنوان الدعاء :  ",
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
                                          if (value!.isEmpty) {
                                            return "الرجاء إدخال عنوان الدعاء";
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller: newTitleRemembranceController,
                                        decoration: InputDecoration(
                                          hintText: "أدخل عنوان الدعاء",
                                          hintStyle: TextStyle(color: Colors.black),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                        ),
                                      ),
                            
                                      SizedBox(
                                        height: 18,
                                      ),

                                      Text(
                                        "نص الدعاء :  ",
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
                                          if (value!.isEmpty) {
                                            return "الرجاء إدخال نص الدعاء";
                                          } else {
                                            return null;
                                          }
                                        },
                                        controller: newTextRemembranceController,
                                        scrollController: ScrollController(),
                                        maxLines: 2, 
                                        minLines: 1,   
                                        keyboardType: TextInputType.multiline, 
                                        decoration: InputDecoration(
                                          hintText: "أدخل نص الدعاء",
                                          hintStyle: TextStyle(color: Colors.black),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.black),
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
                              if (_formKey.currentState!.validate()) {
                                setState(() { 
                                  l_remembrance.add(Remembrance(
                                    color: colorHex, 
                                    title: newTitleRemembranceController.text, 
                                    content: newTextRemembranceController.text
                                  ));
                                });
                                
                                saveData();
                                userInteraction=false;
                                colorHex = 0xff0A5C36;
                                newTitleRemembranceController.clear();
                                newTextRemembranceController.clear();
                                
                                Navigator.of(context).pop();

                                Future.delayed(Duration(milliseconds: 100), () {
                                  if (remembranceController.hasClients) {
                                    remembranceController.animateTo(
                                      remembranceController.position.extentTotal,
                                      duration: Duration(milliseconds: 600),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              }
                              else{
                                setDialogState(() {
                                  userInteraction=true;
                                });
                              
                              }
                            },
                            label: Center(
                              child: Text(
                                'تم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
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
                );
              },
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
        l_remembrance = [
          Remembrance(color: 0xffB1001C, title: "قضاء الدين وسعة الرزق", content: "اللَّهُمَّ اغْفِرْ لِي، وَاهْدِنِي، وَارْزُقْنِي، وَعَافِنِي، أَعُوذُ بِاللَّهِ مِنْ ضِيقِ الْمَقَامِ يَوْمَ الْقِيَامَةِ"),
          Remembrance(color: 0xffffc401, title: "الإستغفار", content: "اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء لك بذنبي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت"),
          Remembrance(color: 0xff12699e, title: "دعاء ليلة القدر", content: "اللهم إنك عفو كريم تحب العفو، فاعفُ عني"),
          Remembrance(color: 0xff0A5C36, title: "دعاء صلاة القيام", content: "اللهم ربنا لك الحمد أنت قيّم السماوات والأرض، ولك الحمد أنت رب السماوات والأرض ومن فيهن، ولك الحمد أنت نور السماوات والأرض ومن فيهن، أنت الحق، وقولك الحق، ووعدك الحق، ولقاؤك الحق، والجنة حق، والنار حق، والساعة حق، اللهم: لك أسلمت، وبك آمنت، وعليك توكلت، وإليك خاصمت، وبك حاكمت، فاغفر لي: ما قدمت، وما أخرت، وأسررت، وأعلنت، وما أنت أعلم به مني، لا إله إلا أنت"),
          Remembrance(color: 0xff14212A, title: "أَفْضَلُ الذِّكْرِ", content: " لَا إِلَهَ إِلَّا اللهُ"),
          Remembrance(color: 0xff62249F, title: "أَفْضَلُ الدُّعَاءِ", content: "الْحَمْدُ للهِ"),
        ];
      });
      
      await saveData(); 
      await setFirstTimeFlag(); 
    } else {
      List<Remembrance> l_new_remembrances = await retrieveRemembrances();
      setState(() {
        l_remembrance = l_new_remembrances.isNotEmpty ? l_new_remembrances : [];
      });
    }
  }

  Future<void> saveData() async {
    await storeRemembrances(l_remembrance);
  }


  @override
  void initState() {
    super.initState();
    
    getData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    
      body: Directionality(
        textDirection: textDirection,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'images/pray.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(233, 50, 205, 50),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "أدعية مأثورة",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Fustat',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      'images/islam.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            
            
            SizedBox(
              height: 25,
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 18, right: 18, top: 3, bottom: 2),
                child: ListView.builder(
                  controller: remembranceController,
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  itemCount: l_remembrance.length + 1, // +1 for the Add button
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add button at the beginning
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () {
                              _openAddItemDialog(); 
                            },
                            child: Container(
                              height: 49,
                              // width: MediaQuery.sizeOf(context).width* 2/3 - 80,
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
                                    // spreadRadius: 1,
                                    // offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Color.fromARGB(255, 156, 153, 153).withOpacity(0.9),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "إضافة",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 156, 153, 153).withOpacity(0.9),
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
            
                    final remembrance = l_remembrance[index - 1]; 
                    final isLongPressed = longPressedRemembrance == remembrance;
                    
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 0, top: 20, bottom: 10),
                        child: GestureDetector(
                          onLongPress: () {
                            setState(() {
                              longPressedRemembrance = remembrance;
                            });
                          },
                          onTap: () {
                            setState(() {
                              isLongPressed ? null : selectedRemembrance = remembrance;
                              longPressedRemembrance = null;
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                // width: MediaQuery.sizeOf(context).width* 2/3 - 80,
                                // padding: EdgeInsets.only(left: 18, right: 18, top: 3, bottom: 2),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 241, 236, 236),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Container(
                                        height: 49,
                                        // width: MediaQuery.sizeOf(context).width* 2/3 - 65,
                                        decoration: BoxDecoration(
                                          color: Color(remembrance.getRemembranceColor),
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${remembrance.getRemembranceTitle}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 20, top: 15, right: 4, left: 4),
                                      child: Text(
                                        "${remembrance.getRemembranceContent}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Zain',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                top: isLongPressed ? 0 : -50,
                                left: isLongPressed ? -5 : -50,
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: isLongPressed ? 1.0 : 0.0,
                                  child: IconButton(
                                    icon: Icon(Icons.remove_circle, size: 17),
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        l_remembrance.remove(remembrance);
                                        saveData();
                                        longPressedRemembrance = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}