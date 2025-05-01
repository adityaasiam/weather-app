import 'package:flutter/material.dart';

class NavigationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_ios, color: Colors.white70),
          Row(
            children: List.generate(
              3,
                  (index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.circle, size: 6, color: Colors.white70),
              ),
            ),
          ),
          Icon(Icons.menu, color: Colors.white70),
        ],
      ),
    );
  }
}