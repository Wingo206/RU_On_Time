import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ru_on_time/authentication_service.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign In"),
            Text(message),
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
              obscureText: true,
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthenticationService>().signIn(emailController.text.trim(), passwordController.text.trim()).then((value) {
                      setState(() {
                        print(value);
                        message = value;
                      });
                    });
                  },
                  child: Text("Sign in"),
                ),
                SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthenticationService>().signUp(emailController.text.trim(), passwordController.text.trim()).then((value) {
                      setState(() {
                        print(value);
                        message = value;
                      });
                    });
                  },
                  child: Text("Sign up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
