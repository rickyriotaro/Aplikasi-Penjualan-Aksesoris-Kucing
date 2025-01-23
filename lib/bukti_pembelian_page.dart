import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuktiPembelianPage extends StatefulWidget {
  final int orderId;

  const BuktiPembelianPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _BuktiPembelianPageState createState() => _BuktiPembelianPageState();
}

class _BuktiPembelianPageState extends State<BuktiPembelianPage> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.3/api-petshop/api/order_detail.php?id=${widget.orderId}')); // Ganti dengan URL API Anda

    if (response.statusCode == 200) {
      setState(() {
        _orderDetails = json.decode(response.body)['data'];
        _isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load order details');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bukti Pembelian'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terima kasih telah melakukan pembelian!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ID Pesanan: ${_orderDetails!['id']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Nama Produk: ${_orderDetails!['product_name']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Jumlah: ${_orderDetails!['quantity']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Harga: Rp ${_orderDetails!['total_price']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Metode Pembayaran: ${_orderDetails!['payment_method']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Status: ${_orderDetails!['status']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tanggal Pesanan: ${_orderDetails!['created_at']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/order',
                          arguments: widget.orderId);
                    },
                    child: Text('Lihat Detail Pesanan'),
                  ),
                ],
              ),
            ),
    );
  }
}
