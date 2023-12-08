import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful Meal Timer',
      debugShowCheckedModeBanner: false,
      home: PageContainer(),
    );
  }
}

class PageContainer extends StatelessWidget {
  final PageController controller = PageController();

  PageContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: [
                MindfulMealTimer(
                  title: 'Nom Nom :)',
                  description: 'You have ${formatTime(30)} seconds remaining. Focus on eating slowly',
                ),
                const MindfulMealTimer(
                  title: 'Break time',
                  description: 'Take a five-minute break to check in your level of fullness',
                ),
                const MindfulMealTimer(
                  title: 'Finish your meal',
                  description: 'You can eat until you feel full',
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MindfulMealTimer extends StatefulWidget {
  final String title;
  final String description;

  const MindfulMealTimer({super.key, 
    required this.title,
    required this.description,
  });

  @override
  _MindfulMealTimerState createState() => _MindfulMealTimerState();
}

class _MindfulMealTimerState extends State<MindfulMealTimer> {
  bool isSoundOn = true;
  bool isTimerRunning = false;
  int timerDuration = 30;
  int currentTime = 30; 

  
  final AudioPlayer audioPlayer = AudioPlayer();

  late Timer timer;

  void startTimer() {
    if (!isTimerRunning) {
      setState(() {
        isTimerRunning = true;
      });

      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (currentTime == 0) {
          t.cancel();
          resetTimer();
          playSound(); 
        } else {
          setState(() {
            currentTime--;
          });

          if (currentTime <= 5 && isSoundOn && currentTime > 0) {
            playSound();
          }
        }
      });
    }
  }

  void playSound() async {
    try {
      await audioPlayer.play(
        AssetSource('countdown_tick.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void pauseTimer() {
    if (isTimerRunning) {
      setState(() {
        isTimerRunning = false;
      });
      timer.cancel();
    }
  }

  void resetTimer() {
    setState(() {
      isTimerRunning = false;
      currentTime = timerDuration;
    });
    timer.cancel();
  }

  @override
  void dispose() {
    timer.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Mindful Meal Timer',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[200],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[600]!,
                  width: 10,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.green,
                        width: 5,
                      ),
                    ),
                    child: CustomPaint(
                      painter: ClockMarkingsPainter(),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${currentTime ~/ 60}:${(currentTime % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isTimerRunning ? Colors.black : Colors.grey[600]!,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'minutes remaining',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600]!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Switch(
              value: isSoundOn,
              onChanged: (value) {
                setState(() {
                  isSoundOn = value;
                });
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
            ),
            const SizedBox(
              height: 1,
            ),
            Text(
              'Sound On',
              style: TextStyle(
                fontSize: 16,
                color: isSoundOn ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (!isTimerRunning)
              Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.lightGreen,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    startTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 224, 244, 201),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            if (isTimerRunning)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  Container(
                    width: 140,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        pauseTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 224, 244, 201),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Pause',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 140,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        resetTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Let's stop, I'm full now",
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    int remainingSeconds = seconds % 60;
    return '${remainingSeconds < 10 ? '0$remainingSeconds' : remainingSeconds}';
  }
}

class ClockMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    final Paint boldPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    
    const double boldMarkingLength = 24.0;
    const double smallMarkingLength = 8.0;
    const int totalLargeMarkings = 4;
    const int totalSmallMarkings = 14;

    // Draw large bold markings at 12, 3, 6, and 9 o'clock positions
    for (int i = 0; i < totalLargeMarkings; i++) {
      final double angle = -pi / 2 + i * (pi / 2);
      final double x1 = centerX + (radius - boldMarkingLength) * cos(angle);
      final double y1 = centerY + (radius - boldMarkingLength) * sin(angle);
      final double x2 = centerX + radius * cos(angle);
      final double y2 = centerY + radius * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), boldPaint);
    }

 
    for (int i = 1; i <= totalSmallMarkings; i++) {
     
      final double angle12to3 = -pi / 2 + (i - 1) * (pi / totalSmallMarkings);
      final double x1_12to3 = centerX + (radius - smallMarkingLength) * cos(angle12to3);
      final double y1_12to3 = centerY + (radius - smallMarkingLength) * sin(angle12to3);
      final double x2_12to3 = centerX + radius * cos(angle12to3);
      final double y2_12to3 = centerY + radius * sin(angle12to3);
      canvas.drawLine(Offset(x1_12to3, y1_12to3), Offset(x2_12to3, y2_12to3), paint);

    
      final double angle3to6 = -pi / 2 + pi / 2 + (i - 1) * (pi / totalSmallMarkings);
      final double x1_3to6 = centerX + (radius - smallMarkingLength) * cos(angle3to6);
      final double y1_3to6 = centerY + (radius - smallMarkingLength) * sin(angle3to6);
      final double x2_3to6 = centerX + radius * cos(angle3to6);
      final double y2_3to6 = centerY + radius * sin(angle3to6);
      canvas.drawLine(Offset(x1_3to6, y1_3to6), Offset(x2_3to6, y2_3to6), paint);

      
      final double angle6to9 = -pi / 2 + pi + (i - 1) * (pi / totalSmallMarkings);
      final double x1_6to9 = centerX + (radius - smallMarkingLength) * cos(angle6to9);
      final double y1_6to9 = centerY + (radius - smallMarkingLength) * sin(angle6to9);
      final double x2_6to9 = centerX + radius * cos(angle6to9);
      final double y2_6to9 = centerY + radius * sin(angle6to9);
      canvas.drawLine(Offset(x1_6to9, y1_6to9), Offset(x2_6to9, y2_6to9), paint);

      
      final double angle9to12 = -pi / 2 + 3 * pi / 2 + (i - 1) * (pi / totalSmallMarkings);
      final double x1_9to12 = centerX + (radius - smallMarkingLength) * cos(angle9to12);
      final double y1_9to12 = centerY + (radius - smallMarkingLength) * sin(angle9to12);
      final double x2_9to12 = centerX + radius * cos(angle9to12);
      final double y2_9to12 = centerY + radius * sin(angle9to12);
      canvas.drawLine(Offset(x1_9to12, y1_9to12), Offset(x2_9to12, y2_9to12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

String formatTime(int seconds) {
  int remainingSeconds = seconds % 60;
  return '${remainingSeconds < 10 ? '0$remainingSeconds' : remainingSeconds}';
}
