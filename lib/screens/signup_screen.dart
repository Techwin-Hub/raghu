import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/profile_picture_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String password = '';
  File? profileImage;

  void _submitForm() async {
    if (_formKey.currentState!.validate() && profileImage != null) {
      _formKey.currentState!.save();
      bool success = await ApiService.signupUser(
        firstName,
        lastName,
        email,
        phone,
        password,
        profileImage!,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful')),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfilePicturePicker(
                onImageSelected: (file) {
                  profileImage = file;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                onSaved: (val) => firstName = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                onSaved: (val) => lastName = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val!,
                validator: (val) => val!.contains('@') ? null : 'Invalid Email',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (val) => phone = val!,
                validator: (val) => val!.length >= 10 ? null : 'Invalid Number',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: (val) => val!.length >= 6 ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
