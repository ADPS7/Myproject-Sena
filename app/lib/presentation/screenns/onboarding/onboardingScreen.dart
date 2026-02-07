
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../views/Home_Page.dart';
import 'page_1.dart';
import 'page_2.dart';
import 'page_3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = index == 2;
              });
            },
            children: [
              page_1(),
              page_2(),
              page_3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Skip", style:TextStyle(color: Colors.white, fontSize: 18),),
                SmoothPageIndicator(controller: _controller, count: 3,),
                onLastPage ? GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return HomePage();
                    },)
                    );
                  },  child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 18),)
                ):GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn
                    );
                  }, child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 18),)
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
