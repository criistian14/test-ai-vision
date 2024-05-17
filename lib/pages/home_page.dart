import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:geminis_open_ia/utils/image_utils.dart';

import 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DocumentScanner(
        generalStyles: const GeneralStyles(
          hideDefaultDialogs: true,
        ),
        onSave: (Uint8List imageBytes) {
          final imageUtils = ImageUtils();
          imageUtils.image = imageBytes;

          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GeminiPage(),
                        ),
                      );
                    },
                    title: const Text("Gemini"),
                  ),

                  //
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OpenAIPage(),
                        ),
                      );
                    },
                    title: const Text("Open AI"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
