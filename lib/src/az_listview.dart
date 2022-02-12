import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'az_common.dart';
import 'index_bar.dart';
import 'suspension_view.dart';

/// AzListView
class AzListView extends StatefulWidget {
  AzListView({
    Key? key,
    required this.data,
    required this.itemCount,
    required this.itemBuilder,
    this.itemScrollController,
    this.itemPositionsListener,
    this.physics,
    this.padding,
    this.susItemBuilder,
    this.susItemHeight = kSusItemHeight,
    this.susPosition,
    this.indexHintBuilder,
    this.indexBarData = kIndexBarData,
    this.indexBarWidth = kIndexBarWidth,
    this.indexBarHeight,
    this.indexBarItemHeight = kIndexBarItemHeight,
    this.hapticFeedback = false,
    this.indexBarAlignment = Alignment.centerRight,
    this.indexBarMargin,
    this.indexBarOptions = const IndexBarOptions(),
  }) : super(key: key);

  /// with  ISuspensionBean Data
  final List<ISuspensionBean> data;

  /// Number of items the [itemBuilder] can produce.
  final int itemCount;

  /// Called to build children for the list with
  /// 0 <= index < itemCount.
  final IndexedWidgetBuilder itemBuilder;

  /// Controller for jumping or scrolling to an item.
  final ItemScrollController? itemScrollController;

  /// Notifier that reports the items laid out in the list after each frame.
  final ItemPositionsListener? itemPositionsListener;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  /// Called to build suspension header.
  final IndexedWidgetBuilder? susItemBuilder;

  /// Suspension widget Height.
  final double susItemHeight;

  /// Suspension item position.
  final Offset? susPosition;

  /// IndexHintBuilder.
  final IndexHintBuilder? indexHintBuilder;

  /// Index data.
  final List<String> indexBarData;

  /// IndexBar Width.
  final double indexBarWidth;

  /// IndexBar Height.
  final double? indexBarHeight;

  /// IndexBar Item Height.
  final double indexBarItemHeight;

  /// Haptic feedback.
  final bool hapticFeedback;

  /// IndexBar alignment.
  final AlignmentGeometry indexBarAlignment;

  /// IndexBar margin.
  final EdgeInsetsGeometry? indexBarMargin;

  /// IndexBar options.
  final IndexBarOptions indexBarOptions;

  @override
  _AzListViewState createState() => _AzListViewState();
}

class _AzListViewState extends State<AzListView> {
  /// Controller to scroll or jump to a particular item.
  late ItemScrollController itemScrollController;

  /// Listener that reports the position of items when the list is scrolled.
  late ItemPositionsListener itemPositionsListener;

  IndexBarDragListener dragListener = IndexBarDragListener.create();

  final IndexBarController indexBarController = IndexBarController();

  String selectTag = '';

  @override
  void initState() {
    super.initState();
    itemScrollController =
        widget.itemScrollController ?? ItemScrollController();
    itemPositionsListener =
        widget.itemPositionsListener ?? ItemPositionsListener.create();
    dragListener.dragDetails.addListener(_valueChanged);
    if (widget.indexBarOptions.selectItemDecoration != null) {
      itemPositionsListener.itemPositions.addListener(_positionsChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
    dragListener.dragDetails.removeListener(_valueChanged);
    if (widget.indexBarOptions.selectItemDecoration != null) {
      itemPositionsListener.itemPositions.removeListener(_positionsChanged);
    }
  }

  int _getIndex(String tag) {
    for (int i = 0; i < widget.itemCount; i++) {
      ISuspensionBean bean = widget.data[i];
      if (tag == bean.getSuspensionTag()) {
        return i;
      }
    }
    return -1;
  }

  void _scrollTopIndex(String tag) {
    int index = _getIndex(tag);
    if (index != -1) {
      itemScrollController.jumpTo(index: index);
    }
  }

  void _valueChanged() {
    IndexBarDragDetails details = dragListener.dragDetails.value;
    String tag = details.tag!;
    if (details.action == IndexBarDragDetails.actionDown ||
        details.action == IndexBarDragDetails.actionUpdate) {
      selectTag = tag;
      _scrollTopIndex(tag);
    }
  }

  void _positionsChanged() {
    Iterable<ItemPosition> positions =
        itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      ItemPosition itemPosition = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge
                  ? position
                  : min);
      int index = itemPosition.index;
      String tag = widget.data[index].getSuspensionTag();
      if (selectTag != tag) {
        selectTag = tag;
        indexBarController.updateTagIndex(tag);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SuspensionView(
          data: widget.data,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          susItemBuilder: widget.susItemBuilder,
          susItemHeight: widget.susItemHeight,
          susPosition: widget.susPosition,
          padding: widget.padding,
          physics: widget.physics,
        ),
        Align(
          alignment: widget.indexBarAlignment,
          child: IndexBar(
            data: widget.indexBarData,
            width: widget.indexBarWidth,
            height: widget.indexBarHeight,
            itemHeight: widget.indexBarItemHeight,
            margin: widget.indexBarMargin,
            indexHintBuilder: widget.indexHintBuilder,
            indexBarDragListener: dragListener,
            options: widget.indexBarOptions,
            controller: indexBarController,
          ),
        ),
      ],
    );
  }
}
