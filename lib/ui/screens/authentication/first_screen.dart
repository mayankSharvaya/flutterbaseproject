import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soleoserp/blocs/other/firstscreen/first_screen_bloc.dart';
import 'package:soleoserp/models/api_requests/constant_master/constant_request.dart';
import 'package:soleoserp/models/api_requests/login/login_user_details_api_request.dart';
import 'package:soleoserp/models/api_responses/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_responses/customer/customer_source_response.dart';
import 'package:soleoserp/models/api_responses/login/login_user_details_api_response.dart';
import 'package:soleoserp/models/api_responses/other/designation_list_response.dart';
import 'package:soleoserp/models/common/globals.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/res/dimen_resources.dart';
import 'package:soleoserp/ui/res/image_resources.dart';
import 'package:soleoserp/ui/screens/authentication/serial_key_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';

class FirstScreen extends BaseStatefulWidget {
  static const routeName = '/firstScreen';

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends BaseState<FirstScreen>
    with BasicScreen, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  FirstScreenBloc _firstScreenBloc;
  final double _minValue = 8.0;

/*  final TextEditingController edt_User_Name = TextEditingController();

   final TextEditingController edt_User_Password = TextEditingController();*/

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  CompanyDetailsResponse _offlineCompanyData;
  CustomerSourceResponse _offlineCustomerSourceData;
  DesignationApiResponse _offlineCustomerDesignationData;
  LoginUserDetialsResponse _offlineLoggedInDetailsData;
  String InvalidUserMessage = "";
  bool _isObscure = true;
  String SiteUrl = "";

  bool is_dealer = false;
  int _selectedIndex = 0;

  int CompanyID = 0;

  String ConstantMAster = "";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    screenStatusBarColor = colorWhite;
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    _selectedIndex = 0;
    SiteUrl = _offlineCompanyData.details[0].siteURL;
    CompanyID = _offlineCompanyData.details[0].pkId;
    _firstScreenBloc = FirstScreenBloc(baseBloc);

    print("URLLLL:" + SiteUrl + "/images/companylogo/CompanyLogo.png");

    _firstScreenBloc.add(ConstantRequestEvent(
        CompanyID.toString(),
        ConstantRequest(
            ConstantHead: "DMSSystem", CompanyId: CompanyID.toString())));
  }

  ///listener to multiple states of bloc to handles api responses
  ///use only BlocListener if only need to listen to events
/*
  @override
  Widget build(BuildContext context) {
    return BlocListener<FirstScreenBloc, FirstScreenStates>(
      bloc: _authenticationBloc,
      listener: (BuildContext context, FirstScreenStates state) {
        if (state is FirstScreenResponseState) {
          _onFirstScreenCallSuccess(state.response);
        }
      },
      child: super.build(context),
    );
  }
*/

  ///listener and builder to multiple states of bloc to handles api responses
  ///use BlocProvider if need to listen and build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _firstScreenBloc
        ..add(ConstantRequestEvent(
            CompanyID.toString(),
            ConstantRequest(
                ConstantHead: "DMSSystem", CompanyId: CompanyID.toString()))),
      child: BlocConsumer<FirstScreenBloc, FirstScreenStates>(
        builder: (BuildContext context, FirstScreenStates state) {
          //handle states

          if (state is ConstantResponseState) {
            _onGetDMSConstant(state);
          }
          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called

          if (currentState is ConstantResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, FirstScreenStates state) {
          //handle states
          if (state is LoginUserDetialsCallEventResponseState) {
            _onLoginCallSuccess(state.response);
          }

          return super.build(context);
        },
        listenWhen: (oldState, currentState) {
          //return true for state for which listener method should be called
          if (currentState is LoginUserDetialsCallEventResponseState) {
            return true;
          }
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    /*edt_User_Name.text = "admin";
    edt_User_Password.text = "admin!@#";*/

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _firstScreenBloc.add(ConstantRequestEvent(
              CompanyID.toString(),
              ConstantRequest(
                  ConstantHead: "DMSSystem", CompanyId: CompanyID.toString())));
        },
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
                right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
                top: 50,
                bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstantMAster == "yes"
                    ? _buildDealerTopView()
                    : _buildTopView(),
                SizedBox(height: 20),
                _buildDelaerLoginForm(),
              ],
            ),
          ),
        ),
      ),

      /*     buildBottomNavigationBar(context, indexCount: _selectedIndex,
                ontaptoCount: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        })*/
    );
    /*Scaffold(
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
                    right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN,
                    top: 50,
                    bottom: 50),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopView(),
                        SizedBox(height: 50),
                        _buildLoginForm()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );*/
  }

  ///navigates to homescreen
/*  _onTapOfLogin() {
    if(edt_User_Name.text !="")
      {
        if(edt_User_Password !="")
          {
            _firstScreenBloc
                .add(LoginUserDetailsCallEvent(LoginUserDetialsAPIRequest(userID: edt_User_Name.text.toString(),password: edt_User_Password.text.toString(),companyId: _offlineLoggedInData.pkId)));
          }
        else
          {
            DialogUtils.showCustomDialog(context,title: "Alert",details: "Enter Valid Password");
          }
      }
    else{
      DialogUtils.showCustomDialog(context,title: "Alert",details: "Enter Valid UserName");

    }

  }*/

  /* _onLoginCallSuccess(LoginApiResponse response) {
    SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_LOGGED_IN_BOOL, true);
    SharedPrefHelper.instance.setLoginData(response);
    //edt_User_Name.text = response.companyName.toString();
   // navigateTo(context, HomeScreen.routeName, clearAllStack: true);
  }*/

  _onLoginCallSuccess(LoginUserDetialsResponse response) {
    if (response.details.length != 0) {
      if (response.details[0].activeFlagDesc != "Inactive") {
        SharedPrefHelper.instance
            .putBool(SharedPrefHelper.IS_LOGGED_IN_DATA, true);
        SharedPrefHelper.instance.setLoginUserData(response);
        _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
        _offlineLoggedInDetailsData =
            SharedPrefHelper.instance.getLoginUserData();
        print("LoginAuthenticateSucess123" +
            "CompanyID : " +
            _offlineCompanyData.details[0].pkId.toString() +
            "LoginUserID : " +
            _offlineLoggedInDetailsData.details[0].userID);

        //navigateTo(context, Mayank_Dashboard.routeName, clearAllStack: true);
      } else {
        // fdffdsf

        showCommonDialogWithSingleOption(Globals.context, "User Is InActive",
            positiveButtonTitle: "OK", onTapOfPositiveButton: () {
          //navigateTo(context, HomeScreen.routeName, clearAllStack: true);

          _userNameController.text = "";
          _passwordController.text = "";

          Navigator.pop(context);
        });
      }
    }
  }

  /*_onCompanyDetailsCallSucess(CompanyDetailsResponse response) {
    // SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_LOGGED_IN_USER_DATA, true);


    SharedPrefHelper.instance.setCompanyData(response);
    _offlineLoggedInData = SharedPrefHelper.instance.getCompanyData();

    print(
        "Company Details : " + response.details[0].companyName.toString() + "");

  }
*/

  Widget _buildTopView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Image.asset(
          IMG_HEADER_LOGO,
          width: MediaQuery.of(context).size.width / 1.5,
          fit: BoxFit.fitWidth,
        ),*/

        Container(
          width: 200.0,
          height: 100.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
                child: Center(
              child: Image.network(
                  SiteUrl + "/images/companylogo/CompanyLogo.png"),
            )),
          ),
        ),

        /* FittedBox(
            child: Image.network(
                SiteUrl + "/images/companylogo/CompanyLogo.png",
                width: 100,
                height: 150,
                fit: BoxFit.) //values(BoxFit.fitHeight,BoxFit.fitWidth)),
            ),*/
        SizedBox(
          height: 40,
        ),
        /* Text(
          "Login",
          style: baseTheme.textTheme.headline1,
        ),*/
        Text(
          "Login",
          style: TextStyle(
            color: colorPrimary,
            fontSize: 48,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Log in to your existant account",
          style: TextStyle(
            color: Color(0xff019ee9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildDealerTopView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* Image.asset(
          IMG_HEADER_LOGO,
          width: MediaQuery.of(context).size.width / 1.5,
          fit: BoxFit.fitWidth,
        ),*/

        Container(
          width: 200.0,
          height: 100.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
                child: Center(
              child: Image.network(
                  SiteUrl + "/images/companylogo/CompanyLogo.png"),
            )),
          ),
        ),

        /* FittedBox(
            child: Image.network(
                SiteUrl + "/images/companylogo/CompanyLogo.png",
                width: 100,
                height: 150,
                fit: BoxFit.) //values(BoxFit.fitHeight,BoxFit.fitWidth)),
            ),*/
        SizedBox(
          height: 20,
        ),
        /* Text(
          "Login",
          style: baseTheme.textTheme.headline1,
        ),*/

        Container(
            // margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                child: new BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home,
                            color: Color(0xff958dd5),
                            size: 35,
                          ),
                          activeIcon: Icon(
                            Icons.home,
                            color: colorPrimary,
                            size: 35,
                          ),
                          label: 'Company',
                          backgroundColor: colorPrimary),
                      BottomNavigationBarItem(
                          icon: ImageIcon(
                            AssetImage(DEALER_LOGO),
                            color: Color(0xff958dd5),
                            size: 42,
                          ),
                          activeIcon: ImageIcon(
                            AssetImage(DEALER_LOGO),
                            color: colorPrimary,
                            size: 42,
                          ),
                          label: 'Dealer',
                          backgroundColor: colorBlack),
                    ],
                    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                    showUnselectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _selectedIndex,
                    selectedItemColor: colorPrimary,
                    iconSize: 32,
                    onTap: _onItemTapped,
                    elevation: 5))),
        SizedBox(
          height: 30,
        ),
        Text(
          _selectedIndex == 0 ? "Company " : "Dealer ",
          style: TextStyle(
            color: Color(0xff3a3285),
            //color: _selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown,
            fontSize: 40,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Log in to your existant account",
          style: TextStyle(
            color: Color(
                0xff019ee9), //_selectedIndex == 0 ? Color(0xff019ee9) : Colors.brown[300],
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildDelaerLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          getCommonTextFormField(context, baseTheme,
              title: "Username",
              hint: "enter username",
              //labelColor: _selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown,
              keyboardType: TextInputType.emailAddress,
              // titleTextStyle: TextStyle(color: Colors.brown),
              suffixIcon: ImageIcon(
                Image.asset(
                  IC_USERNAME,
                  color: colorPrimary,
                  width: 10,
                  height: 10,
                ).image,
              ),
              controller: _userNameController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 25,
          ),
          getCommonTextFormField(context, baseTheme,
              title: "Password",
              hint: "enter password",
              obscureText: _isObscure,
              // labelColor: _selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown,
              textInputAction: TextInputAction.done,
              suffixIcon: /*ImageIcon(
                Image.asset(
                  IC_PASSWORD,
                  color: colorPrimary,
                  width: 10,
                  height: 10,
                ).image,
              ),*/
                  IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              controller: _passwordController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 52,
          ),
          /*Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                _onTapOfForgetPassword();
              },
              child: Text(
                "Forget Password?",
                style: baseTheme.textTheme.headline2,
              ),
            ),
          ),*/
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: getCommonButton(baseTheme, () {
                  _onTapOfLogin();
                }, "Login",
                    radius: 15,
                    backGroundColor:
                        colorPrimary /*_selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown*/),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: getCommonButton(baseTheme, () async {
                  _onTapOfRegister();
                }, "LogOut",
                    radius: 15,
                    backGroundColor:
                        colorPrimary /*_selectedIndex == 0 ? Color(0xff3a3285) : Colors.brown*/),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          getCommonTextFormField(context, baseTheme,
              title: "Username",
              hint: "enter username",
              keyboardType: TextInputType.emailAddress,
              suffixIcon: ImageIcon(
                Image.asset(
                  IC_USERNAME,
                  color: colorPrimary,
                  width: 10,
                  height: 10,
                ).image,
              ),
              controller: _userNameController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 25,
          ),
          getCommonTextFormField(context, baseTheme,
              title: "Password",
              hint: "enter password",
              obscureText: _isObscure,
              textInputAction: TextInputAction.done,
              suffixIcon: /*ImageIcon(
                Image.asset(
                  IC_PASSWORD,
                  color: colorPrimary,
                  width: 10,
                  height: 10,
                ).image,
              ),*/
                  IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              controller: _passwordController, validator: (value) {
            if (value.toString().trim().isEmpty) {
              return "Please enter this field";
            }
            return null;
          }),
          SizedBox(
            height: 35,
          ),
          /*Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                _onTapOfForgetPassword();
              },
              child: Text(
                "Forget Password?",
                style: baseTheme.textTheme.headline2,
              ),
            ),
          ),*/
          SizedBox(
            height: 45,
          ),
          getCommonButton(baseTheme, () {
            _onTapOfLogin();
          }, "Login"),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
          ),
          getCommonButton(baseTheme, () async {
            _onTapOfRegister();
          }, "LogOut"),
          /* Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Do You want to Visit Registration Page?",
                style: baseTheme.textTheme.caption,
              ),
              SizedBox(
                width: 2,
              ),
              InkWell(
                onTap: () {
                  _onTapOfRegister();
                },
                child: Text(
                  "Tap here",
                  style: baseTheme.textTheme.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          )*/
        ],
      ),
    );
  }

  void _onTapOfForgetPassword() {
    //TODO
  }

  void _onTapOfLogin() {
    if (_formKey.currentState.validate()) {
      SharedPrefHelper.instance.prefs
          .setString("Is_Dealer", _selectedIndex == 0 ? "Company" : "Dealer");

      _firstScreenBloc.add(LoginUserDetailsCallEvent(LoginUserDetialsAPIRequest(
          userID: _userNameController.text.toString(),
          password: _passwordController.text.toString(),
          companyId: _offlineCompanyData.details[0].pkId)));
    }
    //TODO
  }

  void _onTapOfSignInWithGoogle() {
    //TODO
  }

  void _onTapOfRegister() {
    SharedPrefHelper.instance.putBool(SharedPrefHelper.IS_REGISTERED, false);
    navigateTo(context, SerialKeyScreen.routeName, clearAllStack: true);
    // navigateTo(context, RegisterScreen.routeName, clearAllStack: true);
  }

  void _onGetDMSConstant(ConstantResponseState state) {
    print("ConstantValue" + state.response.details[0].value.toString());

    ConstantMAster = state.response.details[0].value.toString();
  }
}
