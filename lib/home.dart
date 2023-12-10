import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _passwordRef =
      FirebaseDatabase.instance.reference().child('password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              //앱 설명 표시
              explanation();
            },
            icon: const Icon(Icons.book),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                //파이어베이스의 사진 가져오기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PictureScreen(),
                  ),
                );
              },
              child: const Text(
                '금고 내부 확인하기',
                style: TextStyle(fontSize: 30),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                //파이어베이스의 비번 설정 & 있는 경우 변경하는 함수
                final DataSnapshot snapshot =
                    (await _passwordRef.once()).snapshot;
                final currentPassword = snapshot.value?.toString() ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PasswordScreen(currentPassword: currentPassword),
                  ),
                );
              },
              child: const Text(
                '비밀번호 설정& 변경',
                style: TextStyle(fontSize: 30),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
              child: const Text(
                '금고 기록 열람',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> explanation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            '설명',
            style: TextStyle(fontSize: 25),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '1.금고 내부 확인하기',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '  앱에서 버튼을 누르면 금고 내부에서 사진을 찍어 앱을 통해 확인할 수 있다.',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '2.비밀번호 설정& 변경',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '  초기 금고의 비밀번호를 설정 가능하고, 이미 비밀번호가 있는 경우는 변경 가능하다.',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '3.금고 기록 열람',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  '  금고가 열렸을때의 시간을 볼 수 있다.',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key, required this.currentPassword});

  final String currentPassword;

  @override
  _PasswordScreen createState() => _PasswordScreen();
}

class _PasswordScreen extends State<PasswordScreen> {
  final _textController = TextEditingController();
  final DatabaseReference _passwordRef =
      FirebaseDatabase.instance.reference().child('password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('비밀번호'),
        actions: [
          IconButton(
            onPressed: () {
              //앱 설명 표시
              passwordExplanation();
            },
            icon: const Icon(Icons.book),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
              '비밀번호 설정',
              style: TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                const Padding(padding: EdgeInsets.all(8.0)),
                Flexible(
                  flex: 1,
                  child: TextField(
                    controller: _textController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text == '') {
                      return;
                    } else {
                      setState(() {
                        changePassword(
                            widget.currentPassword, _textController.text);
                        _textController.clear();
                      });
                    }
                  },
                  child: const Text("변경"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> passwordExplanation() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            '비밀번호 기능 설명',
            style: TextStyle(fontSize: 25),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              Text(
                '바꿀 비밀번호를 텍스트필드에 입력하고 변경버튼을 누르세요. 기존의 비밀번호가 없는 경우는 바로 비밀번호가 설정되며, 있는 경우는 기존의 비밀번호를 입력하는 창에 입력하고 일치해야 변경됩니다.',
                style: TextStyle(fontSize: 15),
              ),
            ]),
          ),
        );
      },
    );
  }

  void changePassword(String oldPassword, String newPassword) {
    final numericRegex = RegExp(r'^-?(([1-8]*)|(([1-8]*)\.([1-8]*)))$');
    if (numericRegex.hasMatch(newPassword) == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호는 1~8 사이의 숫자로만 설정할 수 있습니다.'),
        ),
      );
    } else {
      if (newPassword.length == 4) {
        //데이터 베이스에서 비밀번호 불러오기
        //password=
        if (oldPassword == null || oldPassword.isEmpty) {
          // newPassword를 비밀번호로 DB에 저장
          _passwordRef.set(newPassword);
        } else {
          oldPasswordConfirmation(oldPassword, newPassword);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호는 네 자리 숫자입니다.'),
          ),
        );
      }
    }
  }

  Future<void> oldPasswordConfirmation(String oldPassword, String newPassword) {
    final passTextcontroller = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '기존 비밀번호 확인',
            style: TextStyle(fontSize: 25),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              Flexible(
                flex: 1,
                child: TextField(
                  controller: passTextcontroller,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (passTextcontroller.text == '') {
                    return;
                  } else {
                    setState(() {
                      if (oldPassword.compareTo(passTextcontroller.text) == 0) {
                        // 같음, newPassword로 DB에 업데이트
                        _passwordRef.set(newPassword);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('비밀번호 변경에 성공하였습니다.'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('비밀번호가 다릅니다.'),
                          ),
                        );
                      }
                      _textController.clear();
                    });
                  }
                },
                child: const Text("확인"),
              )
            ]),
          ),
        );
      },
    );
  }
}

class PictureScreen extends StatefulWidget {
  const PictureScreen({Key? key});

  @override
  _PictureScreen createState() => _PictureScreen();
}

class _PictureScreen extends State<PictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('현재 금고 내부 사진'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Text('사진')],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key});

  @override
  _HistoryScreen createState() => _HistoryScreen();
}

class _HistoryScreen extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('금고 기록'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[Text('기록 리스트 출력')],
        ),
      ),
    );
  }

  Future<void> _taskUpdate(String uid, String id, bool state) async {
    if (state == true) {
      // Assuming you will perform some action when state is true
      // Add your Firestore or Realtime Database logic here
    }
  }
}
