import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

enum ScreenMode { gallery }

class DigitizeCard extends StatefulWidget {
  DigitizeCard({
    Key key,
    this.title,
    this.customPaint,
    this.onImage,
    this.initialDirection = CameraLensDirection.back,
    this.getString,
    this.getName,
    this.getMobNo,
    this.getEmail,
    this.getAddress,
    this.getWebsite,
  }) : super(key: key);

  final String title;
  final CustomPaint customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;
  final String getString;
  final String getName;
  final String getMobNo;
  final String getEmail;
  final String getAddress;
  final String getWebsite;

  @override
  _DigitizeCardState createState() => _DigitizeCardState();
}

List<CameraDescription> cameras = [];

class _DigitizeCardState extends State<DigitizeCard> {
  File _image;
  ImagePicker _imagePicker;
  int _cameraIndex = 0;

  TextEditingController _nameCtlr = new TextEditingController();
  TextEditingController _mobNoCtlr = new TextEditingController();
  TextEditingController _emailCtlr = new TextEditingController();
  TextEditingController _addressCtlr = new TextEditingController();
  TextEditingController _websiteCtlr = new TextEditingController();
// TextEditingController _nameCtlr=new TextEditingController();

  @override
  void initState() {
    super.initState();
    cameraUtil();
    _imagePicker = ImagePicker();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
  }

  cameraUtil() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.05),
          elevation: 0,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.black54),
          ),
          leading: InkWell(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black54,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.95),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.file(_image),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 1,
                child: Icon(
                  Icons.image,
                  color: Colors.grey.withOpacity(0.5),
                  size: 120,
                ),
              ),
            ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Divider(),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(
            'Choose Image to Proceed',
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library,
                        color: Colors.grey,
                        size: 50,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                onTap: () => _getImage(ImageSource.gallery),
              ),
              InkWell(
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        color: Colors.grey,
                        size: 50,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                onTap: () => _getImage(ImageSource.camera),
              )
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Divider(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: InkWell(
          child: Container(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.width * 0.15,
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black54,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Digitize',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            setCtlrText();
            print(widget.getName +
                widget.getMobNo +
                widget.getEmail +
                widget.getAddress +
                widget.getWebsite);
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Divider(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 25, 8, 25),
        child: _editVisitingCard(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 25, 8, 25),
        child: Stack(children: [
          _updatedCard(),
          _updatedCardStackTwo(),
          _updatedCardStackFour(),
        ]),
      ),
    ]);
  }

  Widget _editVisitingCard() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        children: [
          _textField(_nameCtlr, "Name"),
          _textField(_mobNoCtlr, "Mobile Number"),
          _textField(_emailCtlr, "Email ID"),
          _textField(_addressCtlr, "Address"),
          _textField(_websiteCtlr, "Website"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ))),
                onPressed: () {},
                child: Text('Update')),
          )
        ],
      ),
    );
  }

  Widget _textField(getTxtCtlr, getLableTxt) {
    return TextFormField(
      controller: getTxtCtlr,
      decoration: InputDecoration(
          labelText: getLableTxt, labelStyle: TextStyle(color: Colors.black54)),
    );
  }

  setCtlrText() {
    setState(() {
      _nameCtlr.text = widget.getName;
      _mobNoCtlr.text = widget.getMobNo;
      _emailCtlr.text = widget.getEmail;
      _addressCtlr.text = widget.getAddress;
      _websiteCtlr.text = widget.getWebsite;
    });
  }

  clearCtlrText() {
    setState(() {
      _nameCtlr.text = "";
      _mobNoCtlr.text = "";
      _emailCtlr.text = "";
      _addressCtlr.text = "";
      _websiteCtlr.text = "";
    });
  }

  Widget _updatedCard() {
    return Container(
      padding: EdgeInsets.all(0.5),
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.8), blurRadius: 3)
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  title: Text(
                    _nameCtlr.text,
                    style: TextStyle(
                        letterSpacing: 3,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Icon(
                    Icons.phone,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    _mobNoCtlr.text,
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Icon(
                    Icons.place,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    _addressCtlr.text,
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  leading: Icon(
                    Icons.email,
                    size: 18,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    _emailCtlr.text,
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Icon(
              //   Icons.circle,
              // ),
              SizedBox(
                width: 5,
              ),
              Text(
                _websiteCtlr.text,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _updatedCardStackOne() {
    return Container(
      padding: EdgeInsets.all(5),
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3), color: Colors.white),
    );
  }

  Widget _updatedCardStackTwo() {
    return Container(
      alignment: Alignment.bottomRight,
      // padding: EdgeInsets.all(5),
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        // color: Colors.white,
      ),
      child: Container(
        height: 20,
        // width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(3),
                bottomLeft: Radius.circular(3)),
            color: Colors.deepPurple),
      ),
    );
  }

  Widget _updatedCardStackThree() {
    return Container(
      padding: EdgeInsets.all(5),
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3), color: Colors.white),
    );
  }

  Widget _updatedCardStackFour() {
    return Container(
      padding: EdgeInsets.all(3),
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        // color: Colors.white,
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ListTile(
                //   visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                //   title: Text(
                //     _nameCtlr.text,
                //     style: TextStyle(
                //         color: Colors.blue,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 20),
                //   ),
                // ),
                // ListTile(
                //   visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                //   leading: Icon(Icons.phone),
                //   title: Text(
                //     _mobNoCtlr.text,
                //     style: TextStyle(
                //         color: Colors.blue, fontWeight: FontWeight.w400),
                //   ),
                // ),
                // ListTile(
                //   visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                //   leading: Icon(Icons.place),
                //   title: Text(
                //     _addressCtlr.text,
                //     style: TextStyle(
                //         color: Colors.blue, fontWeight: FontWeight.w400),
                //   ),
                // ),
                // ListTile(
                //   visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                //   leading: Icon(Icons.email),
                //   title: Text(
                //     _emailCtlr.text,
                //     style: TextStyle(
                //         color: Colors.blue, fontWeight: FontWeight.w400),
                //   ),
                // ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Icon(
              //   Icons.circle,
              // ),
              SizedBox(
                width: 5,
              ),
              Text(
                _websiteCtlr.text,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.getImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  Future _processPickedFile(PickedFile pickedFile) async {
    setState(() {
      _image = File(pickedFile.path);
    });
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    widget.onImage(inputImage);
  }
}
