import 'package:chat_app/auth/screen/signup_screen.dart';
import 'package:chat_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/utils.dart';
import '../../chat/screen/app_main_screen.dart';
import '../../core/services/route.dart';
import '../service/aut_service.dart';
import '../service/auth_provider.dart';
import 'google_signin_screen.dart';

class UserLoginScreen extends ConsumerWidget {
  const UserLoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    final formState = ref.watch(authFormProvider);
    final formNotifier = ref.read(authFormProvider.notifier);
    final authMethod = ref.read(authMethodProvider);
    void login() async {
      formNotifier.setLoading(true);
      final res = await authMethod.loginUser(
        email: formState.email,
        password: formState.password,
      );
      formNotifier.setLoading(false);
      if (res == "success") {
        NavigationHelper.pushReplacement(context, AppMainScreen());
        showAppSnackbar(
          context: context,
          type: SnackbarType.success,
          description: "Successful Login",
        );
      } else {
        showAppSnackbar(
          context: context,
          type: SnackbarType.error,
          description: res,
        );
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                // height: height / 2.5,
                height: height / 4.5,
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 25),
                    const SizedBox(width: 5),
                    Text(
                      'Chatty',
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
                // child: Image.asset("assets/2752392.jpg", fit: BoxFit.cover),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      'Login to chatty',
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      "Welcome! We've missed you!",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => formNotifier.updateEmail(value),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "Enter your email",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formState.emailError,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => formNotifier.updatePassword(value),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: formState.isPasswordHidden,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Enter your password",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(15),
                        errorText: formState.passwordError,
                        suffixIcon: IconButton(
                          onPressed: () => formNotifier.togglePasswordVisibility(),
                          icon: Icon(
                            formState.isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    formState.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : CustomFilledButton(
                        label: 'Login',
                        isFullWidth: true,
                        onPressed: formState.isFormValid ? login : null
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                        Text(" or "),
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    GoogleSigninScreen(),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Spacer(),
                        Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            NavigationHelper.push(context, SignupScreen());
                          },
                          child: Text(
                            "SignUp",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}