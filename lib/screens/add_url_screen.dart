import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_provider.dart';

class AddUrlScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAdded;

  const AddUrlScreen({super.key, this.onAdded});

  @override
  ConsumerState<AddUrlScreen> createState() => _AddUrlScreenState();
}

class _AddUrlScreenState extends ConsumerState<AddUrlScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(videoProvider.notifier).extractVideoFromUrl(url);
      if (mounted) {
        _urlController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レシピを追加しました')),
        );
        widget.onAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'YouTubeの動画または再生リストのURLを入力',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onSubmitted: (_) => _addRecipe(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addRecipe,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('追加'),
            ),
          ),
        ],
      ),
    );
  }
}
