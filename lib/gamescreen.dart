import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool oTurn = true;
  bool gameOver = false;
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  String statusText = "O's turn";
  static const String _oScoreKey = 'oScore';
  static const String _xScoreKey = 'xScore';

  List<String> board = ['', '', '', '', '', '', '', '', ''];
  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      oScore = prefs.getInt(_oScoreKey) ?? 0;
      xScore = prefs.getInt(_xScoreKey) ?? 0;
    });
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_oScoreKey, oScore);
    await prefs.setInt(_xScoreKey, xScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 23),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Player O',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: Text(
                            oScore.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Player X',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Center(
                          child: Text(
                            xScore.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        _tapped(index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(width: 5, color: Colors.red),
                          color: Colors.yellow,
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),
              Expanded(
                flex: 2,
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (gameOver)
                ElevatedButton(
                  onPressed: _clearBoard,
                  child: Text(
                    'Play again',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _tapped(int index) {
    if (board[index] != '' || gameOver) return;
    setState(() {
      board[index] = oTurn ? 'O' : 'X';
      filledBoxes++;
      oTurn = !oTurn;
      statusText = oTurn ? "O's turn" : "X's turn";
      _checkWinner();
    });
  }

  void _checkWinner() {
    for (var combination in winningPositions) {
      int a = combination[0];
      int b = combination[1];
      int c = combination[2];

      if (board[a] != '' && board[a] == board[b] && board[b] == board[c]) {
        _showResult(board[a]);
        return;
      }
    }
    if (filledBoxes == 9) {
      _showResult('');
    }
  }

  void _showResult(String winner) {
    setState(() {
      gameOver = true;
      statusText = winner == '' ? "It's a draw!" : 'The winner is $winner';
      if (winner == 'O') {
        oScore++;
      } else if (winner == 'X') {
        xScore++;
      }
    });
    _saveScores();
  }

  void _clearBoard() {
    setState(() {
      board = List.filled(9, '');
      filledBoxes = 0;
      gameOver = false;
      statusText = oTurn ? "O's turn" : "X's turn";
    });
  }

  List<List<int>> winningPositions = [
    [0, 1, 2], // top
    [3, 4, 5], // middle
    [6, 7, 8], // bottom

    [0, 3, 6], // left
    [1, 4, 7], // middle
    [2, 5, 8], // right

    [0, 4, 8], // diagonal
    [2, 4, 6], // diagonal
  ];
}
