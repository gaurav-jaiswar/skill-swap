import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/provider/auth.dart';
import 'package:skill_swap/screens/auth/add_skills.dart';
import 'package:skill_swap/utils/transition.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final dob = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    const Color errorColor = Color.fromARGB(255, 243, 90, 79);
    return ChangeNotifierProvider(
      create: (context) => RegisterProvider(),
      builder:
          (context, child) => Scaffold(
            body: Container(
              height: MediaQuery.sizeOf(context).height,
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * .03,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 49, 49, 49),
                    Color.fromARGB(255, 92, 92, 92),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Image.asset(
                          'assets/images/name.png',
                          width: MediaQuery.sizeOf(context).width * .5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.sizeOf(context).height * .8 < 400
                                  ? 400
                                  : MediaQuery.sizeOf(context).height * .8,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 95, 92, 92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: name,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Consumer<RegisterProvider>(
                              builder:
                                  (context, value, child) =>
                                      name.text.isEmpty && value.showError
                                          ? const Text(
                                            "   *required field",
                                            style: TextStyle(color: errorColor),
                                          )
                                          : const SizedBox(height: 5),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextField(
                                        canRequestFocus: false,
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            firstDate: DateTime(1950),
                                            lastDate: DateTime.now().copyWith(
                                              year: DateTime.now().year - 16,
                                            ),
                                          );
                                          if (date != null) {
                                            dob.text = DateFormat(
                                              'dd-MM-yyyy',
                                            ).format(date);
                                          }
                                        },
                                        readOnly: true,
                                        controller: dob,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        keyboardType: TextInputType.datetime,
                                        decoration: InputDecoration(
                                          labelText: "Date Of Birth",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          suffixIcon: Icon(
                                            Icons.calendar_month_outlined,
                                          ),
                                        ),
                                      ),
                                      Consumer<RegisterProvider>(
                                        builder:
                                            (context, value, child) =>
                                                dob.text.isEmpty &&
                                                        value.showError
                                                    ? const Text(
                                                      "   *required field",
                                                      style: TextStyle(
                                                        color: errorColor,
                                                      ),
                                                    )
                                                    : const SizedBox(height: 5),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DropdownMenu(
                                        onSelected:
                                            (value) =>
                                                context
                                                    .read<RegisterProvider>()
                                                    .gender = value,
                                        menuStyle: MenuStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                Color.fromARGB(255, 49, 49, 49),
                                              ),
                                        ),
                                        label: Text("Select Gender"),
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                .47 -
                                            15,
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                            value: "Male",
                                            label: "Male",
                                          ),
                                          DropdownMenuEntry(
                                            value: "Female",
                                            label: "Female",
                                          ),
                                          DropdownMenuEntry(
                                            value: "NA",
                                            label: "Prefer Not To Say",
                                          ),
                                        ],
                                      ),
                                      Consumer<RegisterProvider>(
                                        builder:
                                            (context, value, child) =>
                                                value.gender == null &&
                                                        value.showError
                                                    ? const Text(
                                                      "   *required field",
                                                      style: TextStyle(
                                                        color: errorColor,
                                                      ),
                                                    )
                                                    : const SizedBox(height: 5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email Address",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Consumer<RegisterProvider>(
                              builder:
                                  (context, value, child) =>
                                      email.text.isEmpty && value.showError
                                          ? const Text(
                                            "   *required field",
                                            style: TextStyle(color: errorColor),
                                          )
                                          : const SizedBox(height: 5),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: password,
                              obscureText: true,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Consumer<RegisterProvider>(
                              builder:
                                  (context, value, child) =>
                                      password.text.isEmpty && value.showError
                                          ? const Text(
                                            "   *required field",
                                            style: TextStyle(color: errorColor),
                                          )
                                          : const SizedBox(height: 5),
                            ),
                            const SizedBox(height: 20),
                            Consumer<RegisterProvider>(
                              builder:
                                  (context, value, child) => Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      value.error ?? "",
                                      style: const TextStyle(
                                        color: errorColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.center,
                              child: Consumer<RegisterProvider>(
                                builder:
                                    (context, value, child) => ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromARGB(
                                          255,
                                          169,
                                          169,
                                          169,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 20,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (await value.register(
                                          name: name.text,
                                          dob: dob.text,
                                          email: email.text,
                                          password: password.text,
                                        )) {
                                          Navigator.of(context).pushReplacement(
                                            transitionToNextScreen(
                                              AddSkillsPage(
                                                isSkillWanted: false,
                                              ),
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
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
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
                                          if (value.isLoading)
                                            const SizedBox(width: 10),
                                          Text(
                                            'Register',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                51,
                                                102,
                                              ),
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
