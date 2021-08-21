import 'package:flutter/material.dart';
import '../LogicalComponents/TextRecognization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedAlign(
                    alignment: Alignment.centerRight,
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Icon(
                        Icons.payment,
                        size: 50,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 25,
                    color: Colors.black54,
                  ),
                  AnimatedAlign(
                    alignment: Alignment.centerLeft,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 50,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    navigateToPage(context, TextRecognization());
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      'Digitize Business Card!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  )),
              // Center(
              //   child: Container(
              //     width: 250.0,
              //     height: 250.0,
              //     color: Colors.white,
              //     child: AnimatedAlign(
              //       alignment:
              //           // selected ?
              //           // Alignment.centerRight,
              //           // :
              //           Alignment.centerLeft,
              //       duration: const Duration(seconds: 1),
              //       curve: Curves.fastOutSlowIn,
              //       child:
              //           // const FlutterLogo(size: 50.0),
              //           Icon(
              //         Icons.qr_code_scanner,
              //         size: 50,
              //         color: Colors.black54,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ));
  }

  navigateToPage(getContext, getPage) {
    Navigator.of(getContext).push(MaterialPageRoute(
      builder: (getContext) => getPage,
    ));
  }
}
