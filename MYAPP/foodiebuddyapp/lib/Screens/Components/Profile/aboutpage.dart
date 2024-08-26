import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/theme.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EFC6),
      appBar: AppBar(
        title: Text(
          'About Foodie Buddy',
          style: AppTheme.textTheme.displayLarge?.copyWith(color: Colors.black), // Use custom headline1 style from AppTheme
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Developed by',
                style: AppTheme.textTheme.bodyLarge, // Use custom bodyLarge style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                'Abin Varghese, Niketh A Unnithan, and Mathew K Raino',
                style: AppTheme.textTheme.bodyLarge, // Use custom bodyLarge style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'Our Story',
                style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold), // Use custom displayMedium style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                "We're a team of food enthusiasts and tech enthusiasts who came together to create an app that makes cooking easier, more enjoyable, and more personalized. With Foodie Buddy, we aim to inspire home cooks and food lovers to explore new recipes, cooking styles, and flavors.",
                style: AppTheme.textTheme.bodyMedium, // Use custom bodyMedium style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'Our Mission',
                style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold), // Use custom displayMedium style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                "Our mission is to provide a comprehensive cooking companion that helps you discover, create, and share delicious meals with ease. We're passionate about making cooking accessible to everyone, regardless of skill level or dietary preference.",
                style: AppTheme.textTheme.bodyMedium, // Use custom bodyMedium style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'What Drives Us',
                style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold), // Use custom displayMedium style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                "We believe that cooking is not just about following a recipe, but about exploring new flavors, experimenting with ingredients, and sharing meals with loved ones. Our app is designed to fuel your culinary creativity, simplify meal planning, and make cooking a joyful experience.",
                style: AppTheme.textTheme.bodyMedium, // Use custom bodyMedium style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'Get in Touch',
                style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold), // Use custom displayMedium style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                "If you have any feedback, suggestions, or just want to say hello, please don't hesitate to reach out to us . We're always looking for ways to improve and make Foodie Buddy an even better cooking companion for you.",
                style: AppTheme.textTheme.bodyMedium, // Use custom bodyMedium style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'Thank You',
                style: AppTheme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold), // Use custom displayMedium style from AppTheme
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for choosing Foodie Buddy as your go-to cooking app. We\'re excited to be a part of your culinary journey and look forward to seeing the delicious meals you create!',
                style: AppTheme.textTheme.bodyMedium, // Use custom bodyMedium style from AppTheme
              ),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: AppTheme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontStyle: FontStyle.italic), // Use custom bodyMedium style from AppTheme
              ),
            ],
          ),
        ),
      ),
    );
  }
}
