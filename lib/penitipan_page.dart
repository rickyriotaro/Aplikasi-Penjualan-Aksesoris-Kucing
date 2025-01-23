import 'package:flutter/material.dart';

class PenitipanPage extends StatelessWidget {
  const PenitipanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penitipan Kucing'),
      ),
      body: Center(
        child: Text('Halaman Penitipan Kucing'),
      ),
    );
  }
}
