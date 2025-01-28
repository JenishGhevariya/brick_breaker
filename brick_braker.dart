import 'dart:async';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Ball position and velocity
  double ballX = 0;
  double ballY = 0;
  double ballXDirection = 1; // 1 for right, -1 for left
  double ballYDirection = -1; // 1 for down, -1 for up

  // Paddle position
  double paddleX = 0;

  // Brick state
  List<List<bool>> bricks =
      List.generate(5, (i) => List.generate(6, (j) => true));

  // Game state
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        // Update ball position
        ballX += 0.01 * ballXDirection;
        ballY += 0.01 * ballYDirection;

        // Wall collision
        if (ballX <= -1 || ballX >= 1) ballXDirection *= -1;
        if (ballY <= -1) ballYDirection *= -1;

        // Paddle collision
        if (ballY >= 0.9 && ballX >= paddleX - 0.2 && ballX <= paddleX + 0.2) {
          ballYDirection *= -1;
        }

        // Brick collision
        for (int i = 0; i < bricks.length; i++) {
          for (int j = 0; j < bricks[i].length; j++) {
            if (bricks[i][j]) {
              double brickTop = -0.8 + (i * 0.2);
              double brickLeft = -1 + (j * 0.4);
              double brickRight = brickLeft + 0.4;

              if (ballY <= brickTop + 0.1 &&
                  ballY >= brickTop &&
                  ballX >= brickLeft &&
                  ballX <= brickRight) {
                bricks[i][j] = false;
                ballYDirection *= -1;
              }
            }
          }
        }

        // Game over
        if (ballY >= 1) {
          isPlaying = false;
          showGameOverDialog();
        }
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You lost! Press restart to play again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restartGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void restartGame() {
    setState(() {
      ballX = 0;
      ballY = 0;
      ballXDirection = 1;
      ballYDirection = -1;
      paddleX = 0;
      bricks = List.generate(5, (i) => List.generate(6, (j) => true));
      isPlaying = true;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  paddleX +=
                      details.delta.dx / MediaQuery.of(context).size.width;
                  paddleX = paddleX.clamp(-1.0, 1.0);
                });
              },
              child: Stack(
                children: [
                  // Ball
                  Align(
                    alignment: Alignment(ballX, ballY),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Paddle
                  Align(
                    alignment: Alignment(paddleX, 0.95),
                    child: Container(
                      width: 100,
                      height: 20,
                      color: Colors.blue,
                    ),
                  ),
                  // Bricks
                  for (int i = 0; i < bricks.length; i++)
                    for (int j = 0; j < bricks[i].length; j++)
                      if (bricks[i][j])
                        Align(
                          alignment:
                              Alignment(-1 + j * 0.4 + 0.2, -0.8 + i * 0.2),
                          child: Container(
                            width: 80,
                            height: 30,
                            color: Colors.red,
                          ),
                        ),
                ],
              ),
            ),
          ),
          if (!isPlaying)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isPlaying = true;
                  startGame();
                });
              },
              child: const Text('Start Game'),
            ),
        ],
      ),
    );
  }
}
