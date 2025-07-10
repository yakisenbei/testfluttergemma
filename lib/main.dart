import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _response = '';
  bool isCreatemodel = false;
  dynamic session;
  Future<Stream<String>> _talkGemma() async {
    //final String? modelpath = await downloadmodel();
    //if (modelpath == null) {
    //  throw Exception('Failed to get model path');
    //}
    final gemma = FlutterGemmaPlugin.instance;
    final modelManager = gemma.modelManager;
    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/gemma3-1B-it-int4.task';
    
    print(await modelManager.isModelInstalled);
    
    if (!await modelManager.isModelInstalled) {
      modelManager.downloadModelFromNetworkWithProgress("gemma3-1B-it-int4.task").listen(
        (progress) {
          print('Loading progress: $progress%');
        },
        onDone: () {
          print('Model loading complete.');
        },
        onError: (error) {
          print('Error loadirng model: $error');
        },
      );
    }
    
    print(isCreatemodel);
      final inferenceModel = await FlutterGemmaPlugin.instance.createModel(
        modelType: ModelType.gemmaIt, // Required, model type to create
        maxTokens: 512, // Optional, default is 1024  
      );  
      session = await inferenceModel.createSession(
        temperature: 0,
      );
      // システムプロンプトを設定
      await session.addQueryChunk(Message(text: 'System: You are an AI that generates English sentence.'));
    isCreatemodel = true;
    await session.addQueryChunk(Message(text: 'Create 3 sentences using the "how about".'));
    return session.getResponseAsync();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemma Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_response),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final responseStream = await _talkGemma();
                setState(() {
                  _response = '';
                });
                responseStream.listen(
                  (token) {
                    setState(() {
                      _response += token;
                    });
                  },
                  onDone: () {
                    print(_response);
                  },
                  onError: (error) {
                    print('Error: $error');
                  },
                );
              },
              child: const Text('Ask Gemma'),
            ),
          ],
        ),
      ),
    );
  }
}
