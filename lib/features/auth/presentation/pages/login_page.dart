import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/components/my_button.dart';
import 'package:flutter_clothingapp/components/my_textfield.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController(); 
  //auth cubit
  late final authCubit = context.read<AuthCubit>();

  //login button pressed
  void login(){
    //prepare email & password
    final String email = emailController.text;
    final String pw = pwController.text;  

  
    //Login!
    if(email.isNotEmpty && pw.isNotEmpty)
    {
      //call login method from auth cubit
      authCubit.login(email,pw);
    }
    else{
      //show error - fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin"))
      );
    }
  }

  //forgot password box
  void openForgotPasswordBox(){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: const Text("Quên mật khẩu"),
        content: MyTextfield(
          controller: emailController, 
          hintText: "Nhập email của bạn", 
          obscureText: false,
          ),
          actions:[
            //cancel button
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text("Hủy"),
            ),
            //reset button
            TextButton(
              onPressed: () async {
               String message = await authCubit.forgotPassword(emailController.text);

               if(message == "Password reset email sent!"){
                Navigator.of(context).pop();
                emailController.clear();
               }

               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message))
               );
              }, 
              child: const Text("Đặt lại"),
            ),
          ]
      )
    );
  }

  //BUILD UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                  'lib/images/nike-5-logo.png',
                  height: 150,
                   ),
              ),
              //name of app
              const Text(
                '59 SNEAKER SHOP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
              const SizedBox(height: 10),
              const Text(
                        'Chào mừng bạn quay trở lại!',
                 style: TextStyle(fontSize: 16, color: Colors.grey),
               ),
              const SizedBox(height: 25),
          
          
              //email text field
              MyTextfield(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 10),
          
              //pw text field
              MyTextfield(
                controller: pwController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(height: 10),
          
              //forgot pw button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap:()=> openForgotPasswordBox(),
                    child: Text("Quên mật khẩu?", style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
          
              //login button  
              MyButton(
                onTap: login,
                text: "ĐĂNG NHẬP",
              ),

          
              //oather login methods


              const SizedBox(height: 10),
              //register button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Chưa có tài khoản? ", style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold),
                  ),
                   GestureDetector(
                     onTap: widget.togglePages,
                     child: Text("Đăng ký", style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                                       ),
                   ),
                ],
              ),
          
          
            ],
          ),
        ),
      ),
    );
  }
}