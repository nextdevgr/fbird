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

  List<double> pipeX = [2, 3.5, 5];
  double pipeWidth = 0.2; //
  double gap = 0.3; //
  List<List<double>> pipeHeights = [
    [0.4, 0.6],
    [0.3, 0.5],
    [0.5, 0.4],
  ];

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

        for (int i = 0; i < pipeX.length; i++) {
          pipeX[i] -= 0.05;

          if (pipeX[i] < -1.5) {
            pipeX[i] += 3.5;
            pipeHeights[i] = _generatePipeHeights();
          }
        }

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

  List<double> _generatePipeHeights() {
    double minHeight = 0.2;
    double maxHeight = 0.6;
    double bottomPipeHeight =
        minHeight + (maxHeight - minHeight) * (new DateTime.now().millisecondsSinceEpoch % 1000) / 1000;

    double topPipeHeight = 1.0 - bottomPipeHeight - gap;

    return [bottomPipeHeight, topPipeHeight];
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
              flex: 3,
              child: Container(
                color: Colors.blue,
                child: Stack(
                  children: [
                    for (int i = 0; i < pipeX.length; i++) ...[
                      Pipe(
                        pipeX[i],
                        pipeHeights[i][0],
                        pipeWidth,
                        true,
                      ),
                      Pipe(
                        pipeX[i],
                        pipeHeights[i][1],
                        pipeWidth,
                        false,
                      ),
                    ],
                    AnimatedContainer(
                      alignment: Alignment(0, birdY),
                      duration: Duration(milliseconds: 0),
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
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

class Pipe extends StatelessWidget {
  final double pipeX;
  final double pipeHeight;
  final double pipeWidth;
  final bool isBottom;

  Pipe(this.pipeX, this.pipeHeight, this.pipeWidth, this.isBottom);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(pipeX, isBottom ? 1 : -1),
      child: Container(
        width: MediaQuery.of(context).size.width * pipeWidth,
        height: MediaQuery.of(context).size.height * pipeHeight / 2,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
