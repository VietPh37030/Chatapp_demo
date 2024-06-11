import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  'Xác minh',
                  style: GoogleFonts.openSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'Nhập mã 6 chữ số được gửi tới số điện thoại',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  phoneNumber,
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 68,
                  child: Pinput(
                    length: 6,
                    controller: controller,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    onCompleted: (pin) {
                      setState(() {
                        otpCode = pin;
                      });
                      verifyOTPCode(
                        verificationId: verificationId,
                        otpCode: otpCode!,
                      );
                    },
                    focusedPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.deepPurple),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyWith(
                      height: 68,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
                authProvider.isSuccessful
                    ? Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.done,
                    color: Colors.white,
                    size: 30,
                  ),
                )
                    : const SizedBox.shrink(),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : Text(
                  ' Bạn không nhận được mã?',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
                const SizedBox(height: 10),
                authProvider.isLoading
                    ? const SizedBox.shrink()
                    : TextButton(
                  onPressed: () {
                    authProvider.signInWithPhoneNumber(
                      phoneNumber: phoneNumber,
                      context: context,
                    );
                  },
                  child: Text(
                    'Gửi lại mã ngay',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        bool userExists = await authProvider.checkUserExists();
        if (userExists) {
          await authProvider.getUserDataFromFireStore();
          await authProvider.saveUserDataToSharedPreferences();
          navigate(userExists: true);
        } else {
          navigate(userExists: false);
        }
      },
    );
  }

  void navigate({required bool userExists}) {
    if (userExists) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
            (route) => false,
      );
    } else {
      Navigator.pushNamed(context, Constants.userInformationScreen);
    }
  }
}
