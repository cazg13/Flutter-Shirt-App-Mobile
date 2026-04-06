import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_clothingapp/models/user_profile.dart';
import 'package:flutter_clothingapp/models/order.dart';
import 'package:flutter_clothingapp/repositories/order_repository.dart';
import 'package:flutter_clothingapp/components/order_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  // Controllers để edit thông tin
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool isEditMode = false;
  late TabController _tabController;
  final OrderRepository _orderRepository = OrderRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    
    // Init TabController (2 tabs)
    _tabController = TabController(length: 2, vsync: this);
    
    // Lấy profile hiện tại
    UserProfile? profile = context.read<AuthCubit>().currentUserProfile;
    
    // Init controllers với dữ liệu hiện tại
    nameController = TextEditingController(text: profile?.name ?? '');
    phoneController = TextEditingController(text: profile?.phone ?? '');
    addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Hàm lưu thông tin
  void _saveProfile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang lưu thông tin...')),
    );

    context.read<AuthCubit>().updateUserProfile(
      name: nameController.text.isEmpty ? null : nameController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text,
      address: addressController.text.isEmpty ? null : addressController.text,
    );
    
    setState(() {
      isEditMode = false;
    });
  }

  void _cancelEdit() {
    UserProfile? profile = context.read<AuthCubit>().currentUserProfile;
    nameController.text = profile?.name ?? '';
    phoneController.text = profile?.phone ?? '';
    addressController.text = profile?.address ?? '';
    
    setState(() {
      isEditMode = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận logout'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công!')),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tài Khoản Của Tôi'),
          centerTitle: true,
          backgroundColor: Colors.grey[850],  // ← Màu xám đậm
          elevation: 2,  // ← Nổi trội hơn
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Thông tin cá nhân'),
              Tab(text: 'Đơn hàng'),
            ],
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is Unauthenticated) {
              return const Center(child: Text('Bạn chưa đăng nhập'));
            }

            UserProfile? profile = context.read<AuthCubit>().currentUserProfile;
            String? email = context.read<AuthCubit>().currentUser?.email;

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Thông tin cá nhân
                _buildPersonalInfoTab(profile, email),
                
                // TAB 2: Đơn hàng
                _buildOrdersTab(email),
              ],
            );
          },
        ),
      ),
    );
  }

  // Tab 1: Thông tin cá nhân
  Widget _buildPersonalInfoTab(UserProfile? profile, String? email) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          email ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Role
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge, color: Colors.grey),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Role',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          profile?.role ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 20),

            // Thông tin có thể edit
            if (!isEditMode) ...[
              // Tên
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tên',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            nameController.text.isEmpty
                                ? 'Chưa cập nhật'
                                : nameController.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Số điện thoại
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Số Điện Thoại',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            phoneController.text.isEmpty
                                ? 'Chưa cập nhật'
                                : phoneController.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Địa chỉ
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Địa Chỉ',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            addressController.text.isEmpty
                                ? 'Chưa cập nhật'
                                : addressController.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Nút Edit
              GestureDetector(
                onTap: () {
                  setState(() {
                    isEditMode = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.indigo[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Chỉnh Sửa Thông Tin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Edit Mode
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số Điện Thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Địa Chỉ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Nút Lưu / Hủy
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Lưu',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _cancelEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            
            
          ],
        ),
      ),
    );
  }

  // Tab 2: Đơn hàng
  Widget _buildOrdersTab(String? email) {
    return FutureBuilder<List<ShopOrder>>(
      future: _orderRepository.getUserOrders(_auth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        List<ShopOrder> orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Text('Bạn chưa có đơn hàng nào'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderTile(order: orders[index]);
          },
        );
      },
    );
  }
}