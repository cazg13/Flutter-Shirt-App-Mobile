import 'package:flutter/material.dart';
import 'home_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Khai báo Controller để lấy dữ liệu nếu cần sau này
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[300], // Sử dụng màu xám sáng cho chuyên nghiệp
      body: Stack(
        children: [
          SafeArea( // Dùng SafeArea để không bị lẹm vào phần tai thỏ/camera
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 25.0),
                child: Text("v1.0",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView( 
              // Thêm cái này để tránh lỗi khi bàn phím hiện lên
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. Logo 
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'lib/images/nike-4-logo.png',
                        height: 150,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 2. Title & Subtitle
                    const Text(
                      '59 SNEAKER SHOP',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Chào mừng bạn quay trở lại!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    // 3. Khung Tài khoản
                    Padding(
                      padding: const EdgeInsets.only(left:25.0,right:25),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Tài khoản',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 4. Khung Mật khẩu
                    Padding(
                      padding: const EdgeInsets.only(left:25.0,right:25),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true, // Ẩn mật khẩu
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Mật khẩu',
                        ),
                      ),
                    ),
                    //Text đăng kí tài khoản
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left:25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Chưa có tài khoản?Đăng kí ngay",
                            style: TextStyle(
                                color: Colors.blue
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 5. Button Đăng nhập (Làm nhỏ lại bằng cách giảm padding)
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement( // Dùng pushReplacement để không quay lại trang login
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      ),
                      child: Container(
                        width: 200, // Khống chế độ rộng của nút
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(15), // Padding nhỏ hơn ban đầu
                        child: const Center(
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}