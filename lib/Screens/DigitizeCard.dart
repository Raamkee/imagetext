import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';

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

  bool tapDigitize = false;

  bool get isPlaying => _controller?.isActive ?? true;

  bool _isPlaying = false;
  Artboard _riveArtboard;
  RiveAnimationController _controller;

  String vCardImgPath = "";

  List<String> vCardImgPathList = [
    "/storage/emulated/0/Pictures/1629630165636.jpg"
  ];
  File currentFile;

  bool loadImage = false;

  TextEditingController _nameCtlr = new TextEditingController();
  TextEditingController _mobNoCtlr = new TextEditingController();
  TextEditingController _emailCtlr = new TextEditingController();
  TextEditingController _addressCtlr = new TextEditingController();
  TextEditingController _websiteCtlr = new TextEditingController();
// TextEditingController _nameCtlr=new TextEditingController();

  GlobalKey globalKey = GlobalKey();

//   Future<void> _capturePng() async {
//     RenderRepaintBoundary boundary =
//         globalKey.currentContext.findRenderObject();

//     ui.Image image = await boundary.toImage();
//     ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData.buffer.asUint8List();
//     print(pngBytes);
//   }

// Future<ui.Image> toImage({ double pixelRatio = 1.0 }) {
//   assert(!debugNeedsPaint);
//   final OffsetLayer offsetLayer = layer! as OffsetLayer;
//   return offsetLayer.toImage(Offset.zero & size, pixelRatio: pixelRatio);
// }

  Future<Uint8List> _capturePng() async {
    print('capture...');
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();

    if (boundary.debugNeedsPaint) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 20));
      return _capturePng();
    }

    var image = await boundary.toImage(pixelRatio: 3.0);
    var byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  void _printPngBytes() async {
    var pngBytes = await _capturePng();
    var bs64 = base64Encode(pngBytes);
    print(pngBytes);
    print(bs64);
    // vCardImgPath=
    _createFileFromString(bs64);
  }

  Future<String> _createFileFromString(getbsData) async {
    Uint8List bytes = base64.decode(getbsData);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/abc.png';
    print("local file full path: " + fullPath);
    File file = File(fullPath);
    await file.writeAsBytes(bytes);
    print(file.path);
    setState(() {
      vCardImgPath = file.path;
      currentFile = file;
      print(vCardImgPath);
    });
    print(vCardImgPath);
    final result = await ImageGallerySaver.saveImage(bytes);
    print(result);
    setState(() {
      // vCardImgPath = result['filePath'];
      vCardImgPath = file.path;
      // vCardImgPath = "/storage/emulated/0/Pictures/1629624092166.jpg";
      print(vCardImgPath);
      // vCardImgPathList.add("/storage/emulated/0/Pictures/1629630165636.jpg");
      vCardImgPathList.add(vCardImgPath);
      print('added to list');
      print('vCardImgPathList to loist ------');
      print(vCardImgPathList[0]);
      loadImage = true;
      print(vCardImgPathList.toString());
    });

    return file.path;
  }

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
    rivAnim();
  }

//   bool get debugNeedsPaint {
//    bool result;
//   assert(() {
//     result = _needsPaint;
//     return true;
//   }());
//   return result;
// }

  rivAnim() {
    rootBundle.load('assets/animations/example__download_icon.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  cameraUtil() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      print(e);
    }
  }

  void getLoadData() {
    Future.delayed(const Duration(milliseconds: 6000), () {
      setState(() {
        tapDigitize = false;
      });
      setCtlrText();
    });
  }

  @override
  Widget build(BuildContext context) {
    // SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.05),
          elevation: 0,
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.black54),
          ),
          centerTitle: true,
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
        body: Stack(children: [
          _galleryBody(),
          Center(
            child: tapDigitize ? _rivLoadAnim() : Container(),
          ),
        ]));
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey.withOpacity(0.3), blurRadius: 8)
                  // ],
                ),
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
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  // boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey.withOpacity(0.3), blurRadius: 8)
                  // ],
                ),
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3), blurRadius: 8)
                    ],
                  ),
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
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3), blurRadius: 8)
                    ],
                  ),
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
      Stack(children: [
        _animatedStackOne(),
        _animatedStackTwo(),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
          child: InkWell(
            child: Container(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.width * 0.15,
                width: MediaQuery.of(context).size.width * 0.40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: Colors.white,
                  // boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 2)],
                ),
                child: AnimatedAlign(
                  alignment: tapDigitize
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: Duration(seconds: 1),
                  child: Text(
                    tapDigitize ? 'Digitizing...' : 'Digitize',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
            onTap: () {
              setState(() {
                tapDigitize = true;
              });
              getLoadData();
              _launchRocket();
              // setCtlrText();
              print(widget.getName +
                  widget.getMobNo +
                  widget.getEmail +
                  widget.getAddress +
                  widget.getWebsite);
              print('object');
            },
          ),
        ),
      ]),
      // tapDigitize ? _rivLoadAnim() : Container(),
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: Divider(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
        child: _editVisitingCard(),
      ),
      // Padding(
      //   padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
      //   child: Stack(children: [
      //     _updatedCard(),
      //     _updatedCardStackTwo(),
      //     _updatedCardStackFour(),
      //   ]),
      // ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
        child: _cardOutput(),
      ),
      // _cardOutput(),
      // _exportBtn(),

      !loadImage
          ? _printImgByteDataBtn()
          : Center(
              child: Container(
                // padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // color: Colors.grey,
                    border: Border.all(
                      color: Colors.grey,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Card is Saved in Gallery!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
      loadImage
          ? Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _loadIMagefromPath(),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                  child: Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 3)
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.share,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          'Share',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () => _shareImage()),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.12,
                              ),
                              InkWell(
                                  child: Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.12,
                                    width: MediaQuery.of(context).size.width *
                                        0.12,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            blurRadius: 3)
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          'Open',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () => _shareImage()),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            )
          : Container(),
      // Text('no image'),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          child: Container(
            height: 5,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      // _shareImg(),
    ]);
  }

  Widget _editVisitingCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)
        // ],
      ),
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
      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
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
      height: MediaQuery.of(context).size.width * 0.6,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        height: 20,
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
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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

  Widget _animatedContent() {
    return Center(
      child: Container(
        width: 250.0,
        height: 250.0,
        color: Colors.white,
        child: AnimatedAlign(
          alignment: tapDigitize ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          child:
              // const FlutterLogo(size: 50.0),
              Icon(
            Icons.qr_code_scanner,
            size: 50,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _animatedStackOne() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
      child: Container(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.width * 0.15,
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)
            ],
          ),
          // child: AnimatedAlign(
          //   alignment:
          //       tapDigitize ? Alignment.centerRight : Alignment.centerLeft,
          //   duration: const Duration(seconds: 1),
          //   curve: Curves.fastOutSlowIn,
          //   child: Icon(
          //     Icons.qr_code_scanner,
          //     color: Colors.black54,
          //   ),
          // ),
        ),
      ),
    );
  }

  Widget _animatedStackTwo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
      child: Container(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.width * 0.15,
          width: MediaQuery.of(context).size.width * 0.40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: AnimatedAlign(
            alignment:
                tapDigitize ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardOutput() {
    return RepaintBoundary(
      key: globalKey,
      child: Stack(children: [
        _updatedCard(),
        _updatedCardStackTwo(),
        _updatedCardStackFour(),
      ]),
    );
  }

  Widget _exportBtn() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            print('exporting...');
            _capturePng();

// _printPngBytes();
          },
          child: Text('Export')),
    );
  }

  Widget _printImgByteDataBtn() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ))),
        onPressed: () {
// _capturePng();

          if (_nameCtlr.text != "" &&
              _mobNoCtlr.text != "" &&
              _addressCtlr.text != "" &&
              _emailCtlr.text != "" &&
              _websiteCtlr.text != "")
            _printPngBytes();
          else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'Please Fill all Details',
              textAlign: TextAlign.center,
            )));
            print('');
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: 55,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Save Card',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shareImg() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
// _capturePng();

            _shareImage();
          },
          child: Text('Share')),
    );
  }

  // _shareImage() async {
  //   try {
  //     final ByteData bytes =
  //         await rootBundle.load('assets/images/Screenshot_1624688004.png');
  //     // final ByteData bytes = await Image.file(File(vCardImgPath)).image;
  //     final Uint8List list = bytes.buffer.asUint8List();
  //     final tempDir = await getTemporaryDirectory();
  //     final file = await new File('${tempDir.path}/image.jpg').create();
  //     file.writeAsBytesSync(list);
  //     final channel = const MethodChannel('channel:me.albie.share/share');
  //     channel.invokeMethod('shareFile', 'image.jpg');
  //   } catch (e) {
  //     print('Share error: $e');
  //   }
  // }

  _shareImage() async {
    // print(vCardImgPathList[0]);
    final RenderBox box = context.findRenderObject() as RenderBox;
    if (Platform.isAndroid) {
      if (vCardImgPath.isNotEmpty) {
        await
            // Share.shareFiles(vCardImgPathList,
            //     text: 'text',
            //     subject: 'subject',
            //     sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);

            // Share.shareFiles(['/storage/emulated/0/Pictures/1629624092166.jpg'],
            Share.shareFiles([vCardImgPath], text: 'Sharing Virtual Card');
      } else {
        await Share.share('text',
            subject: 'subject',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    }
    // final RenderBox box = context.findRenderObject();
    // if (Platform.isAndroid) {
    //   var url = 'https://i.ytimg.com/vi/fq4N0hgOWzU/maxresdefault.jpg';
    //   var response = await get(url);
    //   final documentDirectory = (await getExternalStorageDirectory()).path;
    //   File imgFile = new File('$documentDirectory/flutter.png');
    //   imgFile.writeAsBytesSync(response.bodyBytes);

    //   Share.shareFiles(vCardImgPathList,
    //       subject: 'URL File Share',
    //       text: 'Hello, check your share files!',
    //       sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    // } else {
    //   Share.share('Hello, check your share files!',
    //       subject: 'URL File Share',
    //       sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    // }
  }

  Widget _loadIMagefromPath() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width * 0.42,
        width: MediaQuery.of(context).size.width * 0.65,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
            // color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)
            ]),
        child: Image.file(File(vCardImgPath)),
      ),
    );
  }

  Widget _rivLoadAnim() {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10)
          ]),
      height: 125,
      width: 125,
      child: _riveArtboard == null
          ? const SizedBox()
          : Rive(
              artboard: _riveArtboard,
            ),
    );
  }

  void _launchRocket() {
    print('object-----');
    _riveArtboard.addController(
      _controller = SimpleAnimation('Demo', autoplay: isPlaying),
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
