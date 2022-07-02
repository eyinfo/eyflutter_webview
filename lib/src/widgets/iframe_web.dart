// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:eyflutter_webview/eyflutter_webview.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:eyflutter_webview/html_parser.dart';
import 'package:eyflutter_webview/shims/dart_ui.dart' as ui;
import 'package:eyflutter_webview/src/replaced_element.dart';
import 'package:eyflutter_webview/src/utils.dart';
import 'package:eyflutter_webview/style.dart';

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();
  final String createdViewId = getRandString(10);

  IframeContentElement({
    required String name,
    required this.src,
    required this.width,
    required this.height,
    required dom.Element node,
    required this.navigationDelegate,
  }) : super(name: name, style: Style(), node: node, elementId: node.id);

  @override
  Widget toWidget(RenderContext context) {
    final html.IFrameElement iframe = html.IFrameElement()
      ..width = (width ?? (height ?? 150) * 2).toString()
      ..height = (height ?? (width ?? 300) / 2).toString()
      ..src = src
      ..style.border = 'none';
    //not actually an error
    ui.platformViewRegistry.registerViewFactory(createdViewId, (int viewId) => iframe);
    return Container(
        width: width ?? (height ?? 150) * 2,
        height: height ?? (width ?? 300) / 2,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: HtmlElementView(
              viewType: createdViewId,
            )));
  }
}
