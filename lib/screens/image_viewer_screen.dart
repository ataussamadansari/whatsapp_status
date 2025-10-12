import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const ImageViewerScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 3,
              child: Image.file(File(imagePath)),
            ),
          ),

          Positioned(
            top: 36,
            left: 8,
            child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.withValues(alpha: 0.5),
                  foregroundColor: Colors.white
                ),
                icon: Icon(Icons.arrow_back)),
          ),
        ],
      )
      /*Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1,
          maxScale: 5,
          child: Image.file(File(imagePath)),
        ),
      ),*/
    );
  }
}