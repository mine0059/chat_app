import 'package:chat_app/wrapper_state/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/screen/signin_screen.dart';
import 'chat/provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      const ProviderScope(
          child: MyApp(),
      ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // watching the authStateProvider to firebase auth changes
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: authState.when(
          data: (user) {
           if (user != null) {
             return AuthenticationWrapper();
           } else {
             return UserLoginScreen();
           }
          },
          error: (error, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text("Error: $error"),
                  SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: () => ref.invalidate(authStateProvider),
                      child: Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
          loading: () => Scaffold(body: Center(child: CircularProgressIndicator(),),)
      ),
    );
  }
}
