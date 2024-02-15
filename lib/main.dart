import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Snake',
      theme: ThemeData.dark(),
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'פלאטר סנייק',
              textAlign: TextAlign.right,
            ),
          ),
          body: const Snake()),
    );
  }
}

class Snake extends StatefulWidget {
  const Snake({super.key});
  @override
  SnakeState createState() => SnakeState();
}

class SnakeState extends State<Snake> {
  final int rows = 20;
  final int columns = 20;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Random random = Random();

  // List<int> snake = [45, 65];
  List<int> snake = [126, 106];
  int food = 0;
  var direction = 'start';
  var isPlaying = false;

  void startGame() {
    const duration = Duration(milliseconds: 300);
    snake = [126, 106];
    snake.insert(2, snake.last);
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
        case 'start':
          snake.insert(0, snake.first + columns);
          direction = 'down';
          break;

        case 'up':
          if (snake.first < columns || collisionTest(snake.first, snake)) {
            falseGame();
          } else {
            snake.insert(0, snake.first - columns);
          }
          break;
        case 'down':
          if (snake.first >= (rows - 1) * columns ||
              collisionTest(snake.first, snake)) {
            falseGame();
          } else {
            snake.insert(0, snake.first + columns);
          }
          break;
        case 'left':
          if (snake.first % columns == 0 || collisionTest(snake.first, snake)) {
            falseGame();
          } else {
            snake.insert(0, snake.first - 1);
          }
          break;
        case 'right':
          if ((snake.first + 1) % columns == 0 ||
              collisionTest(snake.first, snake)) {
            falseGame();
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

  bool collisionTest(first, snake) {
    var newSnake = snake.sublist(1);
    var lost = false;
    newSnake.forEach((element) {
      if (element == first) {
        lost = true;
      }
    });
    return lost;
  }

  void falseGame() {
    isPlaying = false;
    direction = 'start';
  }

  void showLostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'נפסלת',
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'לא נורא, תמיד אפשר לנסות שוב',
            textAlign: TextAlign.right,
          ),
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
                  child: const Text('שחק שוב'),
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
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemBuilder: (BuildContext context, int index) {
                var color;
                // double radius = 5;
                double radiusTopLeft = 5;
                double radiusTopRight = 5;
                double radiusBottomLeft = 5;
                double radiusBottomRight = 5;

                double padding = 2;
                dynamic text = const Text('');
                if (snake.contains(index)) {
                  // print('snake: $snake, index: $index');
                  color = Color.fromARGB(255, 218, 177, 84);
                  if (index == snake.first) {
                    color = Color.fromARGB(255, 195, 158, 74);
                    padding = 0;
                    // text = Text('🐍');
                    if (direction == 'up') {
                      text = const Text('👀');
                      radiusBottomLeft = 0;
                      radiusBottomRight = 0;
                    } else if (direction == 'down') {
                      text = const Text('👀');
                      radiusTopLeft = 0;
                      radiusTopRight = 0;
                    } else if (direction == 'left') {
                      text = Transform.rotate(
                        angle: -pi / -2, // 90 degrees
                        alignment: Alignment.center,
                        child: const Text('👀'),
                      );

                      radiusBottomRight = 0;
                      radiusTopRight = 0;
                    } else if (direction == 'right') {
                      text = Transform.rotate(
                        angle: -pi / 2, // -90 degrees
                        alignment: Alignment.center,
                        child: const Text('👀'),
                      );

                      radiusBottomLeft = 0;
                      radiusTopLeft = 0;
                    } else
                      text = const Text('🕶️');
                  } else if (index == snake.last) {
                    color = const Color.fromARGB(255, 51, 122, 86);
                    padding = 0;
                  } else {
                    radiusTopLeft = 0;
                    radiusTopRight = 0;
                    radiusBottomLeft = 0;
                    radiusBottomRight = 0;
                    padding = 0;
                  }
                } else if (index == food) {
                  text = FittedBox(
                    child: const Text('🍎', textAlign: TextAlign.center),
                    fit: BoxFit.contain,
                  );
                  color = const Color.fromARGB(255, 66, 66, 66);
                } else {
                  color = const Color.fromARGB(255, 66, 66, 66);
                }
                return Container(
                    padding: EdgeInsets.all(padding),
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(radius),
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(index == 0 ? 10 : radiusTopLeft),
                        topRight: Radius.circular(
                            index == columns - 1 ? 10 : radiusTopRight),
                        bottomLeft: Radius.circular(
                            index == columns * (rows - 1)
                                ? 10
                                : radiusBottomLeft),
                        bottomRight: Radius.circular(index == columns * rows - 1
                            ? 10
                            : radiusBottomRight),
                      ),

                      child: Container(
                          color: color,
                          child: Center(
                            child: text,
                          )),
                    ));
              },
              itemCount: rows * columns,
            ),
          ),
        ),
      ),
    );
  }
}
