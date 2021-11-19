import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ru_on_time/authentication_service.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthenticationService>().signIn(emailController.text.trim(), passwordController.text.trim());
              },
              child: Text("Sign in"),
            )
          ],
        ),
      ),
    );
  }

}