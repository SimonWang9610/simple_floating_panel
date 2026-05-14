enum ResizeDirection {
  left,
  right,
  up,
  down,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  bool get isLeftEdge =>
      this == ResizeDirection.left || this == ResizeDirection.topLeft || this == ResizeDirection.bottomLeft;

  bool get isRightEdge =>
      this == ResizeDirection.right || this == ResizeDirection.topRight || this == ResizeDirection.bottomRight;

  bool get isTopEdge =>
      this == ResizeDirection.up || this == ResizeDirection.topLeft || this == ResizeDirection.topRight;

  bool get isBottomEdge =>
      this == ResizeDirection.down || this == ResizeDirection.bottomLeft || this == ResizeDirection.bottomRight;
}
