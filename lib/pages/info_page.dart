import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở link: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[800]!, Colors.blueGrey[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.checkroom,
                      size: 50,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SHIRT SHOP',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Thời trang áo hiện đại - Phong cách cho mọi người',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Giới thiệu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Về SHIRT SHOP',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'SHIRT SHOP là cửa hàng thời trang chuyên cung cấp các loại áo như áo thun, hoodie, sơ mi và nhiều phong cách khác. Chúng tôi tập trung vào thiết kế hiện đại, chất liệu thoải mái và giá cả hợp lý.',
                      style: TextStyle(fontSize: 14, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),

            // Lịch sử
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lịch sử',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      '• Thành lập năm 2021\n\n'
                      '• Bắt đầu từ một cửa hàng nhỏ chuyên áo thun tại TP.HCM\n\n'
                      '• Hiện nay đã phát triển thành thương hiệu thời trang trẻ trung được nhiều khách hàng yêu thích',
                      style: TextStyle(fontSize: 14, height: 1.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sứ mệnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sứ mệnh & Tầm nhìn',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      '▸ Sứ mệnh: Mang đến các sản phẩm áo thời trang chất lượng, phù hợp với phong cách và nhu cầu của giới trẻ.\n\n'
                      '▸ Tầm nhìn: Trở thành thương hiệu thời trang áo hàng đầu tại Việt Nam.',
                      style: TextStyle(fontSize: 14, height: 1.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Giá trị
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giá trị cốt lõi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildValueCard('Chất lượng', Icons.star, Colors.black87),
                      const SizedBox(width: 10),
                      _buildValueCard('Uy tín', Icons.verified, Colors.black87),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildValueCard('Thời trang', Icons.style, Colors.black87),
                      const SizedBox(width: 10),
                      _buildValueCard('Tư vấn', Icons.chat, Colors.black87),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Liên hệ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liên hệ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildContactInfo(Icons.location_on, 'Địa chỉ', 'TP.HCM'),
                  const SizedBox(height: 10),
                  _buildContactInfo(Icons.phone, 'Điện thoại', '0123 456 789'),
                  const SizedBox(height: 10),
                  _buildContactInfo(Icons.email, 'Email', 'shirtshop@gmail.com'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Social
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theo dõi chúng tôi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialButton(Icons.facebook, 'Facebook', 'https://www.facebook.com/'),
                      _buildSocialButton(Icons.camera_alt, 'Instagram', 'https://www.instagram.com/'),
                      _buildSocialButton(Icons.play_circle_fill, 'TikTok', 'https://www.tiktok.com/'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.blueGrey[800],
              child: const Column(
                children: [
                  Text(
                    '© 2026 SHIRT SHOP',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cảm ơn bạn đã ủng hộ SHIRT SHOP',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchURL(url),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.black87,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}