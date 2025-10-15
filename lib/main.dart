import 'package:flutter/material.dart';
import 'widgets/standalone_blob_button.dart';
import 'widgets/up_down_button.dart';
import 'package:flutter_svg/flutter_svg.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ukiyo-e 匹配社交App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // 纯白色背景，版画风格
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'serif', fontSize: 18, color: Colors.black),
          headlineMedium: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startMatching() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatchResultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
      
            // Responsive SVG using relative coordinates: keep aspect ratio and
            // size relative to available width so it scales uniformly across devices.
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth * 0.42; // 42% of parent width
                return Center(
                  child: SizedBox(
                    width: width,
                    // let SvgPicture preserve aspect ratio by not forcing height
                    child: SvgPicture.asset(
                      'assets/svgs/cat.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
      
            const SizedBox(height: 20),
            // 动态红色按钮
            ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Replaced the blob button with the new UpDownButton composed
                  // from `up.svg` and `down.svg`.
                  UpDownButton(
                    width: 118, // match asset intrinsic size for crisp rendering
                    height: 83,
                    onTap: _startMatching,
                  ),
                  const SizedBox(height: 20),
          
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 匹配结果页面：模拟3个相似用户
class MatchResultPage extends StatelessWidget {
  const MatchResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('匹配结果')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('找到3位相似用户！', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  MatchUserCard(name: '用户A', interest: '艺术爱好者'),
                  MatchUserCard(name: '用户B', interest: '旅行达人'),
                  MatchUserCard(name: '用户C', interest: '音乐迷'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchUserCard extends StatelessWidget {
  final String name;
  final String interest;

  const MatchUserCard({super.key, required this.name, required this.interest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.black),
        title: Text(name),
        subtitle: Text(interest),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}