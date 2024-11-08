import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(FlappyBird());

class FlappyBird extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double birdY = 0;
  double initialPos = 0;
  double height = 0;
  double time = 0;
  double gravity = -9.8; // Αυξημένη βαρύτητα για ρεαλισμό
  double velocity = 4.0; // Μειωμένη ταχύτητα για ομαλότερο άλμα
  bool gameHasStarted = false;
  Timer? gameTimer;

  void jump() {
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  void startGame() {
    gameHasStarted = true;
    gameTimer = Timer.periodic(Duration(milliseconds: 30), (timer) { // πιο συχνό update για smooth κίνηση
      time += 0.03; // μικρότερα διαστήματα για ρεαλισμό
      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPos - height;

        if (birdY < -1) {
          birdY = -1;
        }
      });

      if (birdY > 1) {
        timer.cancel();
        gameHasStarted = false;
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: AnimatedContainer(
                    alignment: Alignment(0, birdY),
                    duration: Duration(milliseconds: 0),
                    child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
