import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:math' as math;
import 'az_common.dart';

const double kSusItemHeight = 40;

/// SuspensionView.
class SuspensionView extends StatefulWidget {
  SuspensionView({
    Key? key,
    required this.data,
    required this.itemCount,
    required this.itemBuilder,
    this.itemScrollController,
    this.itemPositionsListener,
    this.susItemBuilder,
    this.susItemHeight = kSusItemHeight,
    this.susPosition,
    this.physics,
    this.padding,
  }) : super(key: key);

  /// Suspension data.
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

  /// Called to build suspension header.
  final IndexedWidgetBuilder? susItemBuilder;

  /// Suspension item Height.
  final double susItemHeight;

  /// Suspension item position.
  final Offset? susPosition;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  /// The amount of space by which to inset the children.
  final EdgeInsets? padding;

  @override
  _SuspensionViewState createState() => _SuspensionViewState();
}

class _SuspensionViewState extends State<SuspensionView> {
  /// Controller to scroll or jump to a particular item.
  late ItemScrollController itemScrollController;

  /// Listener that reports the position of items when the list is scrolled.
  late ItemPositionsListener itemPositionsListener;

  @override
  void initState() {
    super.initState();
    itemScrollController =
        widget.itemScrollController ?? ItemScrollController();
    itemPositionsListener =
        widget.itemPositionsListener ?? ItemPositionsListener.create();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// build sus widget.
  Widget _buildSusWidget(BuildContext context) {
    if (widget.susItemBuilder == null) {
      return Container();
    }
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: itemPositionsListener.itemPositions,
      builder: (ctx, positions, child) {
        if (positions.isEmpty || widget.itemCount == 0) {
          return Container();
        }
        ItemPosition itemPosition = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
                position.itemTrailingEdge < min.itemTrailingEdge
                    ? position
                    : min);
        if (itemPosition.itemLeadingEdge > 0) return Container();
        int index = itemPosition.index;
        double left = 0;
        double top = 0;
        if (index < widget.itemCount) {
          if (widget.susPosition != null) {
            left = widget.susPosition!.dx;
            top = widget.susPosition!.dy;
          } else {
            int next = math.min(index + 1, widget.itemCount - 1);
            ISuspensionBean bean = widget.data[next];
            if (bean.isShowSuspension) {
              double height =
                  context.findRenderObject()?.paintBounds?.height ?? 0;
              double topTemp = itemPosition.itemTrailingEdge * height;
              top = math.min(widget.susItemHeight, topTemp) -
                  widget.susItemHeight;
            }
          }
        } else {
          index = 0;
        }
        return Positioned(
          left: left,
          top: top,
          child: widget.susItemBuilder!(ctx, index),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    ISuspensionBean bean = widget.data[index];
    if (!bean.isShowSuspension || widget.susItemBuilder == null) {
      return widget.itemBuilder(context, index);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.susItemBuilder!(context, index),
        widget.itemBuilder(context, index),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.itemCount == 0
            ? Container()
            : ScrollablePositionedList.builder(
                itemCount: widget.itemCount,
                itemBuilder: (context, index) => _buildItem(context, index),
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                physics: widget.physics,
                padding: widget.padding,
              ),
        _buildSusWidget(context),
      ],
    );
  }
}
