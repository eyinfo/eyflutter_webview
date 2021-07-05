import 'package:flutter/material.dart';
import 'package:webview_flutter/flutter_html.dart';
import 'package:webview_flutter/src/layout_element.dart';
import 'package:webview_flutter/style.dart';

mixin OnHtmlStateController {
  void notifyHtml(String html);
}

typedef OnHtmlStateCall = void Function(OnHtmlStateController controller);

class HtmlWidget extends StatefulWidget {
  /// html内容
  final String? html;

  /// controller call
  final OnHtmlStateCall? stateCall;

  const HtmlWidget({Key? key, this.html, this.stateCall}) : super(key: key);

  @override
  _HtmlWidgetState createState() => _HtmlWidgetState();
}

class _HtmlWidgetState extends State<HtmlWidget> implements OnHtmlStateController {
  String _htmlData="";

  @override
  void initState() {
    _htmlData = widget.html??"";
    if (widget.stateCall != null) {
      widget.stateCall!(this);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Html(
        data: _htmlData,
        style: {
          "table": Style(
            backgroundColor: Color.fromARGB(0x50, 0xee, 0xee, 0xee),
          ),
          "tr": Style(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          "th": Style(
            padding: EdgeInsets.all(6),
            backgroundColor: Colors.grey,
          ),
          "td": Style(
            padding: EdgeInsets.all(6),
            alignment: Alignment.topLeft,
          ),
          'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
        },
        customRender: {
          "table": (context, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: (context.tree as TableLayoutElement).toWidget(context),
            );
          }
        },
        customImageRenders: {},
        onLinkTap: (url, _, __, ___) {},
      ),
    );
  }

  /// 更新页面渲染
  void notifyHtml(String? html) {
    if (html != null && html.isNotEmpty) {
      setState(() {
        _htmlData = html;
      });
    }
  }
}
