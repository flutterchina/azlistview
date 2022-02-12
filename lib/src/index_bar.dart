import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

/// IndexHintBuilder.
typedef IndexHintBuilder = Widget Function(BuildContext context, String tag);

/// IndexBarDragListener.
abstract class IndexBarDragListener {
  /// Creates an [IndexBarDragListener] that can be used by a
  /// [IndexBar] to return the drag listener.
  factory IndexBarDragListener.create() => IndexBarDragNotifier();

  /// drag details.
  ValueListenable<IndexBarDragDetails> get dragDetails;
}

/// Internal implementation of [ItemPositionsListener].
class IndexBarDragNotifier implements IndexBarDragListener {
  @override
  final ValueNotifier<IndexBarDragDetails> dragDetails =
      ValueNotifier(IndexBarDragDetails());
}

/// IndexModel.
class IndexBarDragDetails {
  static const int actionDown = 0;
  static const int actionUp = 1;
  static const int actionUpdate = 2;
  static const int actionEnd = 3;
  static const int actionCancel = 4;

  int? action;
  int? index; //current touch index.
  String? tag; //current touch tag.

  double? localPositionY;
  double? globalPositionY;

  IndexBarDragDetails({
    this.action,
    this.index,
    this.tag,
    this.localPositionY,
    this.globalPositionY,
  });
}

///Default Index data.
const List<String> kIndexBarData = const [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '#'
];

const double kIndexBarWidth = 30;

const double kIndexBarItemHeight = 16;

/// IndexBar options.
class IndexBarOptions {
  /// Creates IndexBar options.
  /// Examples.
  /// needReBuild = true
  /// ignoreDragCancel = true
  /// color = Colors.transparent
  /// downColor = Color(0xFFEEEEEE)
  /// decoration
  /// downDecoration
  /// textStyle = TextStyle(fontSize: 12, color: Color(0xFF666666))
  /// downTextStyle = TextStyle(fontSize: 12, color: Colors.white)
  /// selectTextStyle = TextStyle(fontSize: 12, color: Colors.white)
  /// downItemDecoration = BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent)
  /// selectItemDecoration = BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent)
  /// indexHintWidth = 72
  /// indexHintHeight = 72
  /// indexHintDecoration = BoxDecoration(color: Colors.black87, shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(6)),)
  /// indexHintTextStyle = TextStyle(fontSize: 24.0, color: Colors.white)
  /// indexHintChildAlignment = Alignment.center
  /// indexHintAlignment = Alignment.center
  /// indexHintPosition
  /// indexHintOffset
  /// localImages
  const IndexBarOptions({
    this.needRebuild = false,
    this.ignoreDragCancel = false,
    this.hapticFeedback = false,
    this.color,
    this.downColor,
    this.decoration,
    this.downDecoration,
    this.textStyle = const TextStyle(fontSize: 12, color: Color(0xFF666666)),
    this.downTextStyle,
    this.selectTextStyle,
    this.downItemDecoration,
    this.selectItemDecoration,
    this.indexHintWidth = 72,
    this.indexHintHeight = 72,
    this.indexHintDecoration = const BoxDecoration(
      color: Colors.black87,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    this.indexHintTextStyle =
        const TextStyle(fontSize: 24.0, color: Colors.white),
    this.indexHintChildAlignment = Alignment.center,
    this.indexHintAlignment = Alignment.center,
    this.indexHintPosition,
    this.indexHintOffset = Offset.zero,
    this.localImages = const [],
  });

  /// need to rebuild.
  final bool needRebuild;

  /// Ignore DragCancel.
  final bool ignoreDragCancel;

  /// Haptic feedback.
  final bool hapticFeedback;

  /// IndexBar background color.
  final Color? color;

  /// IndexBar down background color.
  final Color? downColor;

  /// IndexBar decoration.
  final Decoration? decoration;

  /// IndexBar down decoration.
  final Decoration? downDecoration;

  /// IndexBar textStyle.
  final TextStyle textStyle;

  /// IndexBar down textStyle.
  final TextStyle? downTextStyle;

  /// IndexBar select textStyle.
  final TextStyle? selectTextStyle;

  /// IndexBar down item decoration.
  final Decoration? downItemDecoration;

  /// IndexBar select item decoration.
  final Decoration? selectItemDecoration;

  /// Index hint width.
  final double indexHintWidth;

  /// Index hint height.
  final double indexHintHeight;

  /// Index hint decoration.
  final Decoration indexHintDecoration;

  /// Index hint alignment.
  final Alignment indexHintAlignment;

  /// Index hint child alignment.
  final Alignment indexHintChildAlignment;

  /// Index hint textStyle.
  final TextStyle indexHintTextStyle;

  /// Index hint position.
  final Offset? indexHintPosition;

  /// Index hint offset.
  final Offset indexHintOffset;

  /// local images.
  final List<String> localImages;
}

/// IndexBarController.
class IndexBarController {
  _IndexBarState? _indexBarState;

  bool get isAttached => _indexBarState != null;

  void updateTagIndex(String tag) {
    _indexBarState?._updateTagIndex(tag);
  }

  void _attach(_IndexBarState state) {
    _indexBarState = state;
  }

  void _detach() {
    _indexBarState = null;
  }
}

/// IndexBar.
class IndexBar extends StatefulWidget {
  IndexBar({
    Key? key,
    this.data = kIndexBarData,
    this.width = kIndexBarWidth,
    this.height,
    this.itemHeight = kIndexBarItemHeight,
    this.margin,
    this.indexHintBuilder,
    IndexBarDragListener? indexBarDragListener,
    this.options = const IndexBarOptions(),
    this.controller,
  })  : indexBarDragNotifier = indexBarDragListener as IndexBarDragNotifier?,
        super(key: key);

  /// Index data.
  final List<String> data;

  /// IndexBar width(def:30).
  final double width;

  /// IndexBar height.
  final double? height;

  /// IndexBar item height(def:16).
  final double itemHeight;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// IndexHint Builder
  final IndexHintBuilder? indexHintBuilder;

  /// IndexBar drag listener.
  final IndexBarDragNotifier? indexBarDragNotifier;

  /// IndexBar options.
  final IndexBarOptions options;

  /// IndexBarController. If non-null, this can be used to control the state of the IndexBar.
  final IndexBarController? controller;

  @override
  _IndexBarState createState() => _IndexBarState();
}

class _IndexBarState extends State<IndexBar> {
  /// overlay entry.
  static OverlayEntry? overlayEntry;

  double floatTop = 0;
  String indexTag = '';
  int selectIndex = 0;
  int action = IndexBarDragDetails.actionEnd;

  @override
  void initState() {
    super.initState();
    widget.indexBarDragNotifier?.dragDetails?.addListener(_valueChanged);
    widget.controller?._attach(this);
  }

  void _valueChanged() {
    if (widget.indexBarDragNotifier == null) return;
    IndexBarDragDetails details =
        widget.indexBarDragNotifier!.dragDetails.value;
    selectIndex = details.index!;
    indexTag = details.tag!;
    action = details.action!;
    floatTop = details.globalPositionY! +
        widget.itemHeight / 2 -
        widget.options.indexHintHeight / 2;

    if (_isActionDown()) {
      _addOverlay(context);
    } else {
      _removeOverlay();
    }

    if (widget.options.needRebuild) {
      if (widget.options.ignoreDragCancel &&
          action == IndexBarDragDetails.actionCancel) {
      } else {
        setState(() {});
      }
    }
  }

  bool _isActionDown() {
    return action == IndexBarDragDetails.actionDown ||
        action == IndexBarDragDetails.actionUpdate;
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _removeOverlay();
    widget.indexBarDragNotifier?.dragDetails?.removeListener(_valueChanged);
    super.dispose();
  }

  Widget _buildIndexHint(BuildContext context, String tag) {
    if (widget.indexHintBuilder != null) {
      return widget.indexHintBuilder!(context, tag);
    }
    Widget child;
    TextStyle textStyle = widget.options.indexHintTextStyle;
    List<String> localImages = widget.options.localImages;
    if (localImages.contains(tag)) {
      child = Image.asset(
        tag,
        width: textStyle.fontSize,
        height: textStyle.fontSize,
        color: textStyle.color,
      );
    } else {
      child = Text('$tag', style: textStyle);
    }
    return Container(
      width: widget.options.indexHintWidth,
      height: widget.options.indexHintHeight,
      alignment: widget.options.indexHintChildAlignment,
      decoration: widget.options.indexHintDecoration,
      child: child,
    );
  }

  /// add overlay.
  void _addOverlay(BuildContext context) {
    OverlayState? overlayState = Overlay.of(context);
    if (overlayState == null) return;
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(builder: (BuildContext ctx) {
        double left;
        double top;
        if (widget.options.indexHintPosition != null) {
          left = widget.options.indexHintPosition!.dx;
          top = widget.options.indexHintPosition!.dy;
        } else {
          if (widget.options.indexHintAlignment == Alignment.centerRight) {
            left = MediaQuery.of(context).size.width -
                kIndexBarWidth -
                widget.options.indexHintWidth +
                widget.options.indexHintOffset.dx;
            top = floatTop + widget.options.indexHintOffset.dy;
          } else if (widget.options.indexHintAlignment ==
              Alignment.centerLeft) {
            left = kIndexBarWidth + widget.options.indexHintOffset.dx;
            top = floatTop + widget.options.indexHintOffset.dy;
          } else {
            left = MediaQuery.of(context).size.width / 2 -
                widget.options.indexHintWidth / 2 +
                widget.options.indexHintOffset.dx;
            top = MediaQuery.of(context).size.height / 2 -
                widget.options.indexHintHeight / 2 +
                widget.options.indexHintOffset.dy;
          }
        }
        return Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: _buildIndexHint(ctx, indexTag),
            ));
      });
      overlayState.insert(overlayEntry!);
    } else {
      //重新绘制UI，类似setState
      overlayEntry?.markNeedsBuild();
    }
  }

  /// remove overlay.
  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Widget _buildItem(BuildContext context, int index) {
    String tag = widget.data[index];
    Decoration? decoration;
    TextStyle? textStyle;
    if (widget.options.downItemDecoration != null) {
      decoration = (_isActionDown() && selectIndex == index)
          ? widget.options.downItemDecoration
          : null;
      textStyle = (_isActionDown() && selectIndex == index)
          ? widget.options.downTextStyle
          : widget.options.textStyle;
    } else if (widget.options.selectItemDecoration != null) {
      decoration =
          (selectIndex == index) ? widget.options.selectItemDecoration : null;
      textStyle = (selectIndex == index)
          ? widget.options.selectTextStyle
          : widget.options.textStyle;
    } else {
      textStyle = _isActionDown()
          ? (widget.options.downTextStyle ?? widget.options.textStyle)
          : widget.options.textStyle;
    }

    Widget child;
    List<String> localImages = widget.options.localImages;
    if (localImages.contains(tag)) {
      child = Image.asset(
        tag,
        width: textStyle?.fontSize,
        height: textStyle?.fontSize,
        color: textStyle?.color,
      );
    } else {
      child = Text('$tag', style: textStyle);
    }

    return Container(
      alignment: Alignment.center,
      decoration: decoration,
      child: child,
    );
  }

  void _updateTagIndex(String tag) {
    if (_isActionDown()) return;
    selectIndex = widget.data.indexOf(tag);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _isActionDown() ? widget.options.downColor : widget.options.color,
      decoration: _isActionDown()
          ? widget.options.downDecoration
          : widget.options.decoration,
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      alignment: Alignment.center,
      child: BaseIndexBar(
        data: widget.data,
        width: widget.width,
        itemHeight: widget.itemHeight,
        hapticFeedback: widget.options.hapticFeedback,
        itemBuilder: (BuildContext context, int index) {
          return _buildItem(context, index);
        },
        indexBarDragNotifier: widget.indexBarDragNotifier,
      ),
    );
  }
}

class BaseIndexBar extends StatefulWidget {
  BaseIndexBar({
    Key? key,
    this.data = kIndexBarData,
    this.width = kIndexBarWidth,
    this.itemHeight = kIndexBarItemHeight,
    this.hapticFeedback = false,
    this.textStyle = const TextStyle(fontSize: 12.0, color: Color(0xFF666666)),
    this.itemBuilder,
    this.indexBarDragNotifier,
  }) : super(key: key);

  /// index data.
  final List<String> data;

  /// IndexBar width(def:30).
  final double width;

  /// IndexBar item height(def:16).
  final double itemHeight;

  /// Haptic feedback.
  final bool hapticFeedback;

  /// IndexBar text style.
  final TextStyle textStyle;

  final IndexedWidgetBuilder? itemBuilder;

  final IndexBarDragNotifier? indexBarDragNotifier;

  @override
  _BaseIndexBarState createState() => _BaseIndexBarState();
}

class _BaseIndexBarState extends State<BaseIndexBar> {
  int lastIndex = -1;
  int _widgetTop = 0;

  /// get index.
  int _getIndex(double offset) {
    int index = offset ~/ widget.itemHeight;
    return math.min(index, widget.data.length - 1);
  }

  /// trigger drag event.
  _triggerDragEvent(int action) {
    if (widget.hapticFeedback &&
        (action == IndexBarDragDetails.actionDown ||
            action == IndexBarDragDetails.actionUpdate)) {
      HapticFeedback.vibrate();
    }
    widget.indexBarDragNotifier?.dragDetails?.value = IndexBarDragDetails(
      action: action,
      index: lastIndex,
      tag: widget.data[lastIndex],
      localPositionY: lastIndex * widget.itemHeight,
      globalPositionY: lastIndex * widget.itemHeight + _widgetTop,
    );
  }

  RenderBox? _getRenderBox(BuildContext context) {
    RenderObject? renderObject = context.findRenderObject();
    RenderBox? box;
    if (renderObject != null) {
      box = renderObject as RenderBox;
    }
    return box;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List.generate(widget.data.length, (index) {
      Widget child = widget.itemBuilder == null
          ? Center(
              child: Text('${widget.data[index]}', style: widget.textStyle))
          : widget.itemBuilder!(context, index);
      return SizedBox(
        width: widget.width,
        height: widget.itemHeight,
        child: child,
      );
    });

    return GestureDetector(
      onVerticalDragDown: (DragDownDetails details) {
        RenderBox? box = _getRenderBox(context);
        if (box == null) return;
        Offset topLeftPosition = box.localToGlobal(Offset.zero);
        _widgetTop = topLeftPosition.dy.toInt();
        int index = _getIndex(details.localPosition.dy);
        if (index >= 0) {
          lastIndex = index;
          _triggerDragEvent(IndexBarDragDetails.actionDown);
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        int index = _getIndex(details.localPosition.dy);
        if (index >= 0 && lastIndex != index) {
          lastIndex = index;
          //HapticFeedback.lightImpact();
          //HapticFeedback.vibrate();
          _triggerDragEvent(IndexBarDragDetails.actionUpdate);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        _triggerDragEvent(IndexBarDragDetails.actionEnd);
      },
      onVerticalDragCancel: () {
        _triggerDragEvent(IndexBarDragDetails.actionCancel);
      },
      onTapUp: (TapUpDetails details) {
        //_triggerDragEvent(IndexBarDragDetails.actionUp);
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
