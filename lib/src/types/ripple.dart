// @copyright @polymer\paper-ripple\paper-ripple.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
const int RIPPLE_MAX_RADIUS = 300;

///
/// Ripple effect for alg-component used with alg-paper-ripple
///
class Ripple {
  /// Constructor
  Ripple(AlgPaperRipple this.element) {
    color = element.getComputedStyle().color;

    wave = document.createElement('div')
        ..style.backgroundColor = color
        ..classes.add('wave');

    waveContainer = document.createElement('div')
        ..append(wave)
        ..classes.add('wave-container');

    resetInteractionState();
  }

  ///
  bool get center => element.center;

  ///
  String color;

  ///
  ElementMetrics containerMetrics;

  ///
  double get initialOpacity => element.initialOpacity;

  ///
  AlgPaperRipple element;

  ///
  bool get isAnimationComplete =>
      mouseUpStart != null ? isOpacityFullyDecayed : isRestingAtMaxRadius;

  ///
  bool get isMouseDown => (mouseDownStart != null) && (mouseUpStart == null);

  ///
  bool get isOpacityFullyDecayed =>
      (opacity < 0.01) && (radius >= Math.min(maxRadius, RIPPLE_MAX_RADIUS));

  ///
  bool get isRestingAtMaxRadius =>
      (opacity >= initialOpacity) && (radius >= Math.min(maxRadius, RIPPLE_MAX_RADIUS));

  ///
  num maxRadius;

  ///
  double mouseDownStart;

  ///
  double get mouseDownElapsed {
    if (mouseDownStart == null) return 0.0;

    double elapsed = Utility.now() - mouseDownStart;
    if (mouseUpStart != null) {
      elapsed -= mouseUpElapsed;
    }

    return elapsed;
  }

  ///
  double get mouseDownElapsedSeconds => mouseDownElapsed / 1000;

  ///
  double get mouseInteractionSeconds => mouseDownElapsedSeconds + mouseUpElapsedSeconds;

  ///
  double get mouseUpElapsed =>
      (mouseUpStart != null) ? (Utility.now() - mouseUpStart) : 0;

  ///
  double get mouseUpElapsedSeconds => mouseUpElapsed / 1000;

  ///
  double mouseUpStart;

  ///
  double get opacity {
    if (mouseUpStart == null) return initialOpacity;

    return Math.max(
      0.0,
      initialOpacity - mouseUpElapsedSeconds * opacityDecayVelocity
    );
  }

  ///
  double get opacityDecayVelocity => element.opacityDecayVelocity;

  /// Linear increase in background opacity, capped at the opacity
  /// of the wavefront (waveOpacity).
  double get outerOpacity {
    final double outerOpacity = mouseUpElapsedSeconds * 0.3;
    final double waveOpacity = opacity;

    return Math.max(0.0, Math.min(outerOpacity, waveOpacity));
  }

  ///
  double get radius {
    final double width2 = Math.pow(containerMetrics.width, 2);
    final double height2 = Math.pow(containerMetrics.height, 2);
    final double waveRadius = Math.min(Math.sqrt(width2 + height2), RIPPLE_MAX_RADIUS) * 1.1 + 5;

    final double duration = 1.1 - 0.2 * (waveRadius / RIPPLE_MAX_RADIUS);
    final double timeNow = mouseInteractionSeconds / duration;
    final double size = waveRadius * (1 - Math.pow(80, -timeNow));

    return size.abs();
  }

  ///
  bool get recenters => element.recenters;

  ///
  double slideDistance = 0.0;

  ///
  double get translationFraction => Math.min(
    1.0,
    radius / containerMetrics.size * 2 / Math.sqrt(2)
  );

  ///
  HtmlElement wave;

  ///
  HtmlElement waveContainer;

  ///
  num xEnd = 0;

  ///
  num get xNow => xEnd != 0
      ? xStart + translationFraction * (xEnd - xStart)
      : xStart;

  ///
  num xStart = 0;

  ///
  num yEnd = 0;

  ///
  num get yNow => yEnd != 0
      ? yStart + translationFraction * (yEnd - yStart)
      : yStart;

  ///
  num yStart = 0;

  ///
  void downAction(Event event) {
    final double xCenter = containerMetrics.width / 2;
    final double yCenter = containerMetrics.height / 2;

    resetInteractionState();
    mouseDownStart = Utility.now();

    if (center) {
      xStart = xCenter;
      yStart = yCenter;
      slideDistance = Utility.distance(xStart, yStart, xEnd, yEnd);
    } else {
      xStart = (event is MouseEvent )
          ? event.client.x - containerMetrics.boundingRect.left
          : containerMetrics.width / 2;
      yStart = (event is MouseEvent)
          ? event.client.y - containerMetrics.boundingRect.top
          : containerMetrics.height / 2;
    }

    if (recenters) {
      xEnd = xCenter;
      yEnd = yCenter;
      slideDistance = Utility.distance(xStart, yStart, xEnd, yEnd);
    }

    maxRadius = containerMetrics.furthestCornerDistanceFrom(xStart, yStart);

    final String top = ((containerMetrics.height - containerMetrics.size) / 2).toString();
    final String left = ((containerMetrics.width - containerMetrics.size) / 2).toString();
    final String size = containerMetrics.size.toString();

    waveContainer.style
      ..top = '${top}px'
      ..left = '${left}px'
      ..width = '${size}px'
      ..height = '${size}px';
  }

  ///
  void draw() {
    final String scale = (radius / (containerMetrics.size / 2)).toString();
    final String dx = (xNow - (containerMetrics.width / 2)).toString();
    final String dy = (yNow - (containerMetrics.height / 2)).toString();

    waveContainer.style.transform = 'translate3d(${dx}px, ${dy}px, 0';

    wave
        ..style.opacity = opacity.toString()
        ..style.transform = 'scale3d($scale, $scale, 1)';
  }

  ///
  void remove() => waveContainer.remove();

  ///
  void resetInteractionState() {
    maxRadius = 0;
    mouseDownStart = null;
    mouseUpStart = null;

    xStart = 0;
    yStart = 0;
    xEnd = 0;
    yEnd = 0;
    slideDistance = 0.0;

    containerMetrics = new ElementMetrics(element);
  }

  ///
  void upAction(Event event) {
    if (!isMouseDown) return;

    mouseUpStart = Utility.now();
  }
}

// --------------------------------------------------- Aux classes

///
class ElementMetrics {
  /// Constructor
  ElementMetrics(HtmlElement this.element) {
    width = boundingRect.width;
    height = boundingRect.height;
    size = Math.max(width, height);
  }

  ///
  HtmlElement element;

  ///
  num height;

  ///
  num size;

  ///
  num width;

  ///
  Rectangle<num> get boundingRect => element.getBoundingClientRect();

  ///
  num furthestCornerDistanceFrom(num x, num y) {
    final num topLeft = Utility.distance(x, y, 0, 0);
    final num topRight = Utility.distance(x, y, width, 0);
    final num bottomLeft = Utility.distance(x, y, 0, height);
    final num bottomRight = Utility.distance(x, y, width, height);

    return Math.max(
        Math.max(topLeft, topRight),
        Math.max(bottomLeft, bottomRight));
  }
}

///
/// Aux Ripple functions
///
class Utility {
  ///
  static num distance(num x1, num y1, num x2, num y2) {
    final num xDelta = x1 - x2;
    final num yDelta = y1 - y2;

    return Math.sqrt(xDelta * xDelta + yDelta * yDelta);
  }

  ///
  static double now() => window.performance.now();
}
