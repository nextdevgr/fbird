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
  double gravity = -6; // Βαρύτητα
  double velocity = 2; // Ταχύτητα άλματος
  bool gameHasStarted = false;
  Timer? gameTimer;
  int score = 0; // Σκορ
  List<double> pipeX = [2, 3.5, 5];
  double pipeWidth = 0.2;
  double gap = 0.3;
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
    score = 0; // Επαναφορά σκορ
    time = 0; // Επαναφορά χρόνου

    gameTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      time += 0.03;
      height = gravity * time * time + velocity * time;

      // Ελέγχουμε αν η κατάσταση της οθόνης είναι ακόμα ενεργή
      if (mounted) {
        setState(() {
          birdY = initialPos - height;

          for (int i = 0; i < pipeX.length; i++) {
            pipeX[i] -= 0.05;

            if (pipeX[i] < -1.5) {
              pipeX[i] += 3.5;
              pipeHeights[i] = _generatePipeHeights();
            }
          }

          if (birdY > 1 || birdY < -1 || _checkCollision()) {
            gameOver(timer);
          }
        });
      }

      if (gameHasStarted) {
        score += 1; // Αύξηση σκορ
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel(); // Ακυρώνουμε τον gameTimer για να αποτρέψουμε την εκτέλεση μετά την αποδέσμευση
    super.dispose();
  }



  bool _checkCollision() {
    for (int i = 0; i < pipeX.length; i++) {
      // Έλεγχος αν το πουλί είναι εντός των οριζόντιων ορίων ενός σωλήνα
      if (pipeX[i] > -0.1 && pipeX[i] < 0.1) {
        double pipeTop = 1 - pipeHeights[i][1]; // Κάτω όριο του πάνω σωλήνα
        double pipeBottom = -1 + pipeHeights[i][0]; // Πάνω όριο του κάτω σωλήνα

        // Έλεγχος αν το πουλί είναι εκτός του κατακόρυφου κενου μεταξύ των σωλήνων
        if (birdY < pipeBottom || birdY > pipeTop) {
          return true; // Βρέθηκε σύγκρουση
        }
      }
    }
    return false; // Δεν βρέθηκε σύγκρουση
  }

  void gameOver(Timer timer) {
    timer.cancel();
    gameHasStarted = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your Score: ${score ~/ 30} seconds'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      birdY = 0;
      initialPos = 0;
      height = 0;
      time = 0;
      pipeX = [2, 3.5, 5];
      pipeHeights = [
        [0.4, 0.6],
        [0.3, 0.5],
        [0.5, 0.4],
      ];
    });
  }

  List<double> _generatePipeHeights() {
    double minHeight = 0.2;
    double maxHeight = 0.6;
    double bottomPipeHeight =
        minHeight + (maxHeight - minHeight) * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;

    double topPipeHeight = 1.0 - bottomPipeHeight - gap;

    return [bottomPipeHeight, topPipeHeight];
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
                color: Colors.white,
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
                      child: Image.asset(
                        'images/bird.gif',
                        height: 100,
                        width: 100,
                      ),
                    ),
                    if (!gameHasStarted)
                      Center(
                        child: Text(
                          'TAP TO PLAY',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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
        ),
      ),
    );
  }
}
