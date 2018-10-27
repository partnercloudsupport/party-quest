import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:party_quest/components/logger.dart';
// import 'package:phone_auth/widgets/google_sign_in_btn.dart';
// import 'package:phone_auth/routes/main_screen.dart';
import 'package:party_quest/components/maskedTextField.dart';
import 'package:party_quest/components/reactive_refresh_indicator.dart';
import 'dart:math';

enum AuthStatus { SOCIAL_AUTH, PHONE_AUTH, SMS_AUTH, PROFILE_AUTH }

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const String TAG = "AUTH";
  AuthStatus status = AuthStatus.PHONE_AUTH;

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();
  final GlobalKey<MaskedTextFieldState> _maskedPhoneKey = GlobalKey<MaskedTextFieldState>();
  final GlobalKey<MaskedTextFieldState> _maskedCountryCodeKey = GlobalKey<MaskedTextFieldState>();

  // Controllers
  TextEditingController smsCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController countryCodeController = TextEditingController();

  // Variables
  String _errorMessage1;
  String _errorMessage2;
  String _verificationId;
  Timer _codeTimer;

  bool _isRefreshing = false;
  bool _codeTimedOut = false;
  bool _codeVerified = false;
  Duration _timeOut = const Duration(minutes: 1);

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // GoogleSignInAccount _googleUser;

  // PhoneVerificationCompleted
  verificationCompleted(FirebaseUser user) async {
    Logger.log(TAG, message: "onVerificationCompleted, user: $user");
    if (await _onCodeVerified(user)) {
      await _finishSignIn(user);
    } else {
      setState(() {
        this.status = AuthStatus.SMS_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    }
  }

  // PhoneVerificationFailed
  verificationFailed(AuthException authException) {
    _showErrorSnackbar(
        "We couldn't verify your code for now, please try again!");
    Logger.log(TAG,
        message:
            'onVerificationFailed, code: ${authException.code}, message: ${authException.message}');
  }

  // PhoneCodeSent
  codeSent(String verificationId, [int forceResendingToken]) async {
    Logger.log(TAG,
        message:
            "Verification code sent to number +${countryCodeController.text} ${phoneNumberController.text}");
    _codeTimer = Timer(_timeOut, () {
      setState(() {
        _codeTimedOut = true;
      });
    });
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this.status = AuthStatus.SMS_AUTH;
      Logger.log(TAG, message: "Changed status to $status");
    });
  }

  // PhoneCodeAutoRetrievalTimeout
  codeAutoRetrievalTimeout(String verificationId) {
    Logger.log(TAG, message: "onCodeTimeout");
    _updateRefreshing(false);
    setState(() {
      this._verificationId = verificationId;
      this._codeTimedOut = true;
    });
  }

  // Styling
  final decorationStyle = TextStyle(color: Colors.grey[50], fontSize: 22.0);
  final hintStyle = TextStyle(color: Colors.white24);

  //

  @override
  void dispose() {
    _codeTimer?.cancel();
    super.dispose();
  }

  // async
  Future<Null> _updateRefreshing(bool isRefreshing) async {
    Logger.log(TAG,
        message: "Setting _isRefreshing ($_isRefreshing) to $isRefreshing");
    if (_isRefreshing) {
      setState(() {
        this._isRefreshing = false;
      });
    }
    setState(() {
      this._isRefreshing = isRefreshing;
    });
  }

  _showErrorSnackbar(String message) {
    _updateRefreshing(false);
    _scaffoldKey1.currentState.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<Null> _signIn() async {
  //   GoogleSignInAccount user = _googleSignIn.currentUser;
  //   Logger.log(TAG, message: "Just got user as: $user");

  //   if (user == null) {
  //     await _googleSignIn.signIn().then((account) {
  //       user = account;
  //     }, onError: (error) {
  //       _showErrorSnackbar(
  //           "Couldn't log in with your Google account, please try again!");
  //     });
  //   }

  //   if (user != null) {
  //     _updateRefreshing(false);
  //     this._googleUser = user;
  //     setState(() {
  //       this.status = AuthStatus.PHONE_AUTH;
  //       Logger.log(TAG, message: "Changed status to $status");
  //     });
  //     return null;
  //   }
  //   return null;
  // }

  Future<Null> _submitPhoneNumber() async {
    final error1 = _countryCodeValidator();
    final error2 = _phoneInputValidator();
    if (error1 != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage1 = error1;
        _errorMessage2 = null;
      });
      return null;
    } else if (error2 != null) {
      _updateRefreshing(false);
      setState(() {
        _errorMessage2 = error2;
        _errorMessage1 = null;
      });
      return null;
    } else {
      _updateRefreshing(false);
      setState(() {
        _errorMessage1 = null;
        _errorMessage2 = null;
      });
      final result = await _verifyPhoneNumber();
      Logger.log(TAG, message: "Returning $result from _submitPhoneNumber");
      return result;
    }
  }

  String get phoneNumber {
    String unmaskedNumber = _maskedPhoneKey.currentState.unmaskedText;
    String unmaskedCountryCode = _maskedCountryCodeKey.currentState.unmaskedText;
    String formatted = "+$unmaskedCountryCode$unmaskedNumber".trim();
    return formatted;
  }

  Future<Null> _verifyPhoneNumber() async {
    Logger.log(TAG, message: "Got phone number as: ${this.phoneNumber}");
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNumber,
        timeout: _timeOut,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed);
    Logger.log(TAG, message: "Returning null from _verifyPhoneNumber");
    return null;
  }

  Future<Null> _submitSmsCode() async {
    final error = _smsInputValidator();
    if (error != null) {
      _updateRefreshing(false);
      _showErrorSnackbar(error);
      return null;
    } else {
      if (this._codeVerified) {
        await _finishSignIn(await _auth.currentUser());
      } else {
        Logger.log(TAG, message: "_signInWithPhoneNumber called");
        await _signInWithPhoneNumber();
      }
      return null;
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    final errorMessage = "We couldn't verify your code, please try again!";
    await _auth
        .signInWithPhoneNumber(
            verificationId: _verificationId, smsCode: smsCodeController.text)
        .then((user) async {
      await _onCodeVerified(user).then((codeVerified) async {
        this._codeVerified = codeVerified;
        Logger.log(
          TAG,
          message: "Returning ${this._codeVerified} from _onCodeVerified",
        );

        if (this._codeVerified) {
          await _finishSignIn(user);
        } else {
          _showErrorSnackbar(errorMessage);
        }
      });
    }, onError: (error) {
      print("Failed to verify SMS code: $error");
      _showErrorSnackbar(errorMessage);
    });
  }

  Future<bool> _onCodeVerified(FirebaseUser user) async {
    final isUserValid = (user != null &&
        (user.phoneNumber != null && user.phoneNumber.isNotEmpty));
    if (isUserValid) {
      setState(() {
        // Here we change the status once more to guarantee that the SMS's
        // text input isn't available while you do any other request
        // with the gathered data
        this.status = AuthStatus.PROFILE_AUTH;
        Logger.log(TAG, message: "Changed status to $status");
      });
    } else {
      _showErrorSnackbar("We couldn't verify your code, please try again!");
    }
    return isUserValid;
  }

  _finishSignIn(FirebaseUser user) async {
    var userRef = Firestore.instance.collection('Users').document(user.uid);
    globals.userState['loginStatus'] = 'loggingIn';
    userRef.get().then((userResult) {
      if (userResult.data != null) {
        // Existing User
        globals.userState['loginStatus'] = 'loggedIn';
        globals.userState['userId'] = user.uid;
        globals.userState['profilePic'] = userResult.data['profilePic'];
        globals.userState['requests'] = userResult.data['requests'].toString();
        globals.userState['name'] = userResult.data['name'];
        Navigator.pop(context);
      } 
      else {
        //New User
        var randomName = 'Anon' + Random().nextInt(999).toString();
        var randomProfilePic = 'assets/images/Unicorn' + (Random().nextInt(12) + 1).toString() + '.png';
        var data = {'name': randomName, 'profilePic': randomProfilePic};
        userRef.setData(data).then((onValue) {
          globals.userState['loginStatus'] = 'loggedIn';
          globals.userState['userId'] = user.uid;
          globals.userState['name'] = randomName;
          globals.userState['profilePic'] = randomProfilePic;
          Navigator.pop(context);
        });
      }
    });
    // await _onCodeVerified(user).then((result) {
      // if (result) {
        // Here, instead of navigating to another screen, you should do whatever you want
        // as the user is already verified with Firebase from both
        // Google and phone number methods
        // Example: authenticate with your own API, use the data gathered
        // to post your profile/user, etc.

        // Navigator.of(context).pushReplacement(CupertinoPageRoute(
        //       builder: (context) => MainScreen(
        //             googleUser: _googleUser,
        //             firebaseUser: user,
        //           ),
        //     ));
      // } else {
        // setState(() {
        //   this.status = AuthStatus.SMS_AUTH;
        // });
      //   _showErrorSnackbar(
      //       "We couldn't create your profile for now, please try again later");
      // }
    // });
  }

  // Widgets

  // Widget _buildSocialLoginBody() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         SizedBox(height: 24.0),
  //         GoogleSignInButton(
  //           onPressed: () => _updateRefreshing(true),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildConfirmInputButton() {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(Icons.check),
      color: theme.accentColor,
      disabledColor: theme.buttonColor,
      onPressed: (this.status == AuthStatus.PROFILE_AUTH)
          ? null
          : () => _updateRefreshing(true),
    );
  }


  Widget _buildCountryCodeInput() {
    return MaskedTextField(
      key: _maskedCountryCodeKey,
      mask: "+xx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: countryCodeController,
      maxLength: 3,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme
          .of(context)
          .textTheme
          .subhead
          .copyWith(fontSize: 22.0, color: Colors.white),
      inputDecoration: InputDecoration(
        isDense: false,
        enabled: this.status == AuthStatus.PHONE_AUTH,
        counterText: "",
        // icon: const Icon(
        //   Icons.phone,
        //   color: Colors.white,
        // ),
        labelText: "Country",
        labelStyle: decorationStyle,
        hintText: "+1",
        hintStyle: hintStyle,
        errorText: _errorMessage1
      ),
    );
  }

  Widget _buildPhoneNumberInput() {
    return MaskedTextField(
      key: _maskedPhoneKey,
      mask: "(xxx) xxx-xxxx",
      keyboardType: TextInputType.number,
      maskedTextFieldController: phoneNumberController,
      maxLength: 15,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme
          .of(context)
          .textTheme
          .subhead
          .copyWith(fontSize: 22.0, color: Colors.white),
      inputDecoration: InputDecoration(
        isDense: false,
        enabled: this.status == AuthStatus.PHONE_AUTH,
        counterText: "",
        labelText: "Phone",
        labelStyle: decorationStyle,
        hintText: "(555) 555-5555",
        hintStyle: hintStyle,
        errorText: _errorMessage2
      ),
    );
  }

  Widget _buildPhoneAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Padding(padding: EdgeInsets.only(top: 200.0)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
          child: Text(
            "We'll send an SMS message to verify your identity, please enter your number below!",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 2, child: Padding(padding: EdgeInsets.only(right: 10.0), child: _buildCountryCodeInput())),
              Flexible(flex: 4, child: _buildPhoneNumberInput()),
              Flexible(flex: 1, child: _buildConfirmInputButton())
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCodeInput() {
    final enabled = this.status == AuthStatus.SMS_AUTH;
    return TextField(
      keyboardType: TextInputType.number,
      enabled: enabled,
      textAlign: TextAlign.center,
      controller: smsCodeController,
      maxLength: 6,
      onSubmitted: (text) => _updateRefreshing(true),
      style: Theme.of(context).textTheme.subhead.copyWith(
            fontSize: 32.0,
            color: enabled ? Colors.white : Theme.of(context).buttonColor,
          ),
      decoration: InputDecoration(
        counterText: "",
        enabled: enabled,
        hintText: "--- ---",
        hintStyle: hintStyle.copyWith(fontSize: 42.0),
      ),
    );
  }

  Widget _buildResendSmsWidget() {
    return InkWell(
      onTap: () async {
        if (_codeTimedOut) {
          await _verifyPhoneNumber();
        } else {
          _showErrorSnackbar("You can't retry yet!");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "If your code does not arrive in 1 minute, touch",
            style: decorationStyle,
            children: <TextSpan>[
              TextSpan(
                text: " here",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmsAuthBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            "Verification code",
            style: decorationStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 64.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(flex: 5, child: _buildSmsCodeInput()),
              Flexible(flex: 2, child: _buildConfirmInputButton())
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _buildResendSmsWidget(),
        )
      ],
    );
  }

  String _phoneInputValidator() {
    if (phoneNumberController.text.isEmpty) {
      return "Your phone number can't be empty!";
    } else if (phoneNumberController.text.length < 10) {
      return "This phone number is invalid!";
    }
    return null;
  }

  String _countryCodeValidator() {
    if (countryCodeController.text.isEmpty) {
      return "Can't be empty!";
    } else if (countryCodeController.text.length < 2) {
      return "Can't be empty!";
    }
    return null;
  }

  String _smsInputValidator() {
    if (smsCodeController.text.isEmpty) {
      return "Your verification code can't be empty!";
    } else if (smsCodeController.text.length < 6) {
      return "This verification code is invalid!";
    }
    return null;
  }

  Widget _buildBody() {
    Widget body;
    switch (this.status) {
      case AuthStatus.SOCIAL_AUTH:
        // body = _buildSocialLoginBody();
        break;
      case AuthStatus.PHONE_AUTH:
        body = _buildPhoneAuthBody();
        break;
      case AuthStatus.SMS_AUTH:
      case AuthStatus.PROFILE_AUTH:
        body = _buildSmsAuthBody();
        break;
    }
    return body;
  }

  Future<Null> _onRefresh() async {
    switch (this.status) {
      case AuthStatus.SOCIAL_AUTH:
        // return await _signIn();
        break;
      case AuthStatus.PHONE_AUTH:
        return await _submitPhoneNumber();
        break;
      case AuthStatus.SMS_AUTH:
        return await _submitSmsCode();
        break;
      case AuthStatus.PROFILE_AUTH:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey1,
      appBar: new AppBar(
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: const Color(0xFF00073F),
				elevation: -1.0,
				title: new Text(
					"Log in",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30.0, letterSpacing: 1.5),
				)),
      // backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
					image: DecorationImage(
					image: AssetImage("assets/images/splash_bg.png"),
					fit: BoxFit.cover,
				)),
        child: ReactiveRefreshIndicator(
          onRefresh: _onRefresh,
          isRefreshing: _isRefreshing,
          child: Container(child: _buildBody()),
        ),
      ),
    );
  }
}