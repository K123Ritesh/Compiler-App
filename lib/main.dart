import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jdoodle Java Compiler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CodeExecutionPage())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white, child: Lottie.asset("assets/splash.json"));
  }
}

class CodeExecutionPage extends StatefulWidget {
  @override
  _CodeExecutionPageState createState() => _CodeExecutionPageState();
}

class _CodeExecutionPageState extends State<CodeExecutionPage> {
  TextEditingController codeController = TextEditingController(
    text: '''
public class main{
  public static void main(String args[]){
    System.out.println("Hello World");
    //Add Your code here.....
  }
}
''',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jdoodle Java Compiler'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: codeController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Enter Java Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OutputPage(codeController.text),
                ),
              );
            },
            child: Text('Compile & Execute'),
          ),
        ],
      ),
    );
  }
}

class OutputPage extends StatefulWidget {
  final String initialCode;

  OutputPage(this.initialCode);

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  TextEditingController inputController = TextEditingController();
  List<String> outputLines = [];
  String currentCommand = '';
  String currentResponse = '';

  void processUserInput(String userInput) async {
    setState(() {
      currentCommand = "> $userInput";
    });

    final program = {
      'script': widget.initialCode,
      'language': 'java',
      'versionIndex': '0',
      'clientId': 'f8f4e987ecb04c0cb9819d069ee19186',
      'clientSecret':
          '3cba9479b9a77433f18cfad0e3545bc851c6a4200c7c6e0e23cfc5c25c921618',
      'stdin': userInput,
    };

    final apiUrl = 'https://api.jdoodle.com/v1/execute';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(program),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final output = data['output'];
        setState(() {
          currentResponse = output;
          outputLines.add(currentCommand);
          outputLines.add(currentResponse);
        });
      } else {
        setState(() {
          currentResponse = 'Failed to execute code';
          outputLines.add(currentCommand);
          outputLines.add(currentResponse);
        });
      }
    } catch (error) {
      setState(() {
        currentResponse = 'Error: $error';
        outputLines.add(currentCommand);
        outputLines.add(currentResponse);
      });
    }
    inputController.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Output Page'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: outputLines.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    outputLines[index],
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Enter Input',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final userInput = inputController.text;
                    if (userInput.isNotEmpty) {
                      processUserInput(userInput);
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
