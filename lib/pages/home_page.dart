import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/components/bottom_nav_bar.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_clothingapp/pages/Dashboard/dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_page.dart';
import 'shop_page.dart';
import 'info_page.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {

  //this selected index is to control the bottom nav bar
  //0 tương đương với cái nút Gbut khai báo đầu tiên bên bottom_nav

  int _selectedIndex = 0;

  //this is method will update our selected index
  //whenever user click on bottom nav bar item
  //Cái này là hàm để cập nhật chỉ mục được chọn
  void navigateBottomBar(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //shop page
    const ShopPage(),

    //cart page
    const CartPage(),

    const InfoPage(),
  ];
    Future<String> _getUserRole() async {
    try {
      final authCubit = context.read<AuthCubit>();
      final userId = authCubit.currentUser?.uid; //  uid của bạn
      
      if (userId == null) return '';
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      return userDoc.data()?['role'] ?? '';
    } catch (e) {
      print('Error getting user role: $e');
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) => navigateBottomBar(index),
      ),
      //Code cho thanh App Bar phía trên và nút mở Menu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) =>
            IconButton(
              icon: Padding(
                padding:  EdgeInsets.only(left:12.0),
                child: Icon(Icons.menu),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                    },
                )
          
        ),
      ),
      //Code cho tab menu
      drawer: Drawer(
        backgroundColor: Colors.grey[800],
        child: Column(
           mainAxisAlignment:MainAxisAlignment.spaceBetween ,
           children: [
              Column(
              children: [
                 DrawerHeader(
                  child: Image.asset( 'lib/images/nike-5-logo.png',
                  color:Colors.white,),),
                  //divider
                  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(
                  color: Colors.grey[800],
                       ),
                   ),

                  //other pages
                  //Home
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      navigateBottomBar(0);
                    } ,
                    child: const Padding(
                    padding: EdgeInsets.only(left:25.0),
                    child: ListTile(
                    leading: Icon(Icons.home,
                    color: Colors.white,),
                    title: Text('Trang chủ',
                    style: TextStyle(
                    color: Colors.white,
                          ),
                       ),
                               
                      ),
                                     ),
                  ),

                  //About
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      navigateBottomBar(2);
                    } ,
                    child: const Padding(
                    padding:  EdgeInsets.only(left:25.0),
                    child: ListTile(
                    leading: Icon(Icons.info,
                    color: Colors.white,),
                    title: Text('Giới thiệu',
                    style: TextStyle(
                     color: Colors.white,
                     ),
                                     ),
                                 
                      ),
                                     ),
                  ),
                  //Profile  ← Thêm từ đây
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Hồ sơ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),  
                  // Dashboard - Chỉ hiển thị nếu user là admin
                  FutureBuilder<String>(
                    future: _getUserRole(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      
                      if (snapshot.data == 'admin') {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 25.0),
                            child: ListTile(
                              leading: Icon(
                                Icons.dashboard,
                                color: Colors.white,
                              ),
                              title: Text(
                                'Bảng điều khiển',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          //Logout
         GestureDetector(
            onTap: (){
              final authCubit = context.read<AuthCubit>();
              authCubit.logout();
            }, 
            child: const Padding(
              padding: EdgeInsets.only(left:25.0, bottom: 25.0),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.white,),
                title: Text('Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

        ],//Children
        ),
          
      ),

      //0 tương đương với home, 1 tương đương với cart, 2 tương đương about
      body:_pages[_selectedIndex],
        
    );
  }
}