import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _passwordRef =
      FirebaseDatabase.instance.reference().child('password');
  final DatabaseReference _pictureRef =
      FirebaseDatabase.instance.reference().child('picture');
  final DatabaseReference _historyRef =
      FirebaseDatabase.instance.reference().child('history');
  final DatabaseReference _openRef =
      FirebaseDatabase.instance.reference().child('open');

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
              onPressed: () async {
                // 금고 열기 버튼 누를 때 비밀번호 입력 다이얼로그 표시
                _showPasswordInputDialog(
                    context, _passwordRef, _historyRef, _openRef);
              },
              child: const Text(
                '금고 열기',
                style: TextStyle(fontSize: 30),
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  //파이어베이스의 사진 가져오기
                  await _pictureRef.set('1');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PictureScreen()));
                },
                child: const Text(
                  '금고 내부 확인하기',
                  style: TextStyle(fontSize: 30),
                )),
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
                '비밀번호 설정 & 변경',
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
                    '1.금고 열기',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '  앱에서 버튼을 누르면 비밀번호를 입력하고 금고 문을 열 수 있다.',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '2.금고 내부 확인하기',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '  앱에서 버튼을 누르면 금고 내부에서 사진을 찍어 앱을 통해 확인할 수 있다.',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '3.비밀번호 설정 & 변경',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '  초기 금고의 비밀번호를 설정 가능하고, 이미 비밀번호가 있는 경우는 변경 가능하다.',
                    style: TextStyle(fontSize: 15),
                  ),
                  Text(
                    '4.금고 기록 열람',
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
        });
  }
}

void _showPasswordInputDialog(
    BuildContext context,
    DatabaseReference passwordRef,
    DatabaseReference historyRef,
    DatabaseReference openRef) {
  TextEditingController _passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("비밀번호 입력"),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '비밀번호를 입력하세요',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("취소"),
          ),
          TextButton(
            onPressed: () async {
              // Check the password
              final DataSnapshot snapshot = (await passwordRef.once()).snapshot;
              final correctPassword = snapshot.value?.toString() ?? '';

              if (_passwordController.text == correctPassword) {
                await openRef.set('1');

                // 입력한 비밀번호가 맞으면 금고 기록에 현재 시간 기입
                final DateTime now = DateTime.now();
                final String formattedTime =
                    DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US')
                        .format(now.toUtc().add(Duration(hours: 9)))
                        .toString();
                await historyRef.push().set(formattedTime);

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('금고가 열렸습니다.'),
                  ),
                );
              } else {
                // 입력한 비밀번호가 틀리면
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('비밀번호가 일치하지 않습니다.'),
                  ),
                );
              }
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
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
        if (oldPassword.isEmpty) {
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
  const PictureScreen({Key? key}) : super(key: key);

  @override
  _PictureScreenState createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    try {
      // Firebase Storage에서 이미지 목록 가져오기
      firebase_storage.ListResult result =
          await storage.ref().child('images/').listAll();

      // 이미지 URL을 리스트에 추가
      for (final firebase_storage.Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        setState(() {
          imageUrls.add(url);
        });
      }
    } catch (error) {
      print("Error loading images: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('현재 금고 내부 사진'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          );
        },
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
  final DatabaseReference _historyRef =
      FirebaseDatabase.instance.reference().child('history');

  List<String> openingTimes = [];

  @override
  void initState() {
    super.initState();
    _loadOpeningTimes();
  }

  Future<void> _loadOpeningTimes() async {
    try {
      final DatabaseEvent event = await _historyRef.once();
      final DataSnapshot snapshot = event.snapshot;
      final Map<dynamic, dynamic>? historyData = snapshot.value as Map?;

      if (historyData != null) {
        final List<String> times = historyData.values.cast<String>().toList();
        setState(() {
          openingTimes = times;
        });
      }
    } catch (error) {
      print("Error loading opening times: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('금고 기록'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: openingTimes.length,
          itemBuilder: (context, index) {
            // 가장 최신 기록이 맨 위에 오도록 함
            final reversedIndex = openingTimes.length - 1 - index;
            final time = openingTimes[reversedIndex];

            return Text(time);
          },
        ),
      ),
    );
  }
}
