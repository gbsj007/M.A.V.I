import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:alan_voice/alan_voice.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool uploading = false;
  var arr0 = [];
  var arr1 = [];
  String parseText = '';
  String str = '';
  int _ocrCamera = FlutterMobileVision.CAMERA_BACK; //initialized a camera
  String _text = "";
  String norText = '';
  final FlutterTts flutterTts = FlutterTts(); // initialized a TTS

  //This is alan voice button
  _HomePageState() {
    //Alan button
    AlanVoice.addButton(
        "c72df5aa5dae26571501e2a31c0ced5c2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    //to handle the commands
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  void setVisuals(String screen) {
    var visual = "{\"screen\":\"$screen\"}";
    AlanVoice.setVisualState(visual);
  }

  //Handling Commands
  void _handleCommand(Map<String, dynamic> command) {
    switch (command["command"]) {
      case "upload":
        _upload(command["route"]);
        break;
      case "scan":
        _scan(command["route"]);
        break;
      case "nupload":
        _nupload(command["route"]);
        break;
      default:
        debugPrint("Unknown command: $command");
    }
  }

  // upload command given by user
  Future<void> _upload(String screen) async {
    switch (screen) {
      case "takeAnImage":
        // ignore: unnecessary_statements
        parsethetext();
        setVisuals("gallery");
        break;
      default:
        print("Unknown screen: $screen");
    }
  }

  // Scan command given by user
  _scan(String screen) {
    switch (screen) {
      case "scanAnProduct":
        _read();
        setVisuals("scanning page");
        break;
      default:
        print("Unknown screen: $screen");
    }
  }

  // nor_upload command given by user
  Future<void> _nupload(String screen) async {
    switch (screen) {
      case "grabImage":
        // ignore: unnecessary_statements
        parsetext();
        setVisuals("gallery");
        break;
      default:
        print("Unknown screen: $screen");
    }
  }

  // TTS function for "uplaod an image" button's OCR
  Future _speak() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.setSpeechRate(1);
    await flutterTts.speak(str);
  }

  // TTS function for scan button's OCR
  Future _scanSpeak() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.speak(_text);
  }

  Future _simSpeak() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(1);
    await flutterTts.speak(norText);
  }

  // function to handle and parsing the image
  parsethetext() async {
    //pick  a image
    final imagefile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 670, maxHeight: 970);
    //prepare the image
    setState(() {
      uploading = true;
    });
    var bytes = Io.File(imagefile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    //send to api
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": '3abb227f0b88957'};
    var post = await http.post(url, body: payload, headers: header);
    //get result from api
    var result = jsonDecode(post.body);

    setState(() {
      norText = '';
      _text = '';
      uploading = false;
      parseText = result['ParsedResults'][0]['ParsedText'];

      arr0 = (parseText.splitMapJoin(
          RegExp(
              '/Platelet Count|Total R\.D\.W\.|Total R\.B\.C|(?:Eosin|Neutr|Bas)ophils|Lymphocytes|Haemoglobin|Haematocrit|M(?:onocytes|C(?:HC|V))|RBC Count|WBC Count|(?:M\.C\.(?:H\.C|V)|P\.C\.V)\.|M(?:\.C\.H\.|CH)|R(?:\.D\.W\.|DW\-CV)|IG/'),
          onMatch: (m) => '${m.group(0) + '  '}',
          onNonMatch: (n) => '')).split('  ');

      arr1 = (RegExp(r'[+-]?([0-9]+([.,][0-9]*)?|[.][0-9]+)', multiLine: true)
              .allMatches(parseText)
              .map((m) => m.group(0))
              .join(' '))
          .split(" ");

      List<dynamic> output = List<dynamic>(arr0.length + arr1.length);
      int i = 0;
      for (i; i < math.min(arr0.length, arr1.length); i++) {
        output[i * 2] = arr0[i];
        output[i * 2 + 1] = arr1[i];
      }

      if (arr0.length != arr1.length) {
        if (arr0.length > arr1.length) {
          output.setRange(i * 2, output.length, arr0.sublist(i));
        } else {
          output.setRange(i * 2, output.length, arr1.sublist(i));
        }
      }

      str = output.join('\n');

      _speak();
    });
  }

  // function to handle and parsing the image
  parsetext() async {
    //pick  a image
    final imagefile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 670, maxHeight: 970);
    //prepare the image
    setState(() {
      uploading = true;
    });
    var bytes = Io.File(imagefile.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    //send to api
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": '3abb227f0b88957'};
    var post = await http.post(url, body: payload, headers: header);
    //get result from api
    var result = jsonDecode(post.body);

    setState(() {
      str = '';
      _text = '';
      uploading = false;
      norText = result['ParsedResults'][0]['ParsedText'];
      _simSpeak();
    });
  }

  // function to handle the scanning of an product
  Future<Null> _read() async {
    List<OcrText> texts = [];

    try {
      texts = await FlutterMobileVision.read(
        camera: _ocrCamera,
        waitTap: true,
        autoFocus: true,
        multiple: true,
      );
      setState(() {
        norText = '';
        str = '';
        _text = texts[0].value;
        _scanSpeak();
      });
    } on Exception {
      texts.add(OcrText('Failed to recognize text'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/four.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 30.0),
                alignment: Alignment.center,
                child: Text(
                  "M.A.V.I",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Colors.black,
                    letterSpacing: 5,
                  ),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.25,
                ),
                height: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.zero, right: Radius.zero),
                    color: Colors.white),
              ),
              SizedBox(
                height: 200.0,
              ),
              GestureDetector(
                onTap: () => parsethetext(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      "Blood Report",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: () => _read(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      "Medical Products",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              GestureDetector(
                onTap: () => parsetext(),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: Colors.white),
                  child: Center(
                    child: Text(
                      "Normal Text Report",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              uploading == false ? Container() : CircularProgressIndicator(),
              SizedBox(
                height: 10.0,
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "ParsedText : ",
                      style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      str != ''
                          ? str
                          : norText != ''
                              ? norText
                              : _text,
                      style: GoogleFonts.montserrat(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
