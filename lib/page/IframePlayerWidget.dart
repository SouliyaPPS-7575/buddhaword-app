// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IframePlayerWidget extends StatelessWidget {
  final String iframeUrl;

  const IframePlayerWidget({super.key, required this.iframeUrl});

  @override
  Widget build(BuildContext context) {
    // Check if iframeUrl is empty and hide the widget if it is
    if (iframeUrl.isEmpty) {
      return const SizedBox
          .shrink(); // Return an empty SizedBox to hide the widget
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 30,
        child: WebView(
          backgroundColor: Colors.transparent,
          initialUrl: iframeUrl, // Load the URL directly
          allowsInlineMediaPlayback: true,
          javascriptMode: JavascriptMode.unrestricted,
          onWebResourceError: (error) {
            if (kDebugMode) {
              print(error);
            }
          },
        ),
      ),
    );
  }
}
