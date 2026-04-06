import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clothingapp/components/my_button.dart';
import 'package:flutter_clothingapp/components/my_textfield.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:flutter_clothingapp/features/auth/presentation/cubits/auth_states.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final pwController = TextEditingController(); 
  final confirmPwController = TextEditingController();

  //register button pressed
  void register()
  {
    //prepare info
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();

    //ensure fields aren't empty
    if(name.isNotEmpty && email.isNotEmpty && pw.isNotEmpty && confirmPw.isNotEmpty)
    {
      //ensure passwords match
      if(pw == confirmPw)
      {
        //call register method from auth cubit
        authCubit.register(name,email,pw);
      }
      else{
        //show error - passwords don't match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mất khẩu không khớp"))
        );
      }
    }
    else{
      //show error - fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin"))
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

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
                          'Hãy tạo một tài khoản để bắt đầu!',
                   style: TextStyle(fontSize: 16, color: Colors.grey),
                 ),
                const SizedBox(height: 25),
            
              //email text field
                  MyTextfield(
                    controller: nameController,
                    hintText: "Họ và tên",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),
              
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
      
                //confirm pw text field
                MyTextfield(
                  controller: confirmPwController,
                  hintText: "Confirm Password",
                  obscureText: true,
                ),
                const SizedBox(height: 25),
            
              
            
                //register button  
                MyButton(
                  onTap: register,
                  text: "ĐĂNG KÝ",
                ),
      
            
                //oather login methods
      
      
                const SizedBox(height: 10),
                //already have account button? login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bạn đã có tài khoản rồi? ", style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text("Đăng nhập ngay", style: TextStyle(
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