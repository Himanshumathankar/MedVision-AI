import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_container.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  Uint8List? _previewBytes;
  String? _filename;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() {
      _previewBytes = file.bytes;
      _filename = file.name;
    });
    ref
        .read(predictionControllerProvider.notifier)
        .setImage(file.bytes!, file.name);
  }

  Future<void> _captureFromCamera() async {
    if (kIsWeb) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _previewBytes = bytes;
      _filename = image.name;
    });
    ref.read(predictionControllerProvider.notifier).setImage(bytes, image.name);
  }

  @override
  Widget build(BuildContext context) {
    final predictionState = ref.watch(predictionControllerProvider);
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Breast Cancer Module'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: GlassContainer(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload, size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Mammogram',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Drag & drop or select an image to analyze.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  if (_previewBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _previewBytes!,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (_filename != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _filename!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed:
                        predictionState.isUploading ||
                            predictionState.isPredicting
                        ? null
                        : () async {
                            await ref
                                .read(predictionControllerProvider.notifier)
                                .uploadAndPredict();
                            if (context.mounted) {
                              context.go('/breast/processing');
                            }
                          },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload and Analyze'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select File'),
                      ),
                      const SizedBox(width: 12),
                      if (!kIsWeb)
                        OutlinedButton.icon(
                          onPressed: _captureFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                    ],
                  ),
                  if (predictionState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        predictionState.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
