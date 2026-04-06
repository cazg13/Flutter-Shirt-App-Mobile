import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  // Hàm mở link ngoài
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
            // Header với gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[600]!],
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
                      Icons.shopping_bag,
                      size: 50,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '59 Sneaker',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Khám phá thế giới giày sneaker chất lượng cao',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Phần Giới thiệu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Về 59 Sneaker',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '59 Sneaker là shop bán giày sneaker chuyên nghiệp, mang đến những mẫu giày đắt giá và chất lượng cao nhất từ các thương hiệu nổi tiếng trên thế giới như Nike, Jordan, Adidas, Puma và nhiều hơn nữa.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Phần Lịch sử
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lịch sử',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                      '• Được thành lập vào năm 2018\n\n'
                      '• Từ một cửa hàng nhỏ tại TP.HCM, 59 Sneaker đã phát triển thành một trong những shop sneaker uy tín nhất tại Việt Nam.\n\n'
                      '• Với hơn 5 năm kinh nghiệm, chúng tôi đã phục vụ hàng ngàn khách hàng hài lòng.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phần Sứ mệnh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sứ mệnh & Tầm nhìn',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                      '▸ Sứ mệnh: Cung cấp những đôi giày sneaker chính hãng, chất lượng cao với giá cạnh tranh nhất, giúp mỗi khách hàng thể hiện phong cách cá nhân.\n\n'
                      '▸ Tầm nhìn: Trở thành shop sneaker hàng đầu Đông Nam Á, được tin tưởng và yêu thích bởi những người yêu giày.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phần Giá trị cốt lõi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giá trị cốt lõi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                      _buildValueCard('Giá tốt', Icons.attach_money, Colors.black87),
                      const SizedBox(width: 10),
                      _buildValueCard('Tư vấn', Icons.chat, Colors.black87),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phần Thông tin liên hệ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liên hệ với chúng tôi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildContactInfo(Icons.location_on, 'Địa chỉ', '56 Trần Bình Trọng, Q Bình Thạnh'),
                  const SizedBox(height: 10),
                  _buildContactInfo(Icons.phone, 'Điện thoại', '0123 456 789'),
                  const SizedBox(height: 10),
                  _buildContactInfo(Icons.email, 'Email', 'info@sneakerhub.com.vn'),
                  const SizedBox(height: 10),
                  _buildContactInfo(Icons.schedule, 'Giờ hoạt động', 'Thứ 2 - Chủ nhật: 9:00 - 22:00'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Phần Mạng xã hội
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theo dõi chúng tôi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSocialButton(Icons.facebook, 'Facebook', 'https://www.facebook.com/'),
                      _buildSocialButton(Icons.camera_alt, 'Instagram', 'https://www.instagram.com/59savage.wan/'),
                      _buildSocialButton(Icons.public, 'Twitter', 'https://twitter.com/'),
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
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
              child: Column(
                children: [
                  const Text(
                    '© 2026 59 Sneaker. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Cảm ơn bạn đã tin tưởng 59 Sneaker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget giá trị cốt lõi
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
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget thông tin liên hệ
  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget nút mạng xã hội
  Widget _buildSocialButton(IconData icon, String label, String url) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _launchURL(url),
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}