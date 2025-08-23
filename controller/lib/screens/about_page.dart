import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lg_airport_simulator_apk/screens/theme_provider.dart';
import 'package:lg_airport_simulator_apk/service/socket_service.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: context.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: context.appbar,
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
   
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[50],
                border: Border(
                  bottom: BorderSide(
                    color: context.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        width: 3,
                      ),
                      color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Dev Gadani',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contributor to LG Airport Simulator & Developer',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // About Me Section
            _buildSection(
              context: context,
              title: 'About Me',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context: context,
                    label: 'Passion',
                    value: 'Contribution to Open source projects and Creating innovative applications with Flutter',
                  ),
                  // _buildInfoRow(
                  //   context: context,
                  //   label: 'Expertise',
                  //   value: 'Flutter Development, UI/UX Design, System Integration',
                  // ),
                  // _buildInfoRow(
                  //   context: context,
                  //   label: 'Focus',
                  //   value: 'Building seamless user experiences and robust applications',
                  // ),
                  SizedBox(height: 16),
                  Text(
                    'Dedicated to crafting high-quality mobile applications that solve real-world problems. '
                    'The LG Airport Simulator represents my commitment to innovation and technical excellence, '
                    'combining advanced Flutter development with sophisticated system integration.',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Project Highlights
            // _buildSection(
            //   context: context,
            //   title: 'Project Highlights',
            //   content: Column(
            //     children: [
            //       _buildProjectHighlight(
            //         context: context,
            //         title: 'LG Airport Simulator',
            //         description: 'Advanced Flutter application with real-time connectivity and immersive simulation features',
            //       ),
            //       _buildProjectHighlight(
            //         context: context,
            //         title: 'Theme System Implementation',
            //         description: 'Comprehensive dark/light theme system with persistent user preferences',
            //       ),
            //       _buildProjectHighlight(
            //         context: context,
            //         title: 'Socket Integration',
            //         description: 'Real-time communication system for Liquid Galaxy integration',
            //       ),
            //     ],
            //   ),
            // ),

            // Mentor Appreciation Section
            Container(
              margin: EdgeInsets.all(24),
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Icon(
                  //   Icons.favorite,
                  //   size: 48,
                  //   color: context.connectionErrorColor, // Using theme color for accent
                  // ),
                  SizedBox(height: 24),
                  Text(
                    'Special Thanks',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'To My Mentor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Thanks to my main mentor Vedant  and secondary mentors  Prayag biswas, Rosemarie Garcia And thanks to the team of the Liquid Galaxy LAB Lleida, Headquarters of the Liquid Galaxy project: Alba, Paula, Josep, Jordi, Oriol, Sharon, Alejandro, Marc, and admin Andreu, for their continuous support on my project.'
                    'Info in www.liquidgalaxy.eu',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'With Gratitude & Respect',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.isDarkMode ? Colors.white : Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            SizedBox(height: 40),

             Container(
            child:Image.asset('assets/logo.png', fit: BoxFit.contain),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: context.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectHighlight({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: context.isDarkMode ? Colors.grey[300] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}