import 'package:flutter/material.dart';
import 'colors.dart';

class SignUpForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onToggle;

  SignUpForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 150),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.primaryColor, width: 2.0), // Adjust width here
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('SignUp',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(nameController, 'Name'),
            SizedBox(height: 10),
            _buildTextField(emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            SizedBox(height: 10),
            _buildTextField(passwordController, 'Password', obscureText: true),
            SizedBox(height: 10),
            _buildTextField(null, 'Confirm Password', obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSubmit,
              child: const Text('SignUp', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: onToggle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Login',
                      style: TextStyle(
                          color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

Widget _buildTextField(TextEditingController? controller, String label,
    {bool obscureText = false,
    TextInputType keyboardType = TextInputType.text}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black), // Default border color
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black), // Border color when focused
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black), // Border color when enabled
      ),
    ),
    obscureText: obscureText,
    keyboardType: keyboardType,
    cursorColor: AppColors.textColor,
    style: TextStyle(color: AppColors.textColor),
  );
}

}
