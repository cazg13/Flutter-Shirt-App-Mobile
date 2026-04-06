import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_bloc.dart';
import 'package:flutter_clothingapp/bloc/shoe_event.dart';
import 'package:flutter_clothingapp/components/loading.dart';
import 'package:flutter_clothingapp/features/auth/data/firebase_auth_repo.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_clothingapp/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_clothingapp/firebase_options.dart';
import 'package:flutter_clothingapp/models/cart.dart';
import 'package:flutter_clothingapp/pages/home_page.dart';
import 'package:flutter_clothingapp/repositories/shoe_repository.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main()  async{
  //firebase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);
   // Khởi tạo Firestore connection
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  
  //run app
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
    providers: [
      // 1. Khai báo Provider cho Giỏ hàng
      ChangeNotifierProvider(
        create: (context) => Cart(),
      ),

      // 2. Khai báo Bloc cho Authentication
      
      BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
      ),
      
      // 3. Khai báo Bloc cho Shoe
      BlocProvider<ShoeBloc>(
            create: (context) => ShoeBloc(ShoeRepository())
              ..add(const FetchAllShoesEvent()),
          ),

      
    
    ],
    // Dùng child thay vì builder nếu không cần truy cập trực tiếp vào value ngay tại đây
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      /*
      BLOC CONSUMER Ở ĐÂY ĐỂ THEO DÕI TRẠNG THÁI XÁC THỰC NGƯỜI DÙNG
      */
      home:BlocConsumer<AuthCubit,AuthState>(
        builder: (context,state){
          print(state);
          //unauthenticated -> auth page (login/register)
          if(state is Unauthenticated){
            return const AuthPage();
          }

          //authenticated
          if(state is Authenticated){
            return const HomePage();
          }

          //loading
          else {
            return const LoadingScreen();
          }
        }, 
        //Listen for state changes 
        listener: (context,state){
         if(state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          //show error message
          if(state is AuthError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message))
            );
          }
        }
      ),
    ),
  );
}
}