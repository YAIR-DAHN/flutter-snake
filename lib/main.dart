import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(SnakeGame());
}

class SnakeGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Snake',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Future Snake'),
        ),
        body: Snake(),
      ),
    );
  }
}

class Snake extends StatefulWidget {
  @override
  _SnakeState createState() => _SnakeState();
}

class _SnakeState extends State<Snake> {
  final int rows = 20;
  final int columns = 20;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Random random = Random();

  List<int> snake = [45, 65];
  int food = 0;
  var direction = 'up';
  var isPlaying = false;

  void startGame() {
    const duration = Duration(milliseconds: 300);
    snake = [45, 65];
    snake.insert(0, snake.last);
    createFood();
    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (!isPlaying) {
        timer.cancel();
      }
    });
  }

  void createFood() {
    food = random.nextInt(rows * columns);
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          if (snake.first < columns) {
            isPlaying = false;
          } else {
            snake.insert(0, snake.first - columns);
          }
          break;
        case 'down':
          if (snake.first >= (rows - 1) * columns) {
            isPlaying = false;
          } else {
            snake.insert(0, snake.first + columns);
          }
          break;
        case 'left':
          if (snake.first % columns == 0) {
            isPlaying = false;
          } else {
            snake.insert(0, snake.first - 1);
          }
          break;
        case 'right':
          if ((snake.first + 1) % columns == 0) {
            isPlaying = false;
          } else {
            snake.insert(0, snake.first + 1);
          }
          break;
      }
      if (snake.first == food) {
        createFood();
      } else {
        snake.removeLast();
      }
      if (!isPlaying) {
        showLostDialog();
      }
    });
  }

  void showLostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('נפסלת', textAlign: TextAlign.right,),
          content: Text('לא נורא, תמיד אפשר לנסות שוב', textAlign: TextAlign.right,),
          actions: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 1,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    startGame();
                  },
                  child: Text('רענן'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (direction != 'up' && details.delta.dy > 0) {
          direction = 'down';
        } else if (direction != 'down' && details.delta.dy < 0) {
          direction = 'up';
        }
      },
      onHorizontalDragUpdate: (details) {
        if (direction != 'left' && details.delta.dx > 0) {
          direction = 'right';
        } else if (direction != 'right' && details.delta.dx < 0) {
          direction = 'left';
        }
      },
      onTap: () {
        if (!isPlaying) {
          startGame();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Center(
          child: AspectRatio(
            aspectRatio: columns / (rows + 4),
            child: Container(
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemBuilder: (BuildContext context, int index) {
                  var color;
                  if (snake.contains(index)) {
                    color = Colors.green;
                  } else if (index == food) {
                    color = Colors.red;
                  } else {
                    color = Colors.grey[800];
                  }
                  return Container(
                    padding: EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: color,
                      ),
                    ),
                  );
                },
                itemCount: rows * columns,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
