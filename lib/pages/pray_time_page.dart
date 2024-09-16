import 'dart:async'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PrayTimePage extends StatefulWidget {
  @override
  _PrayTimePageState createState() => _PrayTimePageState();
}

class _PrayTimePageState extends State<PrayTimePage> {
  Map<String, String> prayerTimes = {};
  String currentTimeInJerusalem = '';
  bool isLoading = true;
  Timer? _timer;  

  @override
  void initState() {
    super.initState();

    fetchPrayerTimes();

    tz.initializeTimeZones();
    getCurrentTimeInJerusalem();

    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => getCurrentTimeInJerusalem());
  }

  Future<void> fetchPrayerTimes() async {
    final url = Uri.parse(
      'http://api.aladhan.com/v1/timingsByCity?city=Jerusalem&country=Palestine'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        prayerTimes = {
          "الفجر": convertToArabicDigits(formatTime(data['data']['timings']['Fajr'])),
          "الظهر": convertToArabicDigits(formatTime(data['data']['timings']['Dhuhr'])),
          "العصر": convertToArabicDigits(formatTime(data['data']['timings']['Asr'])),
          "المغرب": convertToArabicDigits(formatTime(data['data']['timings']['Maghrib'])),
          "العشاء": convertToArabicDigits(formatTime(data['data']['timings']['Isha'])),
        };
        isLoading = false;
      });
    }
  }

  String formatTime(String time) {
    final parsedTime = DateFormat('HH:mm').parse(time);
    return DateFormat('h:mm a').format(parsedTime);
  }

  String convertToArabicDigits(String input) {
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < englishDigits.length; i++) {
      input = input.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return input;
  }

  void getCurrentTimeInJerusalem() {
    final jerusalem = tz.getLocation('Asia/Jerusalem');
    final nowInJerusalem = tz.TZDateTime.now(jerusalem);
    String formattedTime = DateFormat('h:mm').format(nowInJerusalem); // Time without AM/PM
    String period = DateFormat('a').format(nowInJerusalem); // AM/PM part

    setState(() {
      currentTimeInJerusalem = '$period $formattedTime';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    'images/rug.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xff228B22),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "مواعيد الأذان",
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
                    'images/mosque.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 26),
                child: Text(
                  "مواعيد الأذان بتوقيت مدينة القدس عاصمة فلسطين",
                  style: TextStyle(
                    color: Color(0xff228B22),
                    fontSize: 18,
                    fontFamily: 'Zain',
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 12, bottom: 26),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xff228B22)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prayerTimes.entries.map((entry) {
                      return PrayerTimeCard(
                        prayer: entry.key,
                        time: entry.value,
                        img: prayerImage(entry.key),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              '$currentTimeInJerusalem  الوقت الحالي في القدس',
              style: TextStyle(
                color: Color(0xff228B22),
                fontSize: 24,
                fontFamily: 'Zain',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PrayerTimeCard extends StatelessWidget {
  final Image img;
  final String prayer;
  final String time;

  const PrayerTimeCard({required this.prayer, required this.time, required this.img});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(top: 10,bottom: 10),
          child: ListTile(
            leading: img,
            title: Text(
              prayer,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff228B22),
                fontFamily: 'Zain',
              ),
            ),
            trailing: Text(
              time,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xff228B22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Image prayerImage(String time){
  if(time=="الفجر"){
    return Image.asset('images/fajr.png', width: 80, height: 80, fit: BoxFit.contain);
  }
  else if(time=="الظهر"){
    return Image.asset('images/dhuhr.png', width: 80, height: 80, fit: BoxFit.contain);
  }
  else if(time=="العصر"){
    return Image.asset('images/asr.png', width: 80, height: 80, fit: BoxFit.contain);
  }
  else if(time=="المغرب"){
    return Image.asset('images/maghrib.png', width: 80, height: 80, fit: BoxFit.contain);
  }
  else if(time=="العشاء"){
    return Image.asset('images/isha.png', width: 80, height: 80, fit: BoxFit.contain);
  }
  
  return Image.asset('images/default.png', width: 80, height: 80, fit: BoxFit.contain);
}
