import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class HealthInfoSourcesPage extends StatelessWidget {
  static const String id = 'health_info_sources_page';

  const HealthInfoSourcesPage({Key? key}) : super(key: key);

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Information Sources & Disclaimer'),
        backgroundColor: const Color(0xFF0A0E21),
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: kactiveCardColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'BMI (Body Mass Index) Calculation Formula',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'BMI = weight (kg) ÷ height (m)²\nThis app uses the standard formula for calculation.',
                    style: TextStyle(fontSize: 14.0, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: kactiveCardColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Adult BMI Categories (Refer to WHO & CDC)',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '• Underweight: < 18.5\n• Normal: 18.5 – 24.9\n• Overweight: 25.0 – 29.9\n• Obesity: ≥ 30.0',
                    style: TextStyle(fontSize: 14.0, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: kactiveCardColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Official Sources & Links',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8.0),
                  _LinkItem(
                    title: 'WHO BMI Classification',
                    url:
                        'https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight',
                  ),
                  _LinkItem(
                    title:
                        'WHO Tech Report Series 894 (2000): Obesity: preventing and managing the global epidemic',
                    url: 'https://apps.who.int/iris/handle/10665/42330',
                  ),
                  _LinkItem(
                    title: 'CDC: About Adult BMI',
                    url:
                        'https://www.cdc.gov/healthyweight/assessing/bmi/adult_bmi/index.html',
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'The above links are authoritative public sources for further understanding of BMI calculation and applicability.',
                    style: TextStyle(fontSize: 12.0, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: kactiveCardColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Disclaimer: All health information provided by this app is for general reference only and cannot replace professional medical advice, diagnosis, or treatment. BMI may not apply or should be interpreted with caution for children, pregnant women, professional athletes, or individuals with special health conditions. If you have concerns about your health, please consult a doctor or other medical professional.',
                style: TextStyle(fontSize: 13.0, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  final String title;
  final String url;
  const _LinkItem({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.link, color: Color(0xFFEB1555), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color(0xFFEB1555),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
