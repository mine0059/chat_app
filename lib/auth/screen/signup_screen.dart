import 'package:chat_app/auth/screen/signin_screen.dart';
import 'package:chat_app/auth/service/aut_service.dart';
import 'package:chat_app/auth/service/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/utils.dart';
import '../../chat/screen/app_main_screen.dart';
import '../../core/services/route.dart';
import '../../core/widgets/custom_button.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formstate = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);

    void signup() async {
      formNotifier.setLoading(true);
      final res = await authMethod.signUpUser(
          email: formstate.email,
          password: formstate.password,
          name: formstate.name,
      );
      formNotifier.setLoading(false);
      if (res == "success" && context.mounted) {
        NavigationHelper.pushReplacement(context, AppMainScreen());
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Successful Signup",
        );
      } else {
        if (context.mounted) {
          showAppSnackbar(
            context: context,
            type: SnackbarType.error,
            description: res,
          );
        }
      }
    }
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: ListView(
            children: [
              Container(
                height: height / 2.5,
                width: double.maxFinite,
                decoration: BoxDecoration(),
                child: Icon(Icons.login, size: 50,),
              ),
              const SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => formNotifier.updateName(value),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Enter your name",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formstate.nameError,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => formNotifier.updateEmail(value),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Enter your email",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formstate.emailError,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => formNotifier.updatePassword(value),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Enter your password",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formstate.passwordError,
                        suffixIcon: IconButton(
                            onPressed: () => formNotifier.togglePasswordVisibility(),
                            icon: Icon(
                              formstate.isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            )
                        )
                      ),
                    ),
                    SizedBox(height: 15),
                    formstate.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : CustomFilledButton(
                        label: 'Register',
                        isFullWidth: true,
                        onPressed: () {}
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Spacer(),
                        Text("Already have an account?"),
                        GestureDetector(
                          onTap: () {
                            NavigationHelper.push(context, UserLoginScreen());
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}
