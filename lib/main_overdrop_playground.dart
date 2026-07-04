import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const OverdropLoaderApp());
}

class OverdropLoaderApp extends StatelessWidget {
  const OverdropLoaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overdrop Weather Loader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        primaryColor: const Color(0xFF60A5FA),
        fontFamily: 'sans-serif',
      ),
      home: const OverdropPlaygroundScreen(),
    );
  }
}

// Weather styles mirroring the Overdrop application themes
enum OverdropWeatherStyle { sunny, rainy, snowy, stormy }

class OverdropPlaygroundScreen extends StatefulWidget {
  const OverdropPlaygroundScreen({Key? key}) : super(key: key);

  @override
  State<OverdropPlaygroundScreen> createState() => _OverdropPlaygroundScreenState();
}

class _OverdropPlaygroundScreenState extends State<OverdropPlaygroundScreen> {
  OverdropWeatherStyle _weatherStyle = OverdropWeatherStyle.sunny;
  double _animationSpeed = 1.0;
  double _scale = 1.0;
  int _particleCount = 30;
  Color _dropletColor = const Color(0xFF60A5FA);
  Color _sunColor = const Color(0xFFFBBF24);
  Color _cloudColor = const Color(0xFFE2E8F0);

  bool _isPlaying = true;
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: isMobile
                      ? Column(children: _buildLayoutWidgets())
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: _buildPreviewContainer()),
                            const SizedBox(width: 20),
                            Expanded(flex: 5, child: _buildControlTabs()),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLayoutWidgets() {
    return [
      _buildPreviewContainer(),
      const SizedBox(height: 20),
      _buildControlTabs(),
    ];
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0E131F),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.2)),
                ),
                child: const Icon(Icons.thunderstorm, color: Color(0xFF60A5FA), size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Overdrop Flutter Lab',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    'Liquid Droplet Weather Loader SDK',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on, color: const Color(0xFF10B981), size: 14),
                SizedBox(width: 4),
                Text('60 FPS CustomPaint', style: TextStyle(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPreviewContainer() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF070A13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _buildGridBackground()),
          Center(
            child: _isPlaying
                ? OverdropAnimatedLoader(
                    weatherStyle: _weatherStyle,
                    speed: _animationSpeed,
                    scale: _scale,
                    particleCount: _particleCount,
                    dropletColor: _dropletColor,
                    sunColor: _sunColor,
                    cloudColor: _cloudColor,
                  )
                : const Text("Animation Paused", style: TextStyle(color: Colors.grey)),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111827).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF60A5FA),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Style: ${_weatherStyle.name.toUpperCase()}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                IconButton(
                  tooltip: _isPlaying ? 'Pause Animation' : 'Play Animation',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying = false;
                    });
                    Future.delayed(const Duration(milliseconds: 50), () {
                      setState(() {
                        _isPlaying = true;
                      });
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Re-trigger Drop', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(),
    );
  }

  Widget _buildControlTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E131F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 0 ? const Color(0xFF60A5FA) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, color: _activeTab == 0 ? const Color(0xFF60A5FA) : Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Configure Style',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 0 ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _activeTab == 1 ? const Color(0xFF60A5FA) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.code, color: _activeTab == 1 ? const Color(0xFF60A5FA) : Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Flutter Code',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 1 ? Colors.white : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _activeTab == 0 ? _buildCustomizer() : _buildCodeViewer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MORPH WEATHER CONDITION TARGET', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: OverdropWeatherStyle.values.map((style) {
            final isSelected = _weatherStyle == style;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: isSelected ? const Color(0xFF60A5FA) : const Color(0xFF1A2234),
                    foregroundColor: isSelected ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      _weatherStyle = style;
                      if (style == OverdropWeatherStyle.sunny) {
                        _sunColor = const Color(0xFFFBBF24);
                        _cloudColor = const Color(0xFFE2E8F0);
                      } else if (style == OverdropWeatherStyle.rainy) {
                        _sunColor = const Color(0xFFFBBF24);
                        _cloudColor = const Color(0xFF94A3B8);
                      } else if (style == OverdropWeatherStyle.snowy) {
                        _sunColor = const Color(0xFFD1D5DB);
                        _cloudColor = const Color(0xFFF1F5F9);
                      } else if (style == OverdropWeatherStyle.stormy) {
                        _sunColor = const Color(0xFFE2E8F0);
                        _cloudColor = const Color(0xFF475569);
                      }
                    });
                  },
                  child: Text(style.name[0].toUpperCase() + style.name.substring(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildSlider(
          title: 'Animation Cycle Speed',
          value: _animationSpeed,
          min: 0.5,
          max: 2.5,
          onChanged: (val) => setState(() => _animationSpeed = val),
          displayValue: '${_animationSpeed.toStringAsFixed(1)}x',
        ),
        const SizedBox(height: 16),
        _buildSlider(
          title: 'Weather Elements Scale',
          value: _scale,
          min: 0.5,
          max: 1.5,
          onChanged: (val) => setState(() => _scale = val),
          displayValue: '${_scale.toStringAsFixed(2)}x',
        ),
        const SizedBox(height: 16),
        _buildSlider(
          title: 'Splash Rain/Snow Particle Density',
          value: _particleCount.toDouble(),
          min: 5,
          max: 80,
          onChanged: (val) => setState(() => _particleCount = val.toInt()),
          displayValue: '$_particleCount',
        ),
        const SizedBox(height: 24),
        const Text('PALETTE TUNING', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildColorBubble(
              title: 'Teardrop Drop',
              color: _dropletColor,
              options: [const Color(0xFF3B82F6), const Color(0xFF60A5FA), const Color(0xFF00D2FF), const Color(0xFFFFFFFF)],
              onSelect: (c) => setState(() => _dropletColor = c),
            ),
            const SizedBox(width: 16),
            _buildColorBubble(
              title: 'Warm Sun Core',
              color: _sunColor,
              options: [const Color(0xFFF59E0B), const Color(0xFFFBBF24), const Color(0xFFEAB308), const Color(0xFF94A3B8)],
              onSelect: (c) => setState(() => _sunColor = c),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildColorBubble({
    required String title,
    required Color color,
    required List<Color> options,
    required Function(Color) onSelect,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF161C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: options.map((opt) {
                final isSelected = opt.value == color.value;
                return GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: opt,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected) BoxShadow(color: opt.withOpacity(0.5), blurRadius: 6, spreadRadius: 1)
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
            Text(displayValue, style: const TextStyle(fontSize: 12, color: Color(0xFF60A5FA), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: const Color(0xFF60A5FA),
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF60A5FA).withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeViewer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('STANDALONE FLUTTER LOADER CLASS', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF60A5FA)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _generateFlutterCodeSnippet()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Overdrop Animated Loader Code Copied to Clipboard!'),
                    backgroundColor: Color(0xFF161C2C),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 14),
              label: const Text('Copy File', style: TextStyle(fontSize: 12)),
            )
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF070A13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: SingleChildScrollView(
            child: Text(
              _generateFlutterCodeSnippet(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFF93C5FD),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _generateFlutterCodeSnippet() {
    return '''
// Copy-paste this widget straight into your Flutter project!
import 'dart:math' as math;
import 'package:flutter/material.dart';

class OverdropLoader extends StatefulWidget {
  final double scale;
  final double speed;
  final Color dropletColor;
  final Color sunColor;
  final Color cloudColor;

  const OverdropLoader({
    Key? key,
    this.scale = 1.0,
    this.speed = 1.0,
    this.dropletColor = const Color(0xFF60A5FA),
    this.sunColor = const Color(0xFFFBBF24),
    this.cloudColor = const Color(0xFFE2E8F0),
  }) : super(key: key);

  @override
  _OverdropLoaderState createState() => _OverdropLoaderState();
}

class _OverdropLoaderState extends State<OverdropLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2200 / widget.speed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(200 * widget.scale, 200 * widget.scale),
          painter: OverdropPainter(
            progress: _controller.value,
            dropletColor: widget.dropletColor,
            sunColor: widget.sunColor,
            cloudColor: widget.cloudColor,
          ),
        );
      },
    );
  }
}
''';
  }
}

class OverdropAnimatedLoader extends StatefulWidget {
  final OverdropWeatherStyle weatherStyle;
  final double speed;
  final double scale;
  final int particleCount;
  final Color dropletColor;
  final Color sunColor;
  final Color cloudColor;

  const OverdropAnimatedLoader({
    Key? key,
    required this.weatherStyle,
    required this.speed,
    required this.scale,
    required this.particleCount,
    required this.dropletColor,
    required this.sunColor,
    required this.cloudColor,
  }) : super(key: key);

  @override
  State<OverdropAnimatedLoader> createState() => _OverdropAnimatedLoaderState();
}

class _OverdropAnimatedLoaderState extends State<OverdropAnimatedLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<MicroParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2200 / widget.speed).round()),
    );
    _controller.repeat();
    _initializeParticles();
  }

  @override
  void didUpdateWidget(covariant OverdropAnimatedLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = Duration(milliseconds: (2200 / widget.speed).round());
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    }
    if (oldWidget.particleCount != widget.particleCount) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    _particles.clear();
    final random = math.Random();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        MicroParticle(
          angle: random.nextDouble() * math.pi * 2,
          speed: random.nextDouble() * 3.5 + 1.5,
          radius: random.nextDouble() * 2.5 + 1.0,
          opacity: random.nextDouble() * 0.7 + 0.3,
          maxDistance: random.nextDouble() * 45 + 25,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(220 * widget.scale, 220 * widget.scale),
          painter: OverdropPainter(
            progress: _controller.value,
            weatherStyle: widget.weatherStyle,
            dropletColor: widget.dropletColor,
            sunColor: widget.sunColor,
            cloudColor: widget.cloudColor,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class OverdropPainter extends CustomPainter {
  final double progress;
  final OverdropWeatherStyle weatherStyle;
  final Color dropletColor;
  final Color sunColor;
  final Color cloudColor;
  final List<MicroParticle> particles;

  OverdropPainter({
    required this.progress,
    this.weatherStyle = OverdropWeatherStyle.sunny,
    required this.dropletColor,
    required this.sunColor,
    required this.cloudColor,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final double dropProgress = _mapRange(progress, 0.0, 0.35);
    final double splashProgress = _mapRange(progress, 0.35, 0.45);
    final double morphProgress = _mapRange(progress, 0.45, 0.75);
    final double idleProgress = _mapRange(progress, 0.75, 1.00);

    final Paint mainPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    if (progress <= 0.35) {
      final double easedDrop = _easeInBack(dropProgress);
      final double startY = -60;
      final double endY = 10;
      final double currentY = startY + (endY - startY) * easedDrop;

      final double stretch = 1.0 + (dropProgress * 0.3);
      final Path dropPath = _createTeardropPath(cx, cy + currentY, 12, 18 * stretch);

      mainPaint.color = dropletColor;
      canvas.drawPath(dropPath, mainPaint);
    } else if (progress > 0.35 && progress <= 0.45) {
      final double squashFactor = math.sin(splashProgress * math.pi);
      final double width = 12 + (squashFactor * 25);
      final double height = 12 - (squashFactor * 9);

      final Rect puddleRect = Rect.fromCenter(
        center: Offset(cx, cy + 10),
        width: width * 1.5,
        height: height,
      );

      mainPaint.color = dropletColor;
      canvas.drawOval(puddleRect, mainPaint);

      _drawSplashExplosion(canvas, cx, cy + 10, splashProgress);
    } else if (progress > 0.45 && progress <= 0.75) {
      final double morphScale = _easeOutElastic(morphProgress);
      final double radius = 32 * morphScale;
      final double yPos = 10 - (20 * morphProgress);

      final Color blendedColor = Color.lerp(dropletColor, sunColor, morphProgress)!;
      mainPaint.color = blendedColor;

      canvas.drawCircle(Offset(cx, cy + yPos), radius, mainPaint);
    } else if (progress > 0.75 && progress <= 1.0) {
      final double floatOffset = math.sin(idleProgress * math.pi * 2) * 4;
      final double sunY = -10;

      _drawSunnyElement(canvas, cx, cy + sunY, mainPaint, idleProgress);
      _drawCloudElement(canvas, cx, cy + floatOffset, mainPaint, idleProgress);
    }
  }

  void _drawSunnyElement(Canvas canvas, double cx, double cy, Paint paint, double idleVal) {
    paint.color = sunColor;
    final double sunRadius = 32;

    final Paint glowPaint = Paint()
      ..color = sunColor.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(cx, cy), sunRadius + 6, glowPaint);

    canvas.drawCircle(Offset(cx, cy), sunRadius, paint);

    if (weatherStyle == OverdropWeatherStyle.sunny) {
      final int numRays = 8;
      final double rayInner = sunRadius + 8;
      final double rayOuter = rayInner + 8 + (math.sin(idleVal * math.pi * 4) * 2.5);
      final double rotationOffset = idleVal * math.pi * 0.4;

      final Paint rayPaint = Paint()
        ..color = sunColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < numRays; i++) {
        final double angle = (i * math.pi * 2 / numRays) + rotationOffset;
        final double startX = cx + math.cos(angle) * rayInner;
        final double startY = cy + math.sin(angle) * rayInner;
        final double endX = cx + math.cos(angle) * rayOuter;
        final double endY = cy + math.sin(angle) * rayOuter;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
      }
    }
  }

  void _drawCloudElement(Canvas canvas, double cx, double cy, Paint paint, double idleVal) {
    paint.color = cloudColor;

    final double scale = 0.95 + (math.sin(idleVal * math.pi) * 0.05);
    canvas.save();
    canvas.translate(cx + 12, cy + 18);
    canvas.scale(scale);

    final Path cloudPath = Path();
    cloudPath.moveTo(-35, 10);
    cloudPath.lineTo(25, 10);
    cloudPath.arcToPoint(
      const Offset(25, -15),
      radius: const Radius.circular(15),
      clockwise: false,
    );
    cloudPath.arcToPoint(
      const Offset(-10, -28),
      radius: const Radius.circular(25),
      clockwise: false,
    );
    cloudPath.arcToPoint(
      const Offset(-35, -5),
      radius: const Radius.circular(18),
      clockwise: false,
    );
    cloudPath.close();

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(cloudPath, shadowPaint);

    canvas.drawPath(cloudPath, paint);
    canvas.restore();

    _drawWeatherParticles(canvas, cx, cy + 30, idleVal);
  }

  void _drawWeatherParticles(Canvas canvas, double cx, double cy, double idleVal) {
    final Paint partPaint = Paint()..style = PaintingStyle.fill;

    if (weatherStyle == OverdropWeatherStyle.rainy || weatherStyle == OverdropWeatherStyle.stormy) {
      partPaint.color = const Color(0xFF60A5FA).withOpacity(0.8);
      partPaint.strokeWidth = 2.0;
      partPaint.strokeCap = StrokeCap.round;

      for (int i = 0; i < 4; i++) {
        final double xOffset = -30.0 + (i * 24.0) + (idleVal * 5.0);
        final double yOffset = ((idleVal * 45) + (i * 12)) % 35;
        canvas.drawLine(
          Offset(cx + xOffset, cy + yOffset),
          Offset(cx + xOffset - 3, cy + yOffset + 12),
          partPaint,
        );
      }
    } else if (weatherStyle == OverdropWeatherStyle.snowy) {
      partPaint.color = Colors.white.withOpacity(0.9);
      for (int i = 0; i < 5; i++) {
        final double xOffset = -35.0 + (i * 18.0) + math.sin(idleVal * math.pi * 2 + i) * 3;
        final double yOffset = ((idleVal * 40) + (i * 8)) % 32;
        canvas.drawCircle(Offset(cx + xOffset, cy + yOffset), 2.5, partPaint);
      }
    }
  }

  void _drawSplashExplosion(Canvas canvas, double cx, double cy, double progress) {
    final Paint splashPaint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      final double distance = particle.maxDistance * progress;
      final double px = cx + math.cos(particle.angle) * distance;
      final double py = cy + math.sin(particle.angle) * distance;

      final double gravityY = py + (15.0 * progress * progress);

      splashPaint.color = dropletColor.withOpacity(particle.opacity * (1.0 - progress));
      canvas.drawCircle(Offset(px, gravityY), particle.radius * (1.0 - progress * 0.4), splashPaint);
    }
  }

  Path _createTeardropPath(double x, double y, double width, double height) {
    final Path path = Path();
    path.moveTo(x, y - height);
    path.cubicTo(
      x + width, y - height * 0.2,
      x + width, y + height * 0.5,
      x, y + height * 0.5,
    );
    path.cubicTo(
      x - width, y + height * 0.5,
      x - width, y - height * 0.2,
      x, y - height,
    );
    path.close();
    return path;
  }

  double _mapRange(double value, double start, double end) {
    if (value < start) return 0.0;
    if (value > end) return 1.0;
    return (value - start) / (end - start);
  }

  double _easeInBack(double t) => t * t * (2.70158 * t - 1.70158);
  double _easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  @override
  bool shouldRepaint(covariant OverdropPainter oldDelegate) => oldDelegate.progress != progress;
}

class MicroParticle {
  final double angle;
  final double speed;
  final double radius;
  final double opacity;
  final double maxDistance;

  MicroParticle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.maxDistance,
  });
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const double step = 24.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
