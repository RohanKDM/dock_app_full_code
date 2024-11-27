import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: AnimatedDock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedDock extends StatefulWidget {
  final List<IconData> items;

  const AnimatedDock({
    super.key,
    required this.items,
  });

  @override
  State<AnimatedDock> createState() => _AnimatedDockState();
}

class _AnimatedDockState extends State<AnimatedDock> {
  late List<IconData> _items;
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final isHovering = _hoverIndex == index;

            return DragTarget<int>(
              onWillAcceptWithDetails: (draggingIndex) {
                if (draggingIndex.data != index) {
                  setState(() {
                    _draggingIndex = index;
                    _hoverIndex = index;
                  });
                }
                print('onWillAcceptWithDetails');
                return true;
              },
              onLeave: (_) {
                setState(() => _hoverIndex = null);
              },
              onAcceptWithDetails: (_) {
                print('$index onAcceptWithDetails ${_.data}');
                setState(() {
                  final draggedIndex = _.data;
                  if (draggedIndex != index) {
                    final draggedItem = _items.removeAt(draggedIndex);

                    _items.insert(index, draggedItem);
                  }
                  _hoverIndex = null;
                  _draggingIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  margin: EdgeInsets.only(
                    left: isHovering ? 64 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Draggable<int>(
                      data: index,
                      feedback: _buildDockItem(_items[index], true),
                      childWhenDragging: const SizedBox.shrink(),
                      onDragStarted: () =>
                          setState(() => _draggingIndex = index),
                      onDragEnd: (_) => setState(() => _draggingIndex = null),
                      child: _buildDockItem(
                        _items[index],
                        _draggingIndex == index || isHovering,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDockItem(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}
