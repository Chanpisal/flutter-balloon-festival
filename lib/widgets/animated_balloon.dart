import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class BalloonConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final double startXFraction;
  final int floatDuration;
  final int growDuration;
  final int pulseDuration;
  final double rotationAmount;
  final double sizeFraction;

  const BalloonConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.startXFraction,
    required this.floatDuration,
    required this.growDuration,
    required this.pulseDuration,
    required this.rotationAmount,
    required this.sizeFraction,
  });
}

class MultiBalloonScene extends StatelessWidget {
  static const List<BalloonConfig> _configs = [
    BalloonConfig(
      primaryColor: Color(0xFFE53935),
      secondaryColor: Color(0xFFFF8A80),
      startXFraction: 0.18,
      floatDuration: 8,
      growDuration: 4,
      pulseDuration: 1200,
      rotationAmount: 0.15,
      sizeFraction: 1.0,
    ),
    BalloonConfig(
      primaryColor: Color(0xFF1E88E5),
      secondaryColor: Color(0xFF82B1FF),
      startXFraction: 0.50,
      floatDuration: 10,
      growDuration: 5,
      pulseDuration: 900,
      rotationAmount: -0.12,
      sizeFraction: 0.85,
    ),
    BalloonConfig(
      primaryColor: Color(0xFF43A047),
      secondaryColor: Color(0xFFB9F6CA),
      startXFraction: 0.80,
      floatDuration: 7,
      growDuration: 3,
      pulseDuration: 1500,
      rotationAmount: 0.10,
      sizeFraction: 0.75,
    ),
  ];

  const MultiBalloonScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedBackground(),
        ..._configs.map((cfg) => AnimatedBalloonWidget(config: cfg)),
      ],
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _cloudControllers;
  final AudioPlayer _windPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _cloudControllers = List.generate(4, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 18 + i * 5),
      )..repeat();
    });

    _startWind();
  }

  Future<void> _startWind() async {
    await _windPlayer.setVolume(0.25);
    await _windPlayer.setReleaseMode(ReleaseMode.loop);
    await _windPlayer.play(AssetSource('sounds/wind.mp3'));
  }

  @override
  void dispose() {
    for (final controller in _cloudControllers) {
      controller.dispose();
    }
    _windPlayer.dispose();
    super.dispose();
  }

  Widget _animatedCloud(int index, double topFraction) {
    final animation = _cloudControllers[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final screenW = MediaQuery.of(context).size.width;
        final screenH = MediaQuery.of(context).size.height;
        final x = (animation.value * (screenW + 200)) - 100;

        return Positioned(
          top: screenH * topFraction,
          left: x,
          child: Opacity(
            opacity: 0.70,
            child: SizedBox(
              width: 130,
              height: 55,
              child: CustomPaint(
                painter: _CloudPainter(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                  Color(0xFFB3E5FC),
                ],
                stops: [0.0, 0.25, 0.70, 1.0],
              ),
            ),
          ),
          _animatedCloud(0, 0.06),
          _animatedCloud(1, 0.20),
          _animatedCloud(2, 0.38),
          _animatedCloud(3, 0.54),
        ],
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.58), 17, paint);
    canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.38), 23, paint);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.58), 17, paint);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.13,
        size.height * 0.53,
        size.width * 0.72,
        size.height * 0.47,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedBalloonWidget extends StatefulWidget {
  final BalloonConfig config;

  const AnimatedBalloonWidget({
    super.key,
    required this.config,
  });

  @override
  State<AnimatedBalloonWidget> createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controllerFloatUp;
  late final AnimationController _controllerGrowSize;
  late final AnimationController _controllerRotate;
  late final AnimationController _controllerPulse;
  late final AnimationController _controllerBurst;

  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotate;
  late Animation<double> _animationPulse;
  late Animation<double> _animationBurstScale;
  late Animation<double> _animationBurstOpacity;

  bool _bursting = false;
  bool _animationsInitialized = false;

  Offset _dragOffset = Offset.zero;
  double _pinchScale = 1.0;
  double _pinchScaleStart = 1.0;

  double _balloonHeight = 200;
  double _balloonWidth = 120;
  double _bottomStart = 400;

  final AudioPlayer _sfxPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final cfg = widget.config;

    _controllerFloatUp = AnimationController(
      duration: Duration(seconds: cfg.floatDuration),
      vsync: this,
    )..addStatusListener(_onFloatStatus);

    _controllerGrowSize = AnimationController(
      duration: Duration(seconds: cfg.growDuration),
      vsync: this,
    );

    _controllerRotate = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controllerPulse = AnimationController(
      duration: Duration(milliseconds: cfg.pulseDuration),
      vsync: this,
    );

    _controllerBurst = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animationBurstScale = Tween<double>(begin: 1.0, end: 2.4).animate(
      CurvedAnimation(parent: _controllerBurst, curve: Curves.easeOut),
    );

    _animationBurstOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controllerBurst, curve: Curves.easeIn),
    );

    _animationFloatUp = const AlwaysStoppedAnimation(0);
    _animationGrowSize = const AlwaysStoppedAnimation(50);
    _animationRotate = const AlwaysStoppedAnimation(0);
    _animationPulse = const AlwaysStoppedAnimation(1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setupAnimations();
      _startInitialAnimations();
    });
  }

  void _setupAnimations() {
    final size = MediaQuery.of(context).size;
    final cfg = widget.config;

    _balloonHeight = (size.height / 2) * cfg.sizeFraction;
    _balloonWidth = (size.height / 3) * cfg.sizeFraction;
    _bottomStart = size.height - _balloonHeight;

    _animationFloatUp = Tween<double>(
      begin: _bottomStart,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controllerFloatUp,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationGrowSize = Tween<double>(
      begin: 50.0,
      end: _balloonWidth,
    ).animate(
      CurvedAnimation(
        parent: _controllerGrowSize,
        curve: Curves.elasticInOut,
      ),
    );

    _animationRotate = Tween<double>(
      begin: -cfg.rotationAmount,
      end: cfg.rotationAmount,
    ).animate(
      CurvedAnimation(
        parent: _controllerRotate,
        curve: Curves.easeInOut,
      ),
    );

    _animationPulse = Tween<double>(
      begin: 0.96,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.easeInOut,
      ),
    );

    _animationsInitialized = true;
  }

  Future<void> _startInitialAnimations() async {
    if (!mounted) return;

    _controllerRotate.repeat(reverse: true);
    _controllerPulse.repeat(reverse: true);

    await _playInflate();

    if (!mounted) return;
    _controllerFloatUp.forward();
    _controllerGrowSize.forward();

    setState(() {});
  }

  Future<void> _playInflate() async {
    await _sfxPlayer.setVolume(0.55);
    await _sfxPlayer.play(AssetSource('sounds/inflate.mp3'));
  }

  Future<void> _playPop() async {
    await _sfxPlayer.setVolume(0.80);
    await _sfxPlayer.play(AssetSource('sounds/pop.mp3'));
  }

  void _onFloatStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_bursting) {
      _triggerBurst();
    }
  }

  Future<void> _triggerBurst() async {
    if (!mounted) return;

    setState(() {
      _bursting = true;
    });

    await _playPop();
    await _controllerBurst.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    _controllerBurst.reset();
    _controllerFloatUp.reset();
    _controllerGrowSize.reset();

    setState(() {
      _bursting = false;
      _dragOffset = Offset.zero;
      _pinchScale = 1.0;
    });

    await _playInflate();
    if (!mounted) return;

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_animationsInitialized) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotate.dispose();
    _controllerPulse.dispose();
    _controllerBurst.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cfg = widget.config;

    final pulseW = _animationGrowSize.value * _animationPulse.value;
    final pulseH = _balloonHeight * _animationPulse.value;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _controllerFloatUp,
        _controllerGrowSize,
        _controllerRotate,
        _controllerPulse,
        _controllerBurst,
      ]),
      builder: (context, _) {
        if (!_animationsInitialized) {
          return const SizedBox.shrink();
        }

        if (_bursting) {
          return Positioned(
            left: size.width * cfg.startXFraction -
                _balloonWidth / 2 +
                _dragOffset.dx,
            top: _animationFloatUp.value + _dragOffset.dy,
            child: Opacity(
              opacity: _animationBurstOpacity.value,
              child: Transform.scale(
                scale: _animationBurstScale.value,
                child: _buildBalloonBody(_balloonHeight, _balloonWidth, cfg),
              ),
            ),
          );
        }

        final currentPulseW = _animationGrowSize.value * _animationPulse.value;
        final currentPulseH = _balloonHeight * _animationPulse.value;

        return Positioned(
          left: size.width * cfg.startXFraction -
              currentPulseW / 2 +
              _dragOffset.dx,
          top: _animationFloatUp.value + _dragOffset.dy,
          child: GestureDetector(
            onScaleStart: (_) {
              _pinchScaleStart = _pinchScale;
            },
            onScaleUpdate: (details) {
              setState(() {
                _dragOffset += details.focalPointDelta;
                if (details.pointerCount >= 2) {
                  _pinchScale =
                      (_pinchScaleStart * details.scale).clamp(0.5, 2.5);
                }
              });
            },
            onScaleEnd: (_) {
              setState(() {
                _dragOffset = Offset.zero;
              });
            },
            onTap: () async {
              if (_controllerFloatUp.isCompleted) {
                _controllerFloatUp.reverse();
                _controllerGrowSize.reverse();
              } else {
                await _playInflate();
                _controllerFloatUp.forward();
                _controllerGrowSize.forward();
              }
            },
            child: Transform.rotate(
              angle: _animationRotate.value,
              child: Transform.scale(
                scale: _pinchScale,
                child: SizedBox(
                  width: currentPulseW,
                  height: currentPulseH + 32,
                  child: _buildBalloonBody(currentPulseH, currentPulseW, cfg),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalloonBody(double h, double w, BalloonConfig cfg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.38, -0.38),
              radius: 0.82,
              colors: [
                cfg.secondaryColor,
                cfg.primaryColor,
                cfg.primaryColor.withOpacity(0.72),
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: cfg.primaryColor.withOpacity(0.42),
                blurRadius: 20,
                offset: const Offset(6, 12),
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: h * 0.11,
                left: w * 0.17,
                child: Container(
                  width: w * 0.23,
                  height: h * 0.17,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.32),
                    borderRadius: BorderRadius.circular(w * 0.13),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.brown.shade400,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}