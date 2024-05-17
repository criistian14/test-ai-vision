// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geminis_open_ia/utils/image_utils.dart';
import 'package:geminis_open_ia/utils/messages_utils.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final _apiKey = dotenv.env['GEMINI_API_KEY'];
  GenerativeModel? _visionModel;

  bool _isLoading = true;
  bool _isActionsLoading = false;
  Exception? _error;

  late final Uint8List image;

  @override
  void initState() {
    super.initState();

    final imageUtils = ImageUtils();
    if (imageUtils.image == null) {
      MessagesUtils.showSnackbar(context, message: "No hay imagen");
      Navigator.pop(context);
      return;
    }

    image = ImageUtils().image!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_apiKey == null) {
        setState(() {
          _error = Exception("Add a API KEY in .env");
          _isLoading = false;
        });
        return;
      }

      _visionModel = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: _apiKey,
      );

      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini - Google"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    if (_error != null)
                      Text(
                        _error.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(
                      height: size.height * 0.55,
                      child: Image.memory(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // * Actions
                    SizedBox(height: size.height * 0.03),
                    _isActionsLoading
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              // * Count words
                              ElevatedButton(
                                onPressed: _getAllWords,
                                child: const Text("Obtener total palabras"),
                              ),

                              // * Validate if is a person
                              ElevatedButton(
                                onPressed: _validatePerson,
                                child: const Text("Es una persona"),
                              ),

                              // * Validate if is a house or apartment
                              ElevatedButton(
                                onPressed: _validateHouse,
                                child: const Text("Es una casa o apartamento"),
                              ),
                            ],
                          ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _getAllWords() async {
    if (_isActionsLoading) return;
    setState(() => _isActionsLoading = true);

    await _sendPrompt(
      "Dime cuantas palabras hay en el documento de la imagen, en caso de haber una palabra que este en otra pocision cuenta la de todas formas, en caso de que no sea un documento retorna false, solo dime el numero sin explicaciones ni nada.",
    );

    setState(() => _isActionsLoading = false);
  }

  Future<void> _validatePerson() async {
    if (_isActionsLoading) return;
    setState(() => _isActionsLoading = true);

    const percent = 80;
    await _sendPrompt(
      "Dime si en la image aparece una persona y que ocupe mas del $percent% de la imagen, solo dime si es true o false sin explicaciones ni nada.",
    );

    setState(() => _isActionsLoading = false);
  }

  Future<void> _validateHouse() async {
    if (_isActionsLoading) return;
    setState(() => _isActionsLoading = true);

    const percent = 80;
    await _sendPrompt(
      "Dime si en la image aparece una casa o apartamento y que ocupe mas del $percent% de la imagen, solo dime si es true o false sin explicaciones ni nada.",
    );

    setState(() => _isActionsLoading = false);
  }

  Future<void> _sendPrompt(String prompt) async {
    final mimeType = lookupMimeType('', headerBytes: image);
    if (mimeType == null) {
      MessagesUtils.showSnackbar(
        context,
        message: "No se pudo determinar el tipo MIME de la imagen",
      );
      setState(() => _isActionsLoading = false);
      return;
    }

    String? responseText;

    try {
      final promptToSend = TextPart(prompt);

      final List<Content> content = [
        Content.multi([
          promptToSend,
          DataPart(mimeType, image),
        ]),
      ];
      final response = await _visionModel?.generateContent(content);

      responseText = response?.text;
    } catch (e) {
      responseText = e.toString();
    }

    MessagesUtils.showSnackbar(
      context,
      message: responseText ?? "Sin respuesta",
    );
  }
}
