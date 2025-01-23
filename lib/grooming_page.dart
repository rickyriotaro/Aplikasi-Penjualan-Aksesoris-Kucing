import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroomingPage extends StatefulWidget {
  const GroomingPage({Key? key}) : super(key: key);

  @override
  _GroomingPageState createState() => _GroomingPageState();
}

class _GroomingPageState extends State<GroomingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _catNameController = TextEditingController();
  final TextEditingController _catCountController = TextEditingController();
  final TextEditingController _catAgeMonthsController = TextEditingController();
  final TextEditingController _catAgeYearsController = TextEditingController();
  String _gender = 'Jantan';
  String _groomingPackage = 'Paket Regular (Rp. 50.000)';
  DateTime? _startDate;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.8/api-petshop/api/create_grooming_order.php'), // Ganti dengan URL API Anda
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_id': 3, // Ganti dengan ID pengguna yang sesuai
          'nama_pemilik': _ownerNameController.text,
          'nama_kucing': _catNameController.text,
          'jumlah_kucing': int.parse(_catCountController.text),
          'jenis_kelamin': _gender,
          'jenis_kucing':
              'Persia', // Ganti dengan input jenis kucing jika diperlukan
          'umur_bulan': int.parse(_catAgeMonthsController.text),
          'umur_tahun': int.parse(_catAgeYearsController.text),
          'paket_grooming': _groomingPackage,
          'tanggal_mulai': _startDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] == 'Order created successfully') {
          Navigator.pushReplacementNamed(context, '/order',
              arguments: data['order_id']);
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Failed to create grooming order');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kesalahan'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Grooming'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ownerNameController,
                decoration: InputDecoration(labelText: 'Nama Pemilik'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pemilik tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _catNameController,
                decoration: InputDecoration(labelText: 'Nama Kucing'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kucing tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _catCountController,
                decoration: InputDecoration(labelText: 'Jumlah Kucing'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah kucing tidak boleh kosong';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                items: <String>['Jantan', 'Betina']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _catAgeMonthsController,
                decoration: InputDecoration(labelText: 'Umur Kucing (Bulan)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _catAgeYearsController,
                decoration: InputDecoration(labelText: 'Umur Kucing (Tahun)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _groomingPackage,
                decoration: InputDecoration(labelText: 'Paket Grooming'),
                items: <String>[
                  'Paket Regular (Rp. 50.000)',
                  'Paket Anti Kutu (Rp. 60.000)',
                  'Paket Anti Jamur (Rp. 70.000)',
                  'Paket Komplit (Rp. 80.000)'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _groomingPackage = newValue!;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tanggal Mulai'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _startDate) {
                    setState(() {
                      _startDate = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _startDate != null
                      ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                      : '',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
