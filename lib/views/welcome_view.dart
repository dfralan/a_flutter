import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import 'login_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;
  
  final List<String> slogans = [
    "No drama, no hassle, where connections tassel.",
    "No stress, no hassle, embrace the digital castle.",
    "No tension, no hassle, a community that'll make your worries wrastle.",
    "No conflict, no hassle, in this app, friendships amassle.",
    "No trouble, no hassle, a social space that'll make your worries dismantle.",
    "No bickering, no hassle, where thoughts and ideas bristle.",
    "No negativity, no hassle, where positivity will whistle.",
    "No chaos, no hassle, join us and let your creativity thistle.",
    "No friction, no hassle, a platform where expression won't bristle.",
    "No constraints, no hassle, a realm where freedom will chisel.",
    "No haters, no hassle, together we'll form a unified vessel.",
    "No noise, no hassle, where authentic voices nestle.",
    "No limits, no hassle, a playground for minds to wrestle.",
    "No barriers, no hassle, a realm where ideas trestle.",
    "No suppression, no hassle, a platform where thoughts trestle.",
    "No judgment, no hassle, a space where acceptance will nestle.",
    "No filters, no hassle, where connections bloom and nestle.",
    "No exclusion, no hassle, a community where diversity will nestle.",
    "No fear, no hassle, in this app, we'll help you unbuckle.",
    "No bounds, no hassle, where dreams and aspirations will hustle."
  ];
  
  int currentSloganIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _drawAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOut,
    ));
    
    _startSloganRotation();
    _startDrawingAnimation();
  }

  void _startDrawingAnimation() {
    _drawController.forward();
  }

  void _startSloganRotation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _fadeController.reverse().then((_) {
          setState(() {
            currentSloganIndex = (currentSloganIndex + 1) % slogans.length;
          });
          _fadeController.forward();
        });
      }
    });
    
    // Start the first animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _drawController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Spacer(),

              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      blurRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _drawAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TrajectoryPainter(_drawAnimation.value),
                      size: const Size(60, 60),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Rotating Slogan
              Container(
                height: 60,
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    slogans[currentSloganIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFD1D5DB),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),


              const Spacer(),
              
              const SizedBox(height: 60),
              
              // Get Started Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF87CEEB), Color(0xFF32CD32), Color(0xFFFFFACD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrajectoryPainter extends CustomPainter {
  final double animationValue;

  TrajectoryPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale and center the path
    final path = Path();
    
    // Scale and translate the SVG path to fit in 60x60
    // Original SVG viewBox: 1291x1106, target: 60x60
    final scaleX = size.width / 1291;
    final scaleY = size.height / 1106;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    // Center the path
    final offsetX = (size.width - 1291 * scale) / 2;
    final offsetY = (size.height - 1106 * scale) / 2;
    
    // Draw the original SVG path with proper cubic Bézier curves
    path.moveTo(915.242 * scale + offsetX, 75.1875 * scale + offsetY);
    path.cubicTo(
      349.455 * scale + offsetX, 147.962 * scale + offsetY,
      -70.7076 * scale + offsetX, 554.042 * scale + offsetY,
      123.648 * scale + offsetX, 892.195 * scale + offsetY
    );
    path.cubicTo(
      309.548 * scale + offsetX, 1215.64 * scale + offsetY,
      915.747 * scale + offsetX, 964.086 * scale + offsetY,
      980.41 * scale + offsetX, 204.88 * scale + offsetY
    );
    path.cubicTo(
      961.551 * scale + offsetX, 398.946 * scale + offsetY,
      950.389 * scale + offsetX, 790.564 * scale + offsetY,
      1215.5 * scale + offsetX, 1029.91 * scale + offsetY
    );

    // Define gradient colors
    const colors = [
      Color(0xFF8B5CF6), // Purple
      Color(0xFF87CEEB), // Sky Blue
      Color(0xFF32CD32), // Lime Green
      Color(0xFFFFFACD), // Lemon Yellow
    ];

    // Get the total length of the path
    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;
    
    // Increase number of segments for smoother gradient
    const numSegments = 100;
    final segmentLength = totalLength / numSegments;

    // Calculate how many segments to draw based on animation value
    final segmentsToDraw = (numSegments * animationValue).floor();

    // Draw each segment with interpolated colors
    for (int i = 0; i < segmentsToDraw; i++) {
      final startDistance = i * segmentLength;
      final endDistance = (i + 1) * segmentLength;
      
      // Calculate color interpolation for this segment
      final progress = i / (numSegments - 1.0);
      final colorIndex = progress * (colors.length - 1);
      final colorIndexFloor = colorIndex.floor();
      final colorIndexCeil = colorIndexFloor + 1;
      final localProgress = colorIndex - colorIndexFloor;
      
      Color startColor, endColor;
      if (colorIndexCeil >= colors.length) {
        startColor = colors[colorIndexFloor];
        endColor = colors[colorIndexFloor];
      } else {
        startColor = colors[colorIndexFloor];
        endColor = colors[colorIndexCeil];
      }
      
      // Interpolate between the two colors
      final interpolatedColor = Color.lerp(startColor, endColor, localProgress)!;
      
      // Create a sub-path for this segment
      final segmentPath = Path();
      
      // Get more points along this segment for smoother curves
      final numPoints = 20; // Increased points per segment for smoother curve
      for (int j = 0; j < numPoints; j++) {
        final distance = startDistance + (j / (numPoints - 1.0)) * segmentLength;
        final tangent = pathMetrics.getTangentForOffset(distance);
        
        if (tangent != null) {
          if (j == 0) {
            segmentPath.moveTo(tangent.position.dx, tangent.position.dy);
          } else {
            segmentPath.lineTo(tangent.position.dx, tangent.position.dy);
          }
        }
      }
      
      // Draw this segment
      final paint = Paint()
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..color = interpolatedColor;
      
      canvas.drawPath(segmentPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 