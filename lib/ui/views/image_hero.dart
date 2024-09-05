import 'package:flutter/material.dart'; 

class ImageHero extends StatelessWidget {
  const ImageHero({
    super.key,
    required this.image,
    this.onTap,
    required this.width,
    this.height
  });

  final Widget image;
  final VoidCallback? onTap;
  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height, 
      child: Hero(
        tag: "imageHero",
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: image
          ),
        ),
      ),
    );
  }
}