import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/provider/auth.dart';
import 'package:skill_swap/provider/home_provider.dart';
import 'package:skill_swap/screens/auth/register_screen.dart';
import 'package:skill_swap/screens/homescreen.dart';
import 'package:skill_swap/utils/transition.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController userId = TextEditingController();
    TextEditingController password = TextEditingController();
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * .05,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 49, 49, 49),
              Color.fromARGB(255, 92, 92, 92),
            ],
          ),
        ),
        child: Row(
          children: [
            if (MediaQuery.orientationOf(context) == Orientation.landscape)
              Expanded(
                child: Text(
                  'Welcome to Platform to learn new Skills and Share the existing Ones...',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).devicePixelRatio * 50,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (MediaQuery.orientationOf(context) == Orientation.landscape)
              SizedBox(width: MediaQuery.sizeOf(context).width * .1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? MediaQuery.sizeOf(context).width / 2 -
                            MediaQuery.sizeOf(context).width * .1
                        : MediaQuery.sizeOf(context).width -
                            MediaQuery.sizeOf(context).width * .1,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png'),
                    TextField(
                      controller: userId,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Id",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Consumer<LoginProvider>(
                      builder:
                          (context, value, child) => Column(
                            children: [
                              Text(
                                value.error ?? "",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    169,
                                    169,
                                    169,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(12),
                                ),
                                onPressed: () async {
                                  if (await value.login(
                                    userId.text,
                                    password.text,
                                    context,
                                  )) {
                                    context
                                        .read<HomeProvider>()
                                        .init();
                                    Navigator.of(context).pushReplacement(
                                      transitionToNextScreen(
                                        const Homescreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (value.isLoading)
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          padding: const EdgeInsets.all(2),
                                          color: Color.fromARGB(
                                            255,
                                            0,
                                            51,
                                            102,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 30),
                                    Text(
                                      '      Login     ',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 51, 102),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(transitionToNextScreen(const RegisterScreen()));
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blueAccent,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
