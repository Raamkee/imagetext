import 'package:flutter/material.dart';
import '../LogicalComponents/TextRecognizer.dart';

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
                  Icon(
                    Icons.payment,
                    size: 50,
                    color: Colors.black54,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 25,
                    color: Colors.black54,
                  ),
                  Icon(
                    Icons.qr_code_scanner,
                    size: 50,
                    color: Colors.black54,
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    navigateToPage(context, TextRecognizer());
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
                      'Digitise Business Card!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  )),
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
