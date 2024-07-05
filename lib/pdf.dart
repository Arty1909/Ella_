import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Book extends StatelessWidget {
  const Book({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfPdfViewer.asset('assets/ITGSE.pdf'),
    );
  }
}

//https://www.unfpa.org/sites/default/files/pub-pdf/ITGSE.pdf