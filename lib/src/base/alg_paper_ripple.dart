// @copyright @polymer\paper-ripple\paper-ripple.js
// @copyright 2017-2018 adalberto.lacruz@gmail.com

part of core.alg_components;

///
/// Ripple effect
///
/// External Properties: .noink = true | false
/// External Methods:    .simulateRipple()
///
/// Trigger Event: 'transitionend'.
///  with event == {node: Object} the animated node.
///  Fired when the animation finishes. This is useful if you want to wait until
///  the ripple animation finishes to perform some action.
///
class AlgPaperRipple extends AlgComponent {
  ///
  static String tag = 'alg-paper-ripple';

  ///
  factory AlgPaperRipple() => new Element.tag(tag);

  ///
  AlgPaperRipple.created() : super.created();

  ///
  static void register() => AlgComponent.register(tag, AlgPaperRipple);
  @override
  TemplateElement createTemplateStyle(RulesInstance css) => new TemplateElement()..setInnerHtml('''
    <style>
      :host {
        display: block;
        position: absolute;
        border-radius: inherit;
        overflow: hidden;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;

        /* See PolymerElements/paper-behaviors/issues/34. On non-Chrome browsers,
        * creating a node (with a position:absolute) in the middle of an event
        * handler "interrupts" that event handler (which happens when the
        * ripple is created on demand) */
        pointer-events: none;
      }

      :host([animating]) {
        /* This resolves a rendering issue in Chrome (as of 40) where the
          ripple is not properly clipped by its parent (which may have
          rounded corners). See: http://jsbin.com/temexa/4

          Note: We only apply this style conditionally. Otherwise, the browser
          will create a new compositing layer for every ripple element on the
          page, and that would be bad. */
        -webkit-transform: translate(0, 0);
        transform: translate3d(0, 0, 0);
      }

      #background,
      #waves,
      .wave-container,
      .wave {
        pointer-events: none;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
      }

      #background,
      .wave {
        opacity: 0;
      }

      #waves,
      .wave {
        overflow: hidden;
      }

      .wave-container,
      .wave {
        border-radius: 50%;
      }

      :host(.circle) #background,
      :host(.circle) #waves {
        border-radius: 50%;
      }

      :host(.circle) .wave-container {
        overflow: hidden;
      }
    </style>''', treeSanitizer: NodeTreeSanitizer.trusted);


  @override
  TemplateElement createTemplate() => super.createTemplate()..setInnerHtml('''
    <div id="background"></div>
    <div id="waves"></div>''', treeSanitizer: NodeTreeSanitizer.trusted);

  @override
  void deferredConstructor() {
    super.deferredConstructor();

    attributeManager
      // True when there are visible ripples animating within the element.
      ..define('animating', type: TYPE_BOOL)
      ..reflect()

      ..define('center', type: TYPE_BOOL, isPreBinded: true)

      ..define('classbind', type: TYPE_STRING, isPreBinded: true)
      ..on((String value) {
        AttributeManager.classUpdate(this, value);
      })

      // If true, the ripple will remain in the "down" state until `holdDown` is set to false again.
      // holdDown does not respect noink since it can be a focus based effect.
      // Changed outside the component.
      ..define('holdDown', type: TYPE_BOOL)
      ..onLink((bool value, Map<String, dynamic> context) {
        final Event event = context['event'];
        value
            ? new Future<void>(() => downAction(event))
            : new Future<void>(() => upAction(event));
      })

      ..define('noink', type: TYPE_BOOL, isPreBinded: true)

      ..define('recenters', type: TYPE_BOOL, isPreBinded: true);

    animating$ = attributeManager.get('animating');
    center$ = attributeManager.get('center');
    holdDown$ = attributeManager.get('holdDown');
    noink$ = attributeManager.get('noink');
    recenters$ = attributeManager.get('recenters');


    // Set up EventManager to listen to key events on the target,
    // so that space and enter activate the ripple even if the target doesn't
    // handle key events. The key handlers deal with `noink` themselves.
    keyEventTarget = (parentNode.nodeType == 11)
        ? (parentNode as ShadowRoot).host // getRootNode().host ?
        : parentNode;

    (parentEventManager = (keyEventTarget is AlgComponent)
        ? (keyEventTarget as AlgComponent).eventManager
        : new EventManager(keyEventTarget)) // div, ...

      ..on('down', uiDownAction)
      ..on('up', uiUpAction)
      ..onKey('enter:keydown', (_) {
        uiDownAction(null);
        new Future<void>(() => uiUpAction(null));
      })
      ..onKey('space:keydown', (_) {
        uiDownAction(null);
      })
      ..onKey('space:keyup', (_) {
        uiUpAction(null);
      })
      ..subscribe();

    messageManager
      ..from('ripple-simulate', (_) => simulateRipple())
      ..from('ripple-start', (Event event) => uiDownAction(event))
      ..from('ripple-end', (Event event) => uiUpAction(event))
      ..export('noink', noink$)
      ..export('holdDown', holdDown$);
  }

  /// Attributes managed by the component.
  @override
  List<String> observedAttributes() => super.observedAttributes()
      + <String>['center', 'noink', 'recenters'];

  ///
  /// No standard attributes
  ///
  @override
  void addStandardAttributes() { }

  ///
  /// Component removed from the tree
  ///
  @override
  void detached() {
    super.detached();

    // If we need reconnect the element, the parentEventManager must be different from component native
    keyEventTarget = null;
  }

  ///
  ObservableEvent<bool> animating$;

  /// If true, ripples will center inside its container. Used by Ripple().
  ObservableEvent<bool> center$;
  ///
  bool get center => center$.value;

  ///
  ObservableEvent<bool> holdDown$;

  /// The initial opacity set on the wave. Used by Ripple()
  double initialOpacity = 0.25;

  /// parent Element
  HtmlElement keyEventTarget;

  /// If true, the ripple will not generate a ripple effect via pointer interaction.
  /// Calling ripple's imperative api like `simulatedRipple` will still generate the ripple effect.
  ObservableEvent<bool> noink$;

  /// How fast (opacity per second) the wave fades out.
  double opacityDecayVelocity = 0.8;

  /// eventManager in parent component
  EventManager parentEventManager;

  /// If true, ripples will exhibit a gravitational pull towards the center of
  /// their container as they fade away.
  ObservableEvent<bool> recenters$;
  ///
  bool get recenters => recenters$.value;

  /// A list of the visual ripples.
  List<Ripple> ripples = <Ripple>[];

  ///
  bool get shouldKeepAnimating {
    ripples.forEach((Ripple ripple) {
      if (!ripple.isAnimationComplete) return true;
    });
    return false;
  }

  ///
  HtmlElement get target => keyEventTarget;

  ///
  Ripple addRipple() {
    final Ripple ripple = new Ripple(this);

    ids['waves'].append(ripple.waveContainer);
    ids['background'].style.backgroundColor = ripple.color;
    ripples.add(ripple);

    return ripple;
  }

  ///
  /// en polymer: animate(), but conflicts with Element.animate().
  ///
  void animateRipple(num n) {
    if (!animating$.value) return;

    ripples.removeWhere((Ripple ripple) {
      ripple.draw();
      ids['background'].style.opacity = ripple.outerOpacity.toString();

      if (ripple.isOpacityFullyDecayed && !ripple.isRestingAtMaxRadius) {
        ripple.remove();
        return true;
      }
      return false;
    });

    if (ripples.isEmpty) animating$.update(false);


    if (!shouldKeepAnimating && ripples.isEmpty) {
      onAnimationComplete();
    } else {
      window.animationFrame.then(animateRipple);
    }
  }

  ///
  /// Provokes a ripple down effect via a UI event,
  /// *not* respecting the `noink` property.
  ///
  void downAction(Event event) {
    if (holdDown$.value && ripples.isNotEmpty) return;

    addRipple()
      ..downAction(event);

    if (!animating$.value) {
      animating$.update(true);
      animateRipple(null);
    }
  }

  ///
  void onAnimationComplete() {
    animating$.update(false);
    ids['background'].style.backgroundColor = null;

    // 'transitionend' is a dom (transition) event.
    // Use eventManager.on to receive it, else we receive it twice
    // Use detail if necessary: new CustomEvent('transitionend', detail: this)
    parentEventManager.fire('transitionend', new CustomEvent('transitionend'));
  }

//  ///
//  void removeRipple(Ripple ripple) {
//    ripples.remove(ripple);
//
//    if (ripples.isEmpty) {
//      animating.update(false);
//    }
//  }

  ///
  void simulateRipple() {
    downAction(null);
    new Future<void>(() => upAction(null));
  }

  ///
  /// Provokes a ripple down effect via an UI event,
  /// respecting the `noink` property.
  ///
  void uiDownAction(Event event) {
    if (!noink$.value) downAction(event);
  }

  ///
  /// Provokes a ripple up effect via a UI event,
  /// respecting the `noink` property.
  void uiUpAction(Event event) {
    if (!noink$.value) upAction(event);
  }

  ///
  /// Provokes a ripple up effect via a UI event,
  /// *not* respecting the `noink` property.
  ///
  void upAction(Event event) {
    if (holdDown$.value) return;

    ripples.forEach((Ripple ripple) {
      ripple.upAction(event);
    });

    animating$.update(true);
    animateRipple(null);
  }
}
