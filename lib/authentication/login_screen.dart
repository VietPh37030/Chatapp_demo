import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:chatapp_firebase/utilities/assets_manager.dart';
import 'package:country_picker/country_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: '26',
    countryCode: 'ZM',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Zambia',
    example: 'Zambia',
    displayName: 'Zambia',
    displayNameNoCountryCode: 'ZM',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset(AssetsManager.chatBubble),
              ),
              Text(
                "Flutter chat Demo",
                style: GoogleFonts.openSans(
                    fontSize: 28, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              Text(
                "Thêm số điện thoại của bạn, chúng tôi sẽ gửi mã xác minh cho bạn",
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  counterText: '',
                  hintText: "Phone Number",
                  hintStyle: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            bottomSheetHeight: 600,
                            textStyle: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onSelect: (value) {
                            setState(() {
                              selectedCountry = value;
                            });
                          },
                        );
                      },
                      child: Text(
                        ' ${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}',
                        style: GoogleFonts.openSans(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  suffixIcon: _phoneNumberController.text.length > 9
                      ? authProvider.isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                      : InkWell(
                    onTap: () {
                      authProvider.signInWithPhoneNumber(
                        phoneNumber:
                        '+${selectedCountry.phoneCode}${_phoneNumberController.text}',
                        context: context,
                      );
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.done,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
