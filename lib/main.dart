import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagetext/Screens/HomePage.dart';
import 'package:rive/rive.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Business Card',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
          )),
      debugShowCheckedModeBanner: false,
      home: new HomePage(),
      // Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({Key key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool get isPlaying => _controller?.isActive ?? false;

  bool _isPlaying = false;
  Artboard _riveArtboard;
  RiveAnimationController _controller;
  @override
  void initState() {
    super.initState();

    rootBundle
        .load('assets/animations/example__download_icon_whitebg.riv')
        .then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  void getLoadData() {
    print('object');
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: _riveArtboard == null
                        ? const SizedBox()
                        : Rive(
                            artboard: _riveArtboard,
                          ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _launchRocket();
                },
                child: Text('start anim'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('stop anim'),
              )
            ],
          )),
    );
  }

  void _launchRocket() {
    print('object-----');
    _riveArtboard.addController(
      _controller = SimpleAnimation('Demo', autoplay: true),
    );
  }

  navigateToPage(getContext, getPage) {
    Navigator.of(getContext).push(MaterialPageRoute(
      builder: (getContext) => getPage,
    ));
  }
}
