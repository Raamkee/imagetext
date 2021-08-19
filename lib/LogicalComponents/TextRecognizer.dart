import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../Screens/DigitizeCard.dart';

class TextRecognizer extends StatefulWidget {
  @override
  _TextRecognizerState createState() => _TextRecognizerState();
}

class _TextRecognizerState extends State<TextRecognizer> {
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;
  CustomPaint customPaint;
  String passStringVal = "";
  String emailId = "";
  String fName = "";
  String lName = "";
  String mobileNo = "";
  String address = "";
  String companyName = "";
  String designation = "";
  String website = "";
  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return DigitizeCard(
      title: 'Digitize Card',
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      getString: passStringVal,
      getName: fName,
      getMobNo: mobileNo,
      getEmail: emailId,
      getAddress: address,
      getWebsite: website,
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final recognisedText = await textDetector.processImage(inputImage);
    print('Found ${recognisedText.blocks.length} textBlocks');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
    } else {
      customPaint = null;
      print('else');

      String patternEmail =
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

      String patternMobNoIn = r"/^(\+\d{1,3}[- ]?)?\d{10}$/";
      String patternMobNoOther = r"/^(\+\d{1,3}[- ]?)?\d{20}$/";

      String patternMobNoAlternate =
          r"^(\+?\d{1,4}[\s-])?(?!0+\s+,?$)\d{10}\s*,?$";

      String patternString = r"[a-zA-Z]";
      String patternWebsite =
          r"[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)";
      String patternMobNoNew = r'@"^[0-9*#+]+$"';

      RegExp regExName = RegExp(patternString);

      RegExp regExEmail = RegExp(patternEmail);

      RegExp regExMobNoIn = RegExp(patternMobNoIn);

      RegExp regExMobNoOther = RegExp(patternMobNoOther);

      RegExp regExMobNoAlternate = RegExp(patternMobNoAlternate);
      RegExp regExMobNoNew = RegExp(patternMobNoNew);

      RegExp regExWebsite = RegExp(patternWebsite);

      String contentData = "";

      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          if (!regExEmail.hasMatch(line.text)) {
            contentData += line.text + '\n';
            print(contentData);
            passStringVal = contentData;
          }

          if (regExName.hasMatch(line.text) && fName == "") fName = line.text;
          print(fName);

          if ((line.text).length == 1) lName = line.text;
          print("lName: " + lName);

          if (regExMobNoIn.hasMatch(line.text) ||
              regExMobNoOther.hasMatch(line.text) ||
              regExMobNoAlternate.hasMatch(line.text) ||
              regExMobNoNew.hasMatch(line.text) ||
              (line.text).length == 14) mobileNo = line.text;
          print("Mobile: " + mobileNo);

          if (regExEmail.hasMatch(line.text)) emailId = line.text;
          print("email: " + emailId);

          if ((line.text).contains("th") || (line.text).contains("street"))
            address = line.text;
          print("address: " + address);

          if (regExWebsite.hasMatch(line.text)) website = line.text;
          print("website: " + website);
        }
      }
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
