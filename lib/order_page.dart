import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class OrderPage extends StatefulWidget {
  final int orderId;

  const OrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Map<String, dynamic>? _orderDetails;
  List<dynamic>? _serviceOrders;
  bool _isLoading = true;
  bool _hasError = false;

  // Define theme colors
  static const primaryOrange = Color(0xFFFF6B35);
  static const secondaryOrange = Color(0xFFFFA07A);
  static const warmGray = Color(0xFFF5F5F5);
  static const catBrown = Color(0xFF8B4513);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orderDetails == null) {
      _loadData(); // Fetch data if it's not already loaded
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.wait([
        _fetchOrderDetails(),
        _fetchServiceOrders(),
      ]);
    } catch (e) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final response = await http
          .get(
            Uri.parse(
                'http://192.168.1.3/api-petshop/api/order_detail.php?id=${widget.orderId}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() => _orderDetails = data['data']);
        }
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  Future<void> _fetchServiceOrders() async {
    try {
      final response = await http
          .get(
            Uri.parse(
                'http://192.168.1.3/api-petshop/api/service_orders.php?order_id=${widget.orderId}'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() => _serviceOrders = data['data']);
        } else {
          setState(() => _serviceOrders = []);
        }
      } else {
        throw Exception('Failed to load service orders');
      }
    } catch (e) {
      throw Exception('Failed to load service orders: $e');
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                height: 20,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductOrder() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_orderDetails == null) {
      return const Center(
        child: Text('Tidak ada data pesanan'),
      );
    }

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                icon: Icons.shopping_bag,
                label: 'Produk',
                value: _orderDetails!['product_name']?.toString() ?? 'N/A',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.format_list_numbered,
                label: 'Jumlah',
                value: _orderDetails!['quantity']?.toString() ?? '0',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Total',
                value: 'Rp ${_orderDetails!['total_price']?.toString() ?? '0'}',
              ),
              const SizedBox(height: 16),
              _buildStatusBadge(
                  _orderDetails!['status']?.toString() ?? 'pending'),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Tanggal',
                value: _orderDetails!['created_at']?.toString() ?? 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOrders() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingShimmer();
    }

    if (_serviceOrders == null || _serviceOrders!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada layanan yang dipesan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serviceOrders!.length,
      itemBuilder: (context, index) {
        final service = _serviceOrders![index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: secondaryOrange,
              child: Icon(Icons.pets, color: Colors.white),
            ),
            title: Text(
              service['nama_kucing']?.toString() ?? 'Tidak ada nama',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Paket: ${service['paket_grooming']?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(service['status']?.toString() ?? 'pending'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: primaryOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Terjadi kesalahan saat memuat data',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Detail Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.shopping_cart),
                text: 'Order Produk',
              ),
              Tab(
                icon: Icon(Icons.pets),
                text: 'Order Layanan',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductOrder(),
            _buildServiceOrders(),
          ],
        ),
      ),
    );
  }
}
