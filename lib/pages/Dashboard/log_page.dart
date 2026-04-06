import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure TabController is initialized
    _tabController ??= TabController(length: 3, vsync: this);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs Quản Trị'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.cancel_presentation),
              text: 'Đơn Hủy',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Hoàn Thành',
            ),
            Tab(
              icon: Icon(Icons.input),
              text: 'Nhập Hàng',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: CancelLog
          _buildLogColumn(
            collection: 'CancelLog',
            logType: 'cancel',
            orderByField: 'cancelledAt',
          ),
          // Tab 2: CompleteLog
          _buildLogColumn(
            collection: 'CompleteLog',
            logType: 'complete',
            orderByField: 'completedAt',
          ),
          // Tab 3: ImportStockLog
          _buildLogColumn(
            collection: 'ImportStockLog',
            logType: 'import',
            orderByField: 'importedAt',
          ),
        ],
      ),
    );
  }

  // Build nội dung tab
  Widget _buildLogColumn({
    required String collection,
    required String logType,
    required String orderByField,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLogs(collection, orderByField),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi: ${snapshot.error}'),
          );
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có log nào',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return _buildLogTile(
              log: logs[index],
              logType: logType,
            );
          },
        );
      },
    );
  }

  // Fetch logs từ Firestore
  Future<List<Map<String, dynamic>>> _fetchLogs(
    String collection,
    String orderByField,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .orderBy(orderByField, descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'documentId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Lỗi fetch logs: $e');
    }
  }

  // Build log tile
  Widget _buildLogTile({
    required Map<String, dynamic> log,
    required String logType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (logType == 'cancel')
            _buildCancelLogContent(log)
          else if (logType == 'complete')
            _buildCompleteLogContent(log)
          else if (logType == 'import')
            _buildImportLogContent(log),
        ],
      ),
    );
  }

  // CancelLog - Hiển thị: Email khách, Thời gian, Mã đơn, Lý do, UID khách
  Widget _buildCancelLogContent(Map<String, dynamic> log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogRow('Email khách', log['userEmail'] ?? 'N/A'),
        _buildLogRow('Thời gian', _formatDate(log['cancelledAt'])),
        _buildLogRow('Mã đơn', log['orderId'] ?? 'N/A'),
        _buildLogRow('Lý do', log['cancelReason'] ?? 'Không có lý do'),
        _buildLogRow('UID khách', log['userId'] ?? 'N/A'),
      ],
    );
  }

  // CompleteLog - Hiển thị: Admin xác nhận, Thời gian, Mã đơn, UID Admin
  Widget _buildCompleteLogContent(Map<String, dynamic> log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogRow('Admin xác nhận', log['adminEmail'] ?? 'N/A'),
        _buildLogRow('Thời gian', _formatDate(log['completedAt'])),
        _buildLogRow('Mã đơn', log['orderId'] ?? 'N/A'),
        _buildLogRow('UID Admin', log['adminUid'] ?? 'N/A'),
      ],
    );
  }

  // ImportStockLog - Hiển thị: Admin nhập, Thời gian, ID sản phẩm, Số lượng nhập
  Widget _buildImportLogContent(Map<String, dynamic> log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLogRow('Admin nhập', log['adminEmail'] ?? 'N/A'),
        _buildLogRow('Thời gian', _formatDate(log['importedAt'])),
        _buildLogRow('ID sản phẩm', log['productId'] ?? 'N/A'),
        _buildLogRow('Số lượng nhập', log['stockAdded']?.toString() ?? '0'),
      ],
    );
  }

  // Helper method để build các row thông tin
  Widget _buildLogRow(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Helper method để format ngày giờ
  String _formatDate(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    DateTime dt;
    if (dateTime is Timestamp) {
      dt = dateTime.toDate();
    } else if (dateTime is DateTime) {
      dt = dateTime;
    } else {
      return 'N/A';
    }

    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}