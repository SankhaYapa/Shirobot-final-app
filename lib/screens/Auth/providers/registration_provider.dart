import 'dart:ffi';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shiro_bot/components/custom_dialogBox.dart';
import 'package:shiro_bot/screens/Auth/controller/auth_controller.dart';
import 'package:shiro_bot/screens/Auth/model/auth_model.dart';
import 'package:shiro_bot/screens/Auth/providers/user_provider.dart';
import 'package:shiro_bot/screens/Auth/view/Login/login_page.dart';
import 'package:shiro_bot/screens/Auth/view/auth_page.dart';
import 'package:shiro_bot/screens/Home/controller/home_controller.dart';
import 'package:shiro_bot/screens/Home/view/home_page.dart';
import 'package:shiro_bot/utils/util_function.dart';

class RegistrationProvider extends ChangeNotifier {
  bool _isLoading = false;
//firebase auth instance
  FirebaseAuth auth = FirebaseAuth.instance;
  var _isObscure = true;
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmpassword = TextEditingController();
  String? _gender;
  String? _dateOfBirth;
  String? _country;
  String? _phoneNumber;

  // final _gender = TextEditingController();
  // final _dateOfbirth = TextEditingController();
  // final _country = TextEditingController();
  // final _phoneNumber = TextEditingController();

//get obscure state
  bool get isObscure => _isObscure;

//get loading state
  bool get isLoading => _isLoading;

  //get firstname controller
  TextEditingController get firstnameController => _firstname;

  //get lastname controller
  TextEditingController get lastnameController => _lastname;

  //get email controller
  TextEditingController get emailController => _email;

  //get password controller
  TextEditingController get passwordController => _password;

  //get password controller
  TextEditingController get confirmpasswordController => _confirmpassword;
  // //get gender controller
  String? get gender => _gender;
  // //get dateofbirth controller
  String? get dateOfBirth => _dateOfBirth;

  // //get country controller
  String? get country => _country;
  // //get phone controller
  String? get phoneNumber => _phoneNumber;

  //change obscure state
  void changeObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  static final _authModel = AuthModel();
  //registration function
  Future<void> startRegister(BuildContext context) async {
    try {
      if (inputValidation()) {
        setLoading(true);
        await AuthController().registerUser(
            context,
            _firstname.text,
            _lastname.text,
            _email.text,
            _password.text,
            _confirmpassword.text,
            _gender.toString(),
            _dateOfBirth.toString(),
            _country.toString(),
            _phoneNumber.toString());
        userProvider().userName = _firstname.text;
        setLoading();
      } else {
        setLoading();
        DialogBox().dialogBox(
          context,
          DialogType.ERROR,
          'Incorrect Information',
          'Please enter correct Information',
        );
      }
    } catch (e) {
      setLoading();
      Logger().e(e);
    }
  }

//validation Function
  bool inputValidation() {
    var isValid = false;
    if (_firstname.text.isEmpty ||
        _lastname.text.isEmpty ||
        _email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirmpassword.text.isEmpty ||
        _gender.toString().isEmpty ||
        _dateOfBirth.toString().isEmpty ||
        _country.toString().isEmpty ||
        _phoneNumber.toString().isEmpty) {
      isValid = false;
    } else if (!EmailValidator.validate(_email.text)) {
      isValid = false;
    } else if (_password.text != _confirmpassword.text) {
      isValid = false;
    } else {
      isValid = true;
    }
    return isValid;
  }

  //change loading state
  void setLoading([bool val = false]) {
    _isLoading = val;
    notifyListeners();
  }

////////
/////////
////////
  final AuthController _authController = AuthController();

  //user credential
  late UserCredential _userCredential;
//google sign in function
  Future<void> googleAuth(BuildContext context) async {
    String user;
    try {
      _userCredential = await _authController.signInWithGoogle();
      user = _userCredential.user!.displayName!;

      _authController.savedata(
        _userCredential.user?.displayName,
        " ",
        _userCredential.user?.email,
        _userCredential,
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.BOTTOMSLIDE,
        title: "Success",
        desc: "Login Success",
        btnOkOnPress: () {
          UtilFunction.navigateTo(context, HomePage());
        },
      ).show();

      Future.delayed(
        const Duration(seconds: 3),
        () {
          UtilFunction.navigateTo(context, HomePage());
        },
      );

      Logger().i(_userCredential);
      notifyListeners();
    } catch (e) {
      Logger().e(e);
    }
  }

//facebook signin
  Future<void> faceBookAuth() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      Logger().i(_userCredential);
      notifyListeners();
    } catch (e) {
      Logger().e(e);
    }
  }

  String? name = "";

  //initialize user function
  //Future<void> initializerUser(BuildContext context) async {
  //Provider.of<HomeController>(context, listen: false)
  ///    .chechBlutoothOn(context);
  // print("AAAAAAAAAAAAAAAAAAAAAA");
  // FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //  if (user == null) {
  //  Logger().w('User is currently signed out');
  // UtilFunction.navigateTo(context, AuthPage());
  //} else {
  //name = user.email;

  // Logger().w('User is signed in');
  // UtilFunction.navigateTo(context, HomePage());
  // }
  // });
  // }

  //sign out
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    //final GoogleSignInAccount? googleUser = await GoogleSignIn().disconnect();

    UtilFunction.navigateTo(context, AuthPage());
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
        UtilFunction.navigateTo(context, AuthPage());
      }
      await FirebaseAuth.instance.signOut();
      UtilFunction.navigateTo(context, AuthPage());
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   Auth.customSnackBar(
      //     content: 'Error signing out. Try again.',
      //   ),
      // );
    }
  }
}
