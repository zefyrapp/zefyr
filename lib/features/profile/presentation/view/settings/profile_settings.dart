import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Настройка',
        style: TextStyle(
          color: Color(0xffE0E0E0),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          height: 28 / 20,
        ),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size(double.infinity, 1),
        child: Divider(color: Color(0xff2A2A2A)),
      ),
    ),
    body: const Column(),
  );
}
