import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:developer';

final List<OnBoard> demoData = [
  OnBoard(
    image: "assets/images/backup-screenshot.png",
    title: "6 Different Recipe Catagories to Choose From",
    description: "Add your own recipes to each using the + button",
  ),
  OnBoard(
    image: "assets/images/finished-recipe-top.jpg",
    secondImage: "assets/images/finished-recipe-buttons.jpg",
    title: "Change Your Recipes as You Refine Them",
    description: "Easily update and delete individual recipes",
  ),
  OnBoard(
    image: "assets/images/backup-screenshot.png",
    title: "Backup Your Data to Save it From Crashes",
    description:
        "Use the backup and restore options in settings to prevent the loss of your recipes",
  ),
];

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  //final homeCon = Get.put<HomeController>(HomeController());

  late PageController _pageController;
  int _pageIndex = 0;
  //Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _pageController = PageController(initialPage: 0);
    // Automatic scroll behaviour
    /*_timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageIndex < 3) {
        _pageIndex++;
      } else {
        _pageIndex = 0;
      }

      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    }
    );*/
  }

  @override
  void dispose() {
    // Dispose everything
    _pageController.dispose();
    //_timer!.cancel();
    super.dispose();
  }

  void onForwardButtonPressed() {
    setState(() {
      if (_pageIndex < 2) {
        _pageIndex++;
      } else {
        _pageIndex = 0;
      }

      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  void onBackButtonPressed() {
    setState(() {
      if (_pageIndex > 0) {
        _pageIndex--;
      } else {
        _pageIndex = 2;
      }

      _pageController.animateToPage(
        _pageIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Column(
              children: [
                // Carousel area
                Expanded(
                  child: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        _pageIndex = index;
                      });
                    },
                    itemCount: demoData.length,
                    controller: _pageController,
                    itemBuilder: (context, index) => OnBoard(
                      title: demoData[index].title,
                      description: demoData[index].description,
                      image: demoData[index].image,
                    ),
                  ),
                ),
                // Indicator area
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          onBackButtonPressed();
                        },
                      ),
                      ...List.generate(
                        demoData.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: DotIndicator(
                            isActive: index == _pageIndex,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          onForwardButtonPressed();
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // Button area
                InkWell(
                  onTap: () {
                    log("Button clicked!");
                  },
                  child: SizedBox(
                    height: 70, //Get.height * 0.075,
                    width: 200, //Get.width,
                    child: ElevatedButton(
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              fontFamily: "HappyMonkey",
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'home');
                        }),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class OnBoard extends StatelessWidget {
  final String image, title, description;
  final String? secondImage;
  const OnBoard({
    required this.image,
    this.secondImage,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          child: secondImage != null
              ? Column(
                  children: [Image.asset(image), Image.asset(secondImage!)],
                )
              : Image.asset(image),
          decoration:
              BoxDecoration(border: Border.all(width: 5, color: Colors.white)),
        ),
        const Spacer(),
      ],
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    this.isActive = false,
    super.key,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.purple : Colors.white,
        border: isActive ? null : Border.all(color: Colors.purple),
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }
}
