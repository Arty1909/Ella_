import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:core';


void main() {
  runApp(const WebPage());
}

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: InAppWebView(
           initialUrlRequest: URLRequest(url: Uri.parse('https://liltr.ee/cercis/')),
            // initialUrlRequest:
            // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
            // initialFile: "assets/index.html",
            initialUserScripts: UnmodifiableListView<UserScript>([]),
          ),
        ));
  }
}

class Telegram extends StatelessWidget {
  const Telegram({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: InAppWebView(
           initialUrlRequest: URLRequest(url: Uri.parse('https://web.telegram.org/a/#189506830')),
            initialUserScripts: UnmodifiableListView<UserScript>([]),
          ),
        );
  }
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: InAppWebView(
           initialUrlRequest: URLRequest(url: Uri.parse('https://www.idrlabs.com/multiphasic-personality/test.php')),
            initialUserScripts: UnmodifiableListView<UserScript>([]),
          ),
        );
  }
}