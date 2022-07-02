import 'package:eyflutter_webview/html_parser.dart';
import 'package:eyflutter_webview/src/replaced_element.dart';
import 'package:eyflutter_webview/style.dart';
import 'package:eyflutter_webview/eyflutter_webview.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

/// [IframeContentElement is a [ReplacedElement] with web content.
class IframeContentElement extends ReplacedElement {
  final String? src;
  final double? width;
  final double? height;
  final NavigationDelegate? navigationDelegate;
  final UniqueKey key = UniqueKey();

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
    return Container(
      width: width ?? (height ?? 150) * 2,
      height: height ?? (width ?? 300) / 2,
      child: Text("Iframes are currently not supported in this environment"),
    );
  }
}
