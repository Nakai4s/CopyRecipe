import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/utilities/text_extract_utils.dart';

class RecipeScreen extends ConsumerWidget {
  final Video video;
  
  const RecipeScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CopyRecipe'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Container(        
        padding: const EdgeInsets.all(25.0),
        child: Column(          
          children: [
            Text(video.title, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
            const SizedBox(height: 20.0),
            Text(
              TextExtractUtils.extractRecipe(video.description)!,
            ),
          ],
        )
      ),
    );
  }
}