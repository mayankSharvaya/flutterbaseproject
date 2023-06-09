import 'dart:collection';
import 'dart:convert';
import 'dart:io' show Directory, File, Platform, exit;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_shine/flutter_shine.dart';
import 'package:geolocator/geolocator.dart'
    as geolocator; // or whatever name you want
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:ntp/ntp.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soleoserp/blocs/other/bloc_modules/dashboard/dashboard_user_rights_screen_bloc.dart';
import 'package:soleoserp/models/api_requests/api_token/api_token_update_request.dart';
import 'package:soleoserp/models/api_requests/attendance/attendance_list_request.dart';
import 'package:soleoserp/models/api_requests/attendance/punch_attendence_save_request.dart';
import 'package:soleoserp/models/api_requests/attendance/punch_without_image_request.dart';
import 'package:soleoserp/models/api_requests/constant_master/constant_request.dart';
import 'package:soleoserp/models/api_requests/other/all_employee_list_request.dart';
import 'package:soleoserp/models/api_requests/other/follower_employee_list_request.dart';
import 'package:soleoserp/models/api_requests/other/menu_rights_request.dart';
import 'package:soleoserp/models/api_responses/company_details/company_details_response.dart';
import 'package:soleoserp/models/api_responses/login/login_user_details_api_response.dart';
import 'package:soleoserp/models/api_responses/other/all_employee_List_response.dart';
import 'package:soleoserp/models/api_responses/other/follower_employee_list_response.dart';
import 'package:soleoserp/models/api_responses/other/menu_rights_response.dart';
import 'package:soleoserp/models/common/all_name_id_list.dart';
import 'package:soleoserp/models/common/globals.dart';
import 'package:soleoserp/ui/res/color_resources.dart';
import 'package:soleoserp/ui/res/dimen_resources.dart';
import 'package:soleoserp/ui/res/image_resources.dart';
import 'package:soleoserp/ui/screens/authentication/first_screen.dart';
import 'package:soleoserp/ui/screens/base/base_screen.dart';
import 'package:soleoserp/ui/widgets/common_widgets.dart';
import 'package:soleoserp/utils/date_time_extensions.dart';
import 'package:soleoserp/utils/general_utils.dart';
import 'package:soleoserp/utils/image_full_screen.dart';
import 'package:soleoserp/utils/shared_pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

class HomeScreen extends BaseStatefulWidget {
  static const routeName = '/homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen>
    with BasicScreen, WidgetsBindingObserver {
  LoginUserDetialsResponse _offlineLoggedInData;
  CompanyDetailsResponse _offlineCompanyData;
  FollowerEmployeeListResponse _offlineFollowerEmployeeListData;
  ALL_EmployeeList_Response _offlineALLEmployeeListData;
  DashBoardScreenBloc _dashBoardScreenBloc;

  bool isCustomerExist = false;
  bool isInquiryExist = false;
  bool isFollowupExist = false;
  bool isLeaveRequestExist = false;
  bool isLeaveApprovalExist = false;
  bool isAttendanceExist = false;
  bool isExpenseExist = false;
  bool isPunchIn = false;
  bool isPunchOut = false;
  bool isLunchIn = false;
  bool isLunchOut = false;
  bool IsExistInIOS = false;
  bool isLoading = true;
  bool islodding = true;
  bool onWebLoadingStop = false;
  bool isCurrentTime = true;

  List<MenuDetails> array_MenuRightsList;
  List<ALL_Name_ID> arr_ALL_Name_ID_For_HR = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Lead = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Office = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Support = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Purchase = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Production = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Sales = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Account = [];
  List<ALL_Name_ID> arr_ALL_Name_ID_For_Dealer = [];

  List<ALL_Name_ID> arr_UserRightsWithMenuName = [];

  List<String> SplitSTr = [];

  final TextEditingController PuchInTime = TextEditingController();
  final TextEditingController PuchOutTime = TextEditingController();
  final TextEditingController LunchInTime = TextEditingController();
  final TextEditingController LunchOutTime = TextEditingController();
  final TextEditingController ImgFromTextFiled = TextEditingController();

  final TextEditingController PuchInboolcontroller = TextEditingController();
  final TextEditingController PuchOutboolcontroller = TextEditingController();
  final TextEditingController LunchInboolcontroller = TextEditingController();
  final TextEditingController LunchOutboolcontroller = TextEditingController();

  final urlController = TextEditingController();
  TextEditingController EmailTO = TextEditingController();
  TextEditingController EmailBCC = TextEditingController();

  String SiteURL = "";
  String Password = "";
  String LoginUserID = "";
  String MapAPIKey = "";
  String IOSAPPStatus = "";
  String AndroidAppStatus = "";
  String url = "";
  String TitleNAme = "";
  String mid = "Default";
  String EmployeeImage = "https://img.icons8.com/color/2x/no-image.png";
  String EmployeeImageNew = "https://img.icons8.com/color/2x/no-image.png";
  String Address;
  String ISDelaer = "";

  int CompanyID = 0;
  int prgresss = 0;

  double progress = 0;

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  PullToRefreshController pullToRefreshController;
  ContextMenu contextMenu;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  var delay = const Duration(seconds: 3);
  //final FirebaseMessaging _firebaseMessaging;//= FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final Geolocator geolocator123 = Geolocator()..forceAndroidLocationManager;

  File Lunch_In_OUT_File;

  String ConstantMAster = "";

  String LatitudeHome = "23.0115394";
  String LongitudeHome = "72.5235199";

  bool islead = false;
  bool isSale = false;
  bool isAccount = false;
  bool isProduction = false;
  bool isHR = false;
  bool isPurchase = false;
  bool isOffice = false;
  bool isSupport = false;

  final double runSpacing = 4;
  final double spacing = 4;
  final columns = 4;

  @override
  void initState() {
    super.initState();

    PuchInboolcontroller.text = "";
    PuchOutboolcontroller.text = "";
    LunchInboolcontroller.text = "";
    LunchOutboolcontroller.text = "";

    imageCache.clear();
    initPlatformState();
    checkPhotoPermissionStatus();

    ISDelaer = SharedPrefHelper.instance.prefs.getString("Is_Dealer");

    print("dfdfdleif" + ISDelaer);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    getcurrentTimeInfoFromMaindfd();
    screenStatusBarColor = colorWhite;
    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    EmailTO.text = "";
    //normal Notification
    //When App is in Terminated
    _offlineLoggedInData = SharedPrefHelper.instance.getLoginUserData();
    _offlineCompanyData = SharedPrefHelper.instance.getCompanyData();
    CompanyID = _offlineCompanyData.details[0].pkId;
    LoginUserID = _offlineLoggedInData.details[0].userID;
    MapAPIKey = _offlineCompanyData.details[0].MapApiKey;

    print("MapAPIKey" + MapAPIKey);
    IOSAPPStatus = _offlineCompanyData.details[0].IOSApp;
    AndroidAppStatus = _offlineCompanyData.details[0].AndroidApp;
    SiteURL = _offlineCompanyData.details[0].siteURL;
    Password = _offlineLoggedInData.details[0].userPassword;
    print("SiteURL345" +
        " Site URL : " +
        SiteURL +
        " LoginUserID : " +
        LoginUserID +
        " PassWord : " +
        Password);
    ImgFromTextFiled.text = "https://img.icons8.com/color/2x/no-image.png";
    _dashBoardScreenBloc = DashBoardScreenBloc(baseBloc);
    checkPermissionStatus();

    _dashBoardScreenBloc
      ..add(FollowerEmployeeListCallEvent(FollowerEmployeeListRequest(
          CompanyId: CompanyID.toString(), LoginUserID: LoginUserID)));
    _dashBoardScreenBloc
      ..add(ALLEmployeeNameCallEvent(
          ALLEmployeeNameRequest(CompanyId: CompanyID.toString())));

    getLeadListFromDashBoard(arr_ALL_Name_ID_For_Lead);
    getSaleListFromDashBoard(arr_ALL_Name_ID_For_Sales);
    getAccountListFromDashBoard(arr_ALL_Name_ID_For_Account);
    getHRListFromDashBoard(arr_ALL_Name_ID_For_HR);
    getOfficeListFromDashBoard(arr_ALL_Name_ID_For_Office);
    getSupportListFromDashBoard(arr_ALL_Name_ID_For_Support);
    getPurchaseListFromDashBoard(arr_ALL_Name_ID_For_Purchase);
    getProductionListFromDashBoard(arr_ALL_Name_ID_For_Production);
    getDealerListFromDashBoard(arr_ALL_Name_ID_For_Dealer);

    _dashBoardScreenBloc.add(ConstantRequestEvent(
        CompanyID.toString(),
        ConstantRequest(
            ConstantHead: "AttendenceWithImage",
            CompanyId: CompanyID.toString())));
    //ConstantRequestEvent
    _dashBoardScreenBloc.add(AttendanceCallEvent(AttendanceApiRequest(
        pkID: "",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        Month: selectedDate.month.toString(),
        Year: selectedDate.year.toString(),
        CompanyId: CompanyID.toString(),
        LoginUserID: LoginUserID)));

    if (_offlineLoggedInData.details[0].EmployeeImage != "" ||
        _offlineLoggedInData.details[0].EmployeeImage != null) {
      setState(() {
        ImgFromTextFiled.text = _offlineCompanyData.details[0].siteURL +
            _offlineLoggedInData.details[0].EmployeeImage.toString();
      });
    } else {
      ImgFromTextFiled.text = "https://img.icons8.com/color/2x/no-image.png";
    }

    getDetailsOfImage(
        "https://img.icons8.com/color/2x/no-image.png", "demo.png");

    PuchInboolcontroller.addListener(timeChangesEvent);
    PuchOutboolcontroller.addListener(timeChangesEvent);
    LunchInboolcontroller.addListener(timeChangesEvent);
    LunchOutboolcontroller.addListener(timeChangesEvent);
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.

    super.dispose();
    SplitSTr = [];
    PuchInTime.dispose();
    PuchOutTime.dispose();
    ImgFromTextFiled.dispose();
  }

  ///listener and builder to multiple states of bloc to handles api responses
  ///use BlocProvider if need to listen and build
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _dashBoardScreenBloc
        ..add(MenuRightsCallEvent(MenuRightsRequest(
            CompanyID: CompanyID.toString(), LoginUserID: LoginUserID))),
      child: BlocConsumer<DashBoardScreenBloc, DashBoardScreenStates>(
        builder: (BuildContext context, DashBoardScreenStates state) {
          //handle states

          if (state is APITokenUpdateState) {
            _OnTokenUpdateResponse(state);
          }
          if (state is MenuRightsEventResponseState) {
            _onDashBoardCallSuccess(state, context);
          }

          if (state is FollowerEmployeeListByStatusCallResponseState) {
            _onFollowerEmployeeListByStatusCallSuccess(state);
          }

          if (state is ALL_EmployeeNameListResponseState) {
            _onALLEmployeeListByStatusCallSuccess(state);
          }

          if (state is AttendanceListCallResponseState) {
            _OnAttendanceListResponse(state);
          }
          if (state is EmployeeListResponseState) {
            _OnFethEmployeeImage(state);
          }

          if (state is ConstantResponseState) {
            _onGetConstant(state);
          }
          return super.build(context);
        },
        buildWhen: (oldState, currentState) {
          //return true for state for which builder method should be called

          if (currentState is APITokenUpdateState ||
              currentState is MenuRightsEventResponseState ||
              currentState is FollowerEmployeeListByStatusCallResponseState ||
              currentState is ALL_EmployeeNameListResponseState ||
              currentState is AttendanceListCallResponseState ||
              currentState is EmployeeListResponseState ||
              currentState is ConstantResponseState) {
            return true;
          }
          return false;
        },
        listener: (BuildContext context, DashBoardScreenStates state) {
          if (state is PunchAttendenceSaveResponseState) {
            _onPunchAttandanceSaveResponse(state);
          }

          if (state is AttendanceSaveCallResponseState) {
            _onAttandanceSaveResponse(state);
          }

          if (state is PunchOutWebMethodState) {
            _OnwebSucessResponse(state);
          }

          if (state is PunchWithoutAttendenceSaveResponseState) {
            _OnPunchOutWithoutImageSucess(state);
          }
          //handle states
        },
        listenWhen: (oldState, currentState) {
          if (currentState is AttendanceSaveCallResponseState ||
              currentState is PunchOutWebMethodState ||
              currentState is PunchAttendenceSaveResponseState ||
              currentState is PunchWithoutAttendenceSaveResponseState) {
            return true;
          }
          //return true for state for which listener method should be called
          return false;
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context123) {
    //getcurrentTimeInfoFromMain(context123);
    final w = (MediaQuery.of(context).size.width - runSpacing * (4 - 1)) / 4;

    print("FromScreen" + ConstantMAster.toString());
    if (Platform.isAndroid) {
      // Android-specific code

      // IsExistInIOS = true;
      if (AndroidAppStatus == "Active") {
        IsExistInIOS = true;
      } else {
        IsExistInIOS = false;
      }
      print("ISIOS" + "Android-specific code");
    } else if (Platform.isIOS) {
      // iOS-specific code

      if (IOSAPPStatus == "Active") {
        IsExistInIOS = true;
      } else {
        IsExistInIOS = false;
      }
      print("ISIOS" + "iOS-specific code");
    }

    return IsExistInIOS == true
        ? Scaffold(
            backgroundColor: colorGray,
            appBar: AppBar(
              leading: Builder(
                builder: (context) => Container(
                  margin: EdgeInsets.only(top: 14, left: 10),
                  child: IconButton(
                    iconSize: 35,
                    icon: Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              title: Container(
                margin: EdgeInsets.only(top: 20),
                child: FlutterShine(
                  light: Light(intensity: 1, position: Point(5, 5)),
                  builder: (BuildContext context, ShineShadow shineShadow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          "DashBoard",
                          style: TextStyle(
                            color: colorPrimary,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              backgroundColor: colorVeryLightGray,
              foregroundColor: colorPrimary,
              elevation: 0,
              primary: false,
              actions: <Widget>[
                GestureDetector(
                  onTap: () {
                    UserProfileDialog(context1: context123);
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Icon(
                      Icons.person_pin_rounded,
                      size: 30,
                      color: colorPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          bool isChecked = false;
                          // timeChangesEvent();

                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.0))),
                            title: Column(
                              children: [
                                Text(
                                  "Daily Operations",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimary),
                                ),
                                Divider(
                                  thickness: 2,
                                ),
                              ],
                            ),
                            content: Container(
                              height: 450,
                              width: double.infinity,
                            ),
                            actions: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(5),
                                  child: /*getCommonButton(baseTheme, () {
                                    Navigator.pop(context);
                                  }, "Close"),*/
                                      Column(
                                    children: [
                                      Divider(
                                        thickness: 2,
                                      ),
                                      getCommonButton(baseTheme, () {
                                        Navigator.pop(context);
                                      }, "Close", radius: 25.0),
                                      /*Text(
                                        "Close",
                                        style: TextStyle(
                                            color: colorPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),*/
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        });
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Icon(
                      Icons.watch_later,
                      size: 30,
                      color: colorPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    SharedPrefHelper.instance.prefs.setString("Is_Dealer", "");
                    _onTapOfLogOut();
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20, right: 20),
                    child: Icon(
                      Icons.login,
                      size: 30,
                      color: colorPrimary,
                    ),
                  ),
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                checkPermissionStatus();

                checkPhotoPermissionStatus();
                getcurrentTimeInfoFromMaindfd();
                /* _dashBoardScreenBloc..add(EmployeeListCallEvent(
              1,
              EmployeeListRequest(
                CompanyId: CompanyID.toString(),
                OrgCode: "",
                LoginUserID: LoginUserID,)));*/
                _dashBoardScreenBloc.add(AttendanceCallEvent(
                    AttendanceApiRequest(
                        pkID: "",
                        EmployeeID: _offlineLoggedInData.details[0].employeeID
                            .toString(),
                        Month: selectedDate.month.toString(),
                        Year: selectedDate.year.toString(),
                        CompanyId: CompanyID.toString(),
                        LoginUserID: LoginUserID)));
                _dashBoardScreenBloc.add(ConstantRequestEvent(
                    CompanyID.toString(),
                    ConstantRequest(
                        ConstantHead: "AttendenceWithImage",
                        CompanyId: CompanyID.toString())));
                _dashBoardScreenBloc.add(MenuRightsCallEvent(MenuRightsRequest(
                    CompanyID: CompanyID.toString(),
                    LoginUserID: LoginUserID)));
              },
              child: Container(
                color: colorWhite,
                padding: EdgeInsets.only(
                  left: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN2,
                  right: DEFAULT_SCREEN_LEFT_RIGHT_MARGIN2,
                ),
                child: /*ISDelaer == "Dealer"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(
                                  top: 5.0, left: 10, right: 10, bottom: 5),
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5.0,
                                  mainAxisSpacing: 5.0,
                                  childAspectRatio: (200 / 200),

                                  ///200,300
                                ),
                                itemCount: 2,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: makeDashboardItem(
                                        arr_ALL_Name_ID_For_Lead[index].Name,
                                        Icons.person,
                                        context123,
                                        arr_ALL_Name_ID_For_Lead[index].Name1),
                                  );
                                },
                              ))
                        ],
                      )
                    :*/
                    ListView(
                  children: [
                    ///___________________Leads____________________________
                    arr_ALL_Name_ID_For_Lead.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                islead = !islead;

                                isSale = false;
                                isAccount = false;
                                isProduction = false;
                                isHR = false;
                                isPurchase = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_LEAD,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Leads",
                                                style: TextStyle(
                                                    color: colorWhite,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              /*Container(
                                                width: 200,
                                                height: 1,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 5),
                                                color: colorWhite,
                                              ),*/
                                              /*Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text("0",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("Contacts",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("0",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("Followup",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("0",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("Inquiry",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("0",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("Quotation",
                                                          style: TextStyle(
                                                              color: colorWhite,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                ],
                                              )*/
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          islead == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    arr_ALL_Name_ID_For_Lead.length != 0
                        ? Visibility(
                            visible: islead,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Lead.length, (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Lead[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Lead[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    ///___________________Sales______________________________

                    arr_ALL_Name_ID_For_Sales.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isSale = !isSale;

                                islead = false;
                                isAccount = false;
                                isProduction = false;
                                isHR = false;
                                isPurchase = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_SALES,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Sales",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            /*  Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("SalesOrder",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("SalesBill",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isSale == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    arr_ALL_Name_ID_For_Sales.length != 0
                        ? Visibility(
                            visible: isSale,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Sales.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Sales[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Sales[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ))
                        : Container(),

                    ///____________________Production_______________________

                    arr_ALL_Name_ID_For_Production.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isProduction = !isProduction;
                                islead = false;
                                isSale = false;
                                isAccount = false;
                                isHR = false;
                                isPurchase = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_PRODUCTION,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Production",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("Inward",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("OutWord",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Icon(
                                          isProduction == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    arr_ALL_Name_ID_For_Production.length != 0
                        ? Visibility(
                            visible: isProduction,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Production.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Production[
                                                    index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Production[
                                                    index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ))
                        : Container(),

                    ///____________________Account_________________________

                    arr_ALL_Name_ID_For_Account.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isAccount = !isAccount;
                                islead = false;
                                isSale = false;
                                isProduction = false;
                                isHR = false;
                                isPurchase = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_ACCOUNT,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Account",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            /*  Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("voucher",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("journal",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isAccount == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    arr_ALL_Name_ID_For_Account.length != 0
                        ? Visibility(
                            visible: isAccount,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Account.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Account[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Account[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    ///___________________HR_______________________________

                    arr_ALL_Name_ID_For_HR.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isHR = !isHR;
                                islead = false;
                                isSale = false;
                                isAccount = false;
                                isProduction = false;
                                isPurchase = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_HR,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "HR",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            /*Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("Leave",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("MissedPunch",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isHR == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    arr_ALL_Name_ID_For_HR.length != 0
                        ? Visibility(
                            visible: isHR,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_HR.length, (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_HR[index].Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_HR[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ))
                        : Container(),

                    ///__________________Purchase__________________________

                    arr_ALL_Name_ID_For_Purchase.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isPurchase = !isPurchase;
                                islead = false;
                                isSale = false;
                                isAccount = false;
                                isProduction = false;
                                isHR = false;
                                isOffice = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_PURCHASE,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Purchase",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            /* Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("PurchaseOrder",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("PurchaseBill",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isPurchase == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    arr_ALL_Name_ID_For_Purchase.length != 0
                        ? Visibility(
                            visible: isPurchase,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Purchase.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Purchase[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Purchase[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    ///___________________Office____________________________

                    arr_ALL_Name_ID_For_Office.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isOffice = !isOffice;
                                islead = false;
                                isSale = false;
                                isAccount = false;
                                isProduction = false;
                                isHR = false;
                                isPurchase = false;
                                isSupport = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_OFFICE,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Office",
                                              style: TextStyle(
                                                  color: colorWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            /* Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("PendingTask",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("Activity",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isOffice == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    arr_ALL_Name_ID_For_Office.length != 0
                        ? Visibility(
                            visible: isOffice,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Office.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Office[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Office[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    ///___________________Support____________________________

                    arr_ALL_Name_ID_For_Support.length != 0
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                isSupport = !isSupport;
                                islead = false;
                                isSale = false;
                                isAccount = false;
                                isProduction = false;
                                isHR = false;
                                isPurchase = false;
                                isOffice = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Card(
                                elevation: 5,
                                color: colorLightGray,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: Container(
                                  height: 100,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.blue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          DASHBOARD_SUPPORT,
                                          width: 42,
                                          height: 42,
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: 25),
                                              child: Text(
                                                "Support",
                                                style: TextStyle(
                                                    color: colorWhite,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            /* Container(
                                              width: 200,
                                              height: 1,
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              color: colorWhite,
                                            ),*/
                                            /*Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("Open",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text("0",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("Closed",
                                                        style: TextStyle(
                                                            color: colorWhite,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ],
                                            )*/
                                          ],
                                        ),
                                        Icon(
                                          isSupport == false
                                              ? Icons.keyboard_arrow_down
                                              : Icons
                                                  .keyboard_arrow_up_outlined,
                                          color: colorWhite,
                                          size: 38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    arr_ALL_Name_ID_For_Support.length != 0
                        ? Visibility(
                            visible: isSupport,
                            child: Card(
                              elevation: 5,
                              color: colorGreenVeryLight,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                padding: EdgeInsets.only(
                                    top: 10, left: 10, right: 10, bottom: 10),
                                child: Wrap(
                                  runSpacing: 8,
                                  spacing: 5,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(
                                      arr_ALL_Name_ID_For_Support.length,
                                      (index) {
                                    return Container(
                                      width: w,
                                      height: w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              colorWhite, //colorCombination(title),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: makeDashboardItem(
                                            arr_ALL_Name_ID_For_Support[index]
                                                .Name,
                                            Icons.person,
                                            context123,
                                            arr_ALL_Name_ID_For_Support[index]
                                                .Name1),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    /*   arr_ALL_Name_ID_For_Support.length != 0
                            ? Container(
                                margin: EdgeInsets.only(
                                    left: 10, top: 15, right: 10),
                                child: Card(
                                  elevation: 5,
                                  color: colorLightGray,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25)),
                                  child: Container(
                                    height: 40,
                                    padding: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.indigo,
                                          Colors.blue,
                                          Colors.blue,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.ac_unit,
                                          color: colorWhite,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "  Support",
                                            style: TextStyle(
                                                color: colorWhite,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        arr_ALL_Name_ID_For_Support.length != 0
                            ? SizedBox(
                                height: 20,
                              )
                            : Container(),
                        arr_ALL_Name_ID_For_Support.length != 0
                            ? Container(
                                margin: EdgeInsets.only(
                                    top: 5.0, left: 10, right: 10, bottom: 5),
                                child: GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0,
                                    childAspectRatio: (150 / 150),
                                  ),
                                  itemCount:
                                      arr_ALL_Name_ID_For_Support.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      child: makeDashboardItem(
                                          arr_ALL_Name_ID_For_Support[index]
                                              .Name,
                                          Icons.person,
                                          context123,
                                          arr_ALL_Name_ID_For_Support[index]
                                              .Name1),
                                    );
                                  },
                                ))
                            : Container(),*/

                    //  arr_ALL_Name_ID_For_Dealer
                    ///___________________Dealer___________________________

                    arr_ALL_Name_ID_For_Dealer.length != 0
                        ? SizedBox(
                            height: 20,
                          )
                        : Container(),
                    arr_ALL_Name_ID_For_Dealer.length != 0
                        ? Container(
                            margin: EdgeInsets.only(
                                top: 5.0, left: 10, right: 10, bottom: 5),
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20.0,
                                mainAxisSpacing: 20.0,
                                childAspectRatio: (100 / 100),
                              ),
                              itemCount: arr_ALL_Name_ID_For_Dealer.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: makeDashboardItem(
                                      arr_ALL_Name_ID_For_Dealer[index].Name,
                                      Icons.person,
                                      context123,
                                      arr_ALL_Name_ID_For_Dealer[index].Name1),
                                );
                              },
                            ))
                        : Container(),
                  ],
                ),
              ),
            ),
            drawer: build_Drawer(
              context: context123,
              UserName: _offlineLoggedInData.details[0].userID,
              RolCode: _offlineLoggedInData.details[0].roleName,
            ),
          )
        : Scaffold(
            body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(
                IOSBAND,
                height: 200,
                width: 200,
              )),
              Container(
                margin: EdgeInsets.all(20),
                child: Text(
                  "You Are No Longer Available To Use This App !" +
                      "\nIf You want to access this App then Please Contact To Our Department.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorBlack,
                      fontSize: 12),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Text(
                  "Email: info@sharvayainfotech.com" +
                      "\nContact No.: +91 9099988302",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                      fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                },
                child: Card(
                    color: colorPrimary,
                    child: Container(
                      // width: double.infinity,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Center(
                        child: Text(
                          "Close App",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorWhite),
                        ),
                      ),
                    )),
              )
            ],
          ));
  }

  Future<void> _onTapOfLogOut() async {
    await SharedPrefHelper.instance
        .putBool(SharedPrefHelper.IS_LOGGED_IN_DATA, false);
    _dashBoardScreenBloc
      ..add(APITokenUpdateRequestEvent(APITokenUpdateRequest(
          CompanyId: CompanyID.toString(), UserID: LoginUserID, TokenNo: "")));
    navigateTo(context, FirstScreen.routeName, clearAllStack: true);
  }

  void _onDashBoardCallSuccess(
      MenuRightsEventResponseState response, BuildContext context123) {
    checkPermissionStatus();

    // array_MenuRightsList.clear();
    arr_UserRightsWithMenuName.clear();
    SharedPrefHelper.instance.setMenuRightsData(response.menuRightsResponse);

    EmailTO.text = "";
    arr_ALL_Name_ID_For_HR.clear();
    arr_ALL_Name_ID_For_Lead.clear();
    arr_ALL_Name_ID_For_Office.clear();
    arr_ALL_Name_ID_For_Support.clear();
    arr_ALL_Name_ID_For_Purchase.clear();
    arr_ALL_Name_ID_For_Production.clear();
    arr_ALL_Name_ID_For_Sales.clear();
    arr_ALL_Name_ID_For_Account.clear();
    arr_ALL_Name_ID_For_Dealer.clear();
    /*response.menuRightsResponse.details
        .sort((a, b) => a.toString().compareTo(b.toString()));*/
    for (var i = 0; i < response.menuRightsResponse.details.length; i++) {
      print("MenuRightsResponseFromScreen : " +
          response.menuRightsResponse.details[i].menuName);

      ///-----------------------------------------Leads----------------------------------------
      if (response.menuRightsResponse.details[i].menuName == "pgInquiry") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Inquiry";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/gen-lead.png";
        ALL_Name_ID all_name_id1 = ALL_Name_ID();
        all_name_id1.Name = "Quick Inquiry";
        all_name_id1.Name1 =
            "http://demo.sharvayainfotech.in/images/quick_inquiry.jpg";
        arr_ALL_Name_ID_For_Lead.add(all_name_id);
        arr_ALL_Name_ID_For_Lead.add(all_name_id1);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgFollowup") {
        /*ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Follow-up";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/contact.png";
        arr_ALL_Name_ID_For_Lead.add(all_name_id);*/

        if (_offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                "SW0T-GLA5-IND7-AS71" ||
            _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                "SI08-SB94-MY45-RY15") {
          ALL_Name_ID all_name_id1 = ALL_Name_ID();
          all_name_id1.Name = "Quick Follow-up";
          all_name_id1.Name1 =
              "http://demo.sharvayainfotech.in/images/contact.png";
          arr_ALL_Name_ID_For_Lead.add(all_name_id1);
        } else {
          ALL_Name_ID all_name_id1 = ALL_Name_ID();
          all_name_id1.Name = "Follow-up";
          all_name_id1.Name1 =
              "http://demo.sharvayainfotech.in/images/contact.png";
          arr_ALL_Name_ID_For_Lead.add(all_name_id1);
        }
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgQuotation") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Quotation";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/payment.png";
        arr_ALL_Name_ID_For_Lead.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgExternalLeads") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Portal Leads";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/users.png";
        arr_ALL_Name_ID_For_Lead.add(all_name_id);
        /* if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "dol2-6uh7-ph03-in5h") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "Portal Leads";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/users.png";
          arr_ALL_Name_ID_For_Lead.add(all_name_id);
        }*/
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgTeleCaller") {
        /*  if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "dol2-6uh7-ph03-in5h") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "TeleCaller";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/telecaller.png";
          arr_ALL_Name_ID_For_Lead.add(all_name_id);
        }*/

        if (_offlineLoggedInData.details[0].serialKey
                .toString()
                .toLowerCase() ==
            "sw0t-gla5-ind7-as71") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "Tele Caller";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/telecaller.png";
          arr_ALL_Name_ID_For_Lead.add(all_name_id);
        } else {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "TeleCaller";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/telecaller.png";
          all_name_id.PresentDate = "GeneralTeleCaller";
          arr_ALL_Name_ID_For_Lead.add(all_name_id);
        }
      }

      ///_________________________________Sales____________________________________________________
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgSalesOrder") {
        if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "dol2-6uh7-ph03-in5h") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "SalesOrder";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/invoice.png";
          arr_ALL_Name_ID_For_Sales.add(all_name_id);
        }
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgSalesBill") {
        if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "dol2-6uh7-ph03-in5h") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "SalesBill";
          all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/sale.png";
          arr_ALL_Name_ID_For_Sales.add(all_name_id);
        }
      }

      ///__________________________________Production____________________________________________________
      /*  else if (response.menuRightsResponse.details[i].menuName ==
          "pgPackingChecklist") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Packing Checklist";
        all_name_id.Name1 =
            "http://dolphin.sharvayainfotech.in/images/inspection.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      }
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgChecking") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Final Checking";
        all_name_id.Name1 =
            "http://dolphin.sharvayainfotech.in/images/Packing.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      }
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgInstallation") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Installation";
        all_name_id.Name1 =
            "http://dolphin.sharvayainfotech.in/images/Packing.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgProductionActivity") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Production Activity";
        all_name_id.Name1 =
            "http://dolphin.sharvayainfotech.in/images/Worklog.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgInward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Material Inward";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/Inward.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgOutward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Material Outward";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/Outward.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgMaterialMovementInward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Store Inward";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/inbox.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgMaterialMovementOutward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Store Outward";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/outbox.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgMaterialConsumption") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Material Consumption";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/consumption.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgInspection") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Inspection Check List";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/inspection.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgJobCardInward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Job Card Inward";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/inbox.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgJobCardOutward") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Job Card Outward";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/outbox.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgIndent") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Material Indent";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/indent.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgSiteSurvey") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Site Survey";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/survey.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id);

        ALL_Name_ID all_name_id2 = ALL_Name_ID();
        all_name_id2.Name = "Site Survey Report";
        all_name_id2.Name1 =
            "http://demo.sharvayainfotech.in/images/survey.png";
        arr_ALL_Name_ID_For_Production.add(all_name_id2);
      }
*/
      ///-------------------------------------Account---------------------------------------------------------

      else if (response.menuRightsResponse.details[i].menuName ==
          "pgBankVoucher") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "BankVoucher";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/bank.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      }
      /*else if (response.menuRightsResponse.details[i].menuName ==
          "pgCashVoucher") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "CashVoucher";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/money.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgCreditNote") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Credit Note";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/credit.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgDebitNote") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Debit Note";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/debit.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgPettyCash") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Petty Cash";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/petty.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgExpenseVoucher") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Exp.Voucher";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/expenses.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgJournalVoucher") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Journal Voucher";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/journal.png";
        arr_ALL_Name_ID_For_Account.add(all_name_id);
      }
*/

      ///-------------------------------------HR---------------------------------------------------------
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgLeaveRequest") {
        //isExpenseExist = true;

        //  break;
        ALL_Name_ID all_name_id = ALL_Name_ID();

        all_name_id.Name = "Leave Request";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/leave.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgLeaveApprovalView") {
        //isExpenseExist = true;

        //  break;
        ALL_Name_ID all_name_id = ALL_Name_ID();

        all_name_id.Name = "Leave Approval";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/approved.png";

        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgAttendance") {
        //isExpenseExist = true;

        //  break;
        ALL_Name_ID all_name_id = ALL_Name_ID();

        all_name_id.Name = "Attendance";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/attendance.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgExpense") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Expense";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/Expense.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgEmployee") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Employee";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/participant.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgLoanApproval") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Loan Approval";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/approved.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgMissedPunch") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Missed Punch";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/attendance.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgMissedPunchApproval") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Missed Punch Approval";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/approved.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgAdvance") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Salary Adv/Upad";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/salary.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName == "pgLoan") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Loan Installments";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/salary.png";
        arr_ALL_Name_ID_For_HR.add(all_name_id);
      }

      ///----------------------------------Purchase________________________________________________________

      else if (response.menuRightsResponse.details[i].menuName ==
          "pgPurcOrder") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Purchase Order";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/purchaseorder.png";
        arr_ALL_Name_ID_For_Purchase.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgPurchaseOrderApproval") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Purchase Order Approval";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/approved.png";
        arr_ALL_Name_ID_For_Purchase.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgPurchaseBill") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Purchase Bill";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/buy.png";
        arr_ALL_Name_ID_For_Purchase.add(all_name_id);
      }

      ///------------------------------------Office_________________________________________________________
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgDailyActivity") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Daily Activities";
        all_name_id.Name1 =
            "http://demo.sharvayainfotech.in/images/dailyactivity.png";
        arr_ALL_Name_ID_For_Office.add(all_name_id);
      } else if (response.menuRightsResponse.details[i].menuName == "pgToDO") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "To-Do";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/Task.png";
        arr_ALL_Name_ID_For_Office.add(all_name_id);
        /*ALL_Name_ID all_name_id2 = ALL_Name_ID();
        all_name_id2.Name = "Office Task";
        all_name_id2.Name1 = "http://demo.sharvayainfotech.in/images/Task.png";
        arr_ALL_Name_ID_For_Office.add(all_name_id2);*/
      }

      ///------------------------------------Support_________________________________________________________
      else if (response.menuRightsResponse.details[i].menuName ==
          "pgComplaint") {
        if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "acsi-c803-cup0-shel") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "Complaint";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/angry-emoji.jpg";
          arr_ALL_Name_ID_For_Support.add(all_name_id);
        }
      } else if (response.menuRightsResponse.details[i].menuName == "pgVisit") {
        if (_offlineLoggedInData.details[0].serialKey.toLowerCase() !=
            "acsi-c803-cup0-shel") {
          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "Attend Visit";
          all_name_id.Name1 =
              "http://demo.sharvayainfotech.in/images/visit.png";
          arr_ALL_Name_ID_For_Support.add(all_name_id);
        }
      } else if (response.menuRightsResponse.details[i].menuName ==
          "pgContractInfo") {
        ALL_Name_ID all_name_id = ALL_Name_ID();
        all_name_id.Name = "Maintenance Contract";
        all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/amc.png";
        arr_ALL_Name_ID_For_Support.add(all_name_id);
      }

      if (ISDelaer == "Dealer") {
        arr_ALL_Name_ID_For_HR.clear();
        arr_ALL_Name_ID_For_Lead.clear();
        arr_ALL_Name_ID_For_Office.clear();
        arr_ALL_Name_ID_For_Support.clear();
        arr_ALL_Name_ID_For_Purchase.clear();
        arr_ALL_Name_ID_For_Production.clear();
        arr_ALL_Name_ID_For_Sales.clear();
        arr_ALL_Name_ID_For_Account.clear();

        if (i == 0) {
          ALL_Name_ID all_name_id0 = ALL_Name_ID();
          all_name_id0.Name = "Customer";
          all_name_id0.Name1 =
              "http://demo.sharvayainfotech.in/images/profile.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id0);

          ALL_Name_ID all_name_id = ALL_Name_ID();
          all_name_id.Name = "SalesBill";
          all_name_id.Name1 = "http://122.169.111.101:308/images/sale.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id);

          ALL_Name_ID all_name_id1 = ALL_Name_ID();
          all_name_id1.Name = "Purchase Bill";
          all_name_id1.Name1 = "http://122.169.111.101:308/images/buy.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id1);

          ALL_Name_ID all_name_id3 = ALL_Name_ID();
          all_name_id3.Name = "BankVoucher";
          all_name_id3.Name1 = "http://122.169.111.101:308/images/bank.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id3);

          ALL_Name_ID all_name_id4 = ALL_Name_ID();
          all_name_id4.Name = "CashVoucher";
          all_name_id4.Name1 = "http://122.169.111.101:308/images/money.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id4);

          ALL_Name_ID all_name_id5 = ALL_Name_ID();
          all_name_id5.Name = "Mayank_Customer";
          all_name_id5.Name1 =
              "http://demo.sharvayainfotech.in/images/profile.png";
          arr_ALL_Name_ID_For_Dealer.add(all_name_id5);
        }
      }
    }

    if (ISDelaer != "Dealer") {
      ALL_Name_ID all_name_id = ALL_Name_ID();
      all_name_id.Name = "Customer";
      all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/profile.png";
      arr_ALL_Name_ID_For_Lead.add(all_name_id);
    }

    if (ISDelaer != "Dealer") {
      ALL_Name_ID all_name_id = ALL_Name_ID();
      all_name_id.Name = "Mayank_Customer";
      all_name_id.Name1 = "http://demo.sharvayainfotech.in/images/profile.png";
      arr_ALL_Name_ID_For_Lead.add(all_name_id);
    }

    if (_offlineLoggedInData.details[0].serialKey.toLowerCase() ==
        "aasi-67ro-h01i-zh6u") {
      arr_ALL_Name_ID_For_HR.clear();
      arr_ALL_Name_ID_For_Lead.clear();
      // arr_ALL_Name_ID_For_Office.clear();
      arr_ALL_Name_ID_For_Support.clear();
      arr_ALL_Name_ID_For_Purchase.clear();
      arr_ALL_Name_ID_For_Production.clear();
      arr_ALL_Name_ID_For_Sales.clear();
      arr_ALL_Name_ID_For_Account.clear();
    }
    arr_ALL_Name_ID_For_Office
        .sort((a, b) => a.Name.toLowerCase().compareTo(b.Name.toLowerCase()));
    arr_ALL_Name_ID_For_HR
        .sort((a, b) => a.Name.toLowerCase().compareTo(b.Name.toLowerCase()));
    /* arr_ALL_Name_ID_For_Lead
        .sort((a, b) => a.Name.toLowerCase().compareTo(b.Name.toLowerCase()));*/
    arr_ALL_Name_ID_For_Office
        .sort((a, b) => a.Name.toLowerCase().compareTo(b.Name.toLowerCase()));

    arr_ALL_Name_ID_For_Support
        .sort((a, b) => a.Name.toLowerCase().compareTo(b.Name.toLowerCase()));

    for (var i = 0; i < arr_ALL_Name_ID_For_HR.length; i++) {
      print("MenuRightsHR : " + arr_ALL_Name_ID_For_HR[i].Name);
    }
    for (var i = 0; i < arr_ALL_Name_ID_For_Lead.length; i++) {
      print("MenuRightsSales : " + arr_ALL_Name_ID_For_Lead[i].Name);
    }
    for (var i = 0; i < arr_ALL_Name_ID_For_Office.length; i++) {
      print("MenuRightsOffice : " + arr_ALL_Name_ID_For_Office[i].Name);
    }
    for (var i = 0; i < arr_ALL_Name_ID_For_Support.length; i++) {
      print("MenuRightsSupport : " + arr_ALL_Name_ID_For_Support[i].Name);
    }
  }

  _onFollowerEmployeeListByStatusCallSuccess(
      FollowerEmployeeListByStatusCallResponseState state) {
    print("testweb" + state.response.details[0].employeeName);
    SharedPrefHelper.instance.setFollowerEmployeeListData(state.response);
    _offlineFollowerEmployeeListData =
        SharedPrefHelper.instance.getFollowerEmployeeList();
    print("_offlineFollowerEmployeeListData" +
        _offlineFollowerEmployeeListData.details[0].employeeName +
        "");
  }

  void _onALLEmployeeListByStatusCallSuccess(
      ALL_EmployeeNameListResponseState state) {
    SharedPrefHelper.instance
        .setALLEmployeeListData(state.all_employeeList_Response);
    _offlineALLEmployeeListData =
        SharedPrefHelper.instance.getALLEmployeeList();
    print("_offlineALLEmployeeListData" +
        _offlineALLEmployeeListData.details[0].employeeName +
        "");
  }

  void _OnAttendanceListResponse(AttendanceListCallResponseState state) {
    String PDate = "";
    String CDate = "";

    if (state.response.details.isNotEmpty) {
      for (int i = 0; i < state.response.details.length; i++) {
        /*PresenceDate*/
        if (state.response.details[i].presenceDate != "") {
          PDate = state.response.details[i].presenceDate.getFormattedDate(
              fromFormat: "yyyy-MM-ddTHH:mm:ss", toFormat: "dd-MM-yyyy");
          print("APIDAte" + PDate);

          CDate = selectedDate.day.toString() +
              "-" +
              selectedDate.month.toString() +
              "-" +
              selectedDate.year.toString();
          print("CurrentDAte" + CDate);

          DateTime APIDate = new DateFormat("dd-MM-yyyy").parse(PDate);
          DateTime CurrentDate = new DateFormat("dd-MM-yyyy").parse(CDate);

          if (APIDate == CurrentDate) {
            print("ConditionTrue");

            if (state.response.details[i].timeIn != "") {
              PuchInTime.text = state.response.details[i].timeIn.toString();
              isPunchIn = true;
            } else {
              isPunchIn = false;
              PuchInTime.text = "";
            }
            if (state.response.details[i].timeOut != "") {
              PuchOutTime.text = state.response.details[i].timeOut.toString();

              isPunchOut = true;
            } else {
              isPunchOut = false;
              PuchOutTime.text = "";
            }

            if (state.response.details[i].LunchIn != "") {
              LunchInTime.text = state.response.details[i].LunchIn.toString();

              isLunchIn = true;
            } else {
              isLunchIn = false;
              LunchInTime.text = "";
            }
            if (state.response.details[i].LunchOut != "") {
              LunchOutTime.text = state.response.details[i].LunchOut.toString();

              isLunchOut = true;
            } else {
              isLunchOut = false;
              LunchOutTime.text = "";
            }

            break;
          } else {
            isPunchIn = false;
            isPunchOut = false;
            isLunchIn = false;
            isLunchOut = false;
            PuchInTime.text = ""; //state.response.details[i].timeIn.toString();
            PuchOutTime.text =
                ""; //state.response.details[i].timeOut.toString();
            LunchInTime.text = "";
            LunchOutTime.text = "";
            print("ConditionFalse");
            // isPunchIn = false;
          }
        }

        print("TodayAttendance" +
            "Emp_Name : " +
            state.response.details[i].employeeName +
            " InTime : " +
            state.response.details[i].timeIn.toString());
        // timeChangesEvent();
      }
    } else {
      isPunchIn = false;
      isPunchOut = false;
    }
  }

  _getCurrentLocation() {
    geolocator123
        .getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.best)
        .then((Position position) async {
      Longitude = position.longitude.toString();
      Latitude = position.latitude.toString();

      LatitudeHome = Latitude;
      LongitudeHome = Longitude;
      SharedPrefHelper.instance.setLatitude(Latitude);
      SharedPrefHelper.instance.setLongitude(Longitude);
      /*if (MapAPIKey != "") {
        Address = await getAddressFromLatLng(Latitude, Longitude, MapAPIKey);
      } else {
        Address = "";
      }*/
    }).catchError((e) {
      print(e);
    });

    location.onLocationChanged.listen((LocationData currentLocation) async {
      // Use current location
      print("OnLocationChange" +
          " Location : " +
          MapAPIKey +
          currentLocation.latitude.toString());
      Latitude = currentLocation.latitude.toString();
      Longitude = currentLocation.longitude.toString();
      LatitudeHome = Latitude;
      LongitudeHome = Longitude;
      SharedPrefHelper.instance.setLatitude(Latitude);
      SharedPrefHelper.instance.setLongitude(Longitude);
    });
  }

  void checkPermissionStatus() async {
    if (!await location.serviceEnabled()) {
      // location.requestService();

      if (Platform.isAndroid) {
        location.requestService();
        /*showCommonDialogWithSingleOption(Globals.context,
            "Can't get current location, Please make sure you enable GPS and try again !",
            positiveButtonTitle: "OK", onTapOfPositiveButton: () {
          AppSettings.openLocationSettings();
          Navigator.pop(context);
        });*/
      }
    }
    bool granted = await Permission.location.isGranted;
    bool Denied = await Permission.location.isDenied;
    bool PermanentlyDenied = await Permission.location.isPermanentlyDenied;

    print("PermissionStatus" +
        "Granted : " +
        granted.toString() +
        " Denied : " +
        Denied.toString() +
        " PermanentlyDenied : " +
        PermanentlyDenied.toString());

    if (Denied == true) {
      // openAppSettings();
      is_LocationService_Permission = false;
/*      showCommonDialogWithSingleOption(context,
          "Location permission is required , You have to click on OK button to Allow the location access !",
          positiveButtonTitle: "OK", onTapOfPositiveButton: () async {
        await openAppSettings();
        Navigator.of(context).pop();
      });*/
      await Permission.storage.request();

      // await Permission.location.request();
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
    }

// You can can also directly ask the permission about its status.
    if (await Permission.location.isRestricted) {
      // The OS restricts access, for example because of parental controls.
      openAppSettings();
    }
    if (PermanentlyDenied == true) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      is_LocationService_Permission = false;
      openAppSettings();
    }

    if (granted == true) {
      // The OS restricts access, for example because of parental controls.
      is_LocationService_Permission = true;
      _getCurrentLocation();

      /*if (serviceLocation == true) {
        // Use location.
        _serviceEnabled=false;

         location.requestService();


      }
      else{
        _serviceEnabled=true;
        _getCurrentLocation();



      }*/
    }
  }

  Future<String> getAddressFromLatLngMapMyIndia(
      String lat, String lng, String skey) async {
    String _host =
        'https://apis.mapmyindia.com/advancedmaps/v1/$skey/rev_geocode';
    final url = '$_host?lat=$lat&lng=$lng';

    print("MapRequest" + url);
    if (lat != "" && lng != "null") {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        String _formattedAddress = data["results"][0]["formatted_address"];
        //Address = _formattedAddress;
        print("response ==== $_formattedAddress");
        return _formattedAddress;
      } else
        return null;
    } else
      return null;
  }

  void _onAttandanceSaveResponse(AttendanceSaveCallResponseState state) {
    // state.response.details[0].column2

    _dashBoardScreenBloc.add(AttendanceCallEvent(AttendanceApiRequest(
        pkID: "",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        Month: selectedDate.month.toString(),
        Year: selectedDate.year.toString(),
        CompanyId: CompanyID.toString(),
        LoginUserID: LoginUserID)));
  }

  void _onPunchAttandanceSaveResponse(PunchAttendenceSaveResponseState state) {
    // state.response.details[0].column2

    // print("Saevf" + state.punchAttendenceSaveResponse.details[0].column1);

    _dashBoardScreenBloc.add(AttendanceCallEvent(AttendanceApiRequest(
        pkID: "",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        Month: selectedDate.month.toString(),
        Year: selectedDate.year.toString(),
        CompanyId: CompanyID.toString(),
        LoginUserID: LoginUserID)));
  }

  showcustomdialogSendEmail(
      {BuildContext context1,
      String Email,
      PunchAttendanceSaveRequest att}) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorPrimary, //                   <--- border color
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                        15.0) //                 <--- border radius here
                    ),
              ),
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Send Email",
                    style: TextStyle(
                        color: colorPrimary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Text("Email To.",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: colorPrimary,
                                    fontWeight: FontWeight
                                        .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Card(
                              elevation: 5,
                              color: colorLightGray,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                width: double.maxFinite,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                          controller: EmailTO,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            hintText: "Tap to enter email To",
                                            labelStyle: TextStyle(
                                              color: Color(0xFF000000),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF000000),
                                          ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    /*  Container(
                      margin: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Text("Email BCC",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: colorPrimary,
                                    fontWeight: FontWeight
                                        .bold) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Card(
                              elevation: 5,
                              color: colorLightGray,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Container(
                                padding: EdgeInsets.only(left: 25, right: 20),
                                width: double.maxFinite,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                          controller: EmailBCC,
                                          decoration: InputDecoration(
                                            hintText: "Tap to enter email BCC",
                                            labelStyle: TextStyle(
                                              color: Color(0xFF000000),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF000000),
                                          ) // baseTheme.textTheme.headline2.copyWith(color: colorBlack),

                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),*/
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: getCommonButton(
                            baseTheme,
                            () async {
                              if (EmailTO.text != "") {
                                bool emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(EmailTO.text);

                                if (emailValid == true) {
                                  String webreq = SiteURL +
                                      "/DashboardDaily.aspx?MobilePdf=yes&userid=" +
                                      LoginUserID +
                                      "&password=" +
                                      Password +
                                      "&emailaddress=" +
                                      EmailTO.text;

                                  print("webreq" + webreq);

                                  _dashBoardScreenBloc
                                      .add(PunchOutWebMethodEvent(webreq));

                                  //APITokenUpdateRequestEvent

                                  _showMyDialog(EmailTO.text, att);
                                } else {
                                  showCommonDialogWithSingleOption(
                                      context, "Email is not valid !",
                                      positiveButtonTitle: "OK");
                                }
                                // GenerateQT(context123, EmailTO.text);
                              } else {
                                showCommonDialogWithSingleOption(
                                    context, "Email TO is Required !",
                                    positiveButtonTitle: "OK");
                              }
                            },
                            "YES",
                            backGroundColor: colorPrimary,
                            textColor: colorWhite,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 100,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: getCommonButton(
                            baseTheme,
                            () {
                              Navigator.pop(context);
                            },
                            "NO",
                            backGroundColor: colorPrimary,
                            textColor: colorWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog(
      String textEmaill, PunchAttendanceSaveRequest att) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context123) {
        return AlertDialog(
          title: Text('Please wait ...!'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: true,
                  child: GenerateQT(context123, textEmaill, att),
                ),

                //GetCircular123(),
              ],
            ),
          ),
          /*actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context)
                    .pop(), //  We can return any object from here
                child: Text('NO')),
            */ /* prgresss!=100 ? CircularProgressIndicator() :*/ /* FlatButton(
                onPressed: () => {
                      Navigator.of(context).pop(),
                    }, //  We can return any object from here
                child: Text('YES'))
          ],*/
        );
      },
    );
  }

  GenerateQT(BuildContext context123, String emailTOstr,
      PunchAttendanceSaveRequest att) {
    return Center(
      child: Container(
        child: Stack(
          children: [
            Container(
              height: 20,
              width: 20,
              child: Visibility(
                visible: true,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(SiteURL +
                          "/DashboardDaily.aspx?MobilePdf=yes&userid=" +
                          LoginUserID +
                          "&password=" +
                          Password +
                          "&emailaddress=" +
                          emailTOstr)),
                  // initialFile: "assets/index.html",
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,

                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },

                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },

                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url;
                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunch(url)) {
                        // Launch the App
                        await launch(
                          url,
                        );
                        //  islodding = false;

                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    //islodding = false;

                    return NavigationActionPolicy.CANCEL;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      onWebLoadingStop = true;
                      islodding = false;
                    });
                    print("OnLoad" +
                        "On Loading Complted" +
                        onWebLoadingStop.toString());
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                    //Navigator.pop(context123);

                    String pageTitle = "";

                    controller.getTitle().then((value) {
                      setState(() {
                        pageTitle = value;

                        if (pageTitle == "E-Office-Desk") {
                          Navigator.pop(context123);
                          showCommonDialogWithSingleOption(
                              context, "Email Sent Successfully ",
                              onTapOfPositiveButton: () {
                            //Navigator.pop(context);

                            navigateTo(context, HomeScreen.routeName,
                                clearAllStack: true);
                          });
                        } else {
                          Navigator.pop(context123);
                          showCommonDialogWithSingleOption(
                              context, "Please Try Again !");
                        }
                      });
                    });

                    /*showCommonDialogWithSingleOption(
                        context, "Email Sent Successfully ",
                        onTapOfPositiveButton: () {
                      //Navigator.pop(context);
                      navigateTo(context, HomeScreen.routeName,
                          clearAllStack: true);
                    });*/
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                    isLoading = false;
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                      this.prgresss = progress;

                      // _QuotationBloc.add(QuotationPDFGenerateCallEvent(QuotationPDFGenerateRequest(CompanyId: CompanyID.toString(),QuotationNo: model.quotationNo)));
                    }

                    //  EasyLoading.showProgress(progress / 100, status: 'Loading...');

                    setState(() {
                      this.progress = progress / 100;
                      this.prgresss = progress;

                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print("LoadWeb" + consoleMessage.message.toString());
                  },
                  /*  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    //hide you progressbar here
                    setState(() {
                      islodding = false;
                    });
                  },*/
                  onPageCommitVisible: (controller, url) {
                    setState(() {
                      islodding = false;
                    });
                  },
                ),
              ),
            ),
            //CircularProgressIndicator(),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.white,
              child: Lottie.asset('assets/lang/sample_kishan_two.json',
                  width: 100, height: 100),
            )
            // LinearProgressIndicator(value: this.progress)
            /* this.progress < 1.0
                ? LinearProgressIndicator(value: this.progress)
                : Container(),*/
            //
          ],
        ),
      ),
    );
  }

  punchoutLogic() async {
    if (isPunchIn == true) {
      TimeOfDay selectedTime = TimeOfDay.now();

      //EmailTO.text = model.emailAddress;

      /*PunchAttendanceSaveRequest(
        Mode: "punchout",
        pkID: "0",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        PresenceDate: selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString(),
        TimeIn:
            selectedTime.hour.toString() + ":" + selectedTime.minute.toString(),
        TimeOut:
            selectedTime.hour.toString() + ":" + selectedTime.minute.toString(),
        LunchIn: "",
        LunchOut: "",
        LoginUserID: LoginUserID,
        Notes: "",
        Latitude: Latitude,
        Longitude: Longitude,
        LocationAddress: Address,
        CompanyId: CompanyID.toString(),
      );*/
      PunchAttendanceSaveRequest punchAttendanceSaveRequest =
          PunchAttendanceSaveRequest(
        pkID: "0",
        CompanyId: CompanyID.toString(),
        Mode: "punchout",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        FileName: "demo.png",
        PresenceDate: selectedDate.year.toString() +
            "-" +
            selectedDate.month.toString() +
            "-" +
            selectedDate.day.toString(),
        Time:
            selectedTime.hour.toString() + ":" + selectedTime.minute.toString(),
        Notes: "",
        Latitude: Latitude,
        Longitude: Longitude,
        LocationAddress: Address,
        LoginUserId: LoginUserID,
      );

      if (_offlineLoggedInData.details[0].serialKey.toUpperCase() ==
              "SW0T-GLA5-IND7-AS71" /*||
          _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
              "SI08-SB94-MY45-RY15"*/
          ) {
        showcustomdialogSendEmail(
            context1: context, att: punchAttendanceSaveRequest);
      }

      if (isPunchOut == true) {
        if (_offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                "SW0T-GLA5-IND7-AS71" /*||
            _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                "SI08-SB94-MY45-RY15"*/
            ) {
          showcustomdialogSendEmail(
              context1: context, att: punchAttendanceSaveRequest);
        } else {
          showCommonDialogWithSingleOption(
              context,
              _offlineLoggedInData.details[0].employeeName +
                  " \n Punch Out : " +
                  PuchOutTime.text,
              positiveButtonTitle: "OK");
        }
      } else {
        if (await Permission.storage.isDenied) {
          //await Permission.storage.request();

          checkPhotoPermissionStatus();
        } else {
          if (ConstantMAster.toString() == "" ||
              ConstantMAster.toString().toLowerCase() == "no") {
            _dashBoardScreenBloc.add(
                PunchWithoutImageAttendanceSaveRequestEvent(
                    PunchWithoutImageAttendanceSaveRequest(
                        Mode: "punchout",
                        pkID: "0",
                        EmployeeID: _offlineLoggedInData.details[0].employeeID
                            .toString(),
                        PresenceDate: selectedDate.year.toString() +
                            "-" +
                            selectedDate.month.toString() +
                            "-" +
                            selectedDate.day.toString(),
                        TimeIn: "",
                        TimeOut: selectedTime.hour.toString() +
                            ":" +
                            selectedTime.minute.toString(),
                        LunchIn: "",
                        LunchOut: "",
                        LoginUserID: LoginUserID,
                        Notes: "",
                        Latitude: Latitude,
                        Longitude: Longitude,
                        LocationAddress: Address,
                        CompanyId: CompanyID.toString())));
          } else {
            final imagepicker = ImagePicker();

            XFile file = await imagepicker.pickImage(
                source: ImageSource.camera, imageQuality: 85);

            File filerty = File(file.path);

            final extension = p.extension(filerty.path);

            int timestamp1 = DateTime.now().millisecondsSinceEpoch;

            /*String filenamepunchout =
                _offlineLoggedInData.details[0].employeeID.toString() +
                    "_" +
                    DateTime.now().day.toString() +
                    "_" +
                    DateTime.now().month.toString() +
                    "_" +
                    DateTime.now().year.toString() +
                    "_" +
                    timestamp1.toString() +
                    extension;
            */

            if (file != null) {
              File file1 = File(file.path);

              final dir = await path_provider.getTemporaryDirectory();

              final extension = p.extension(file1.path);

              int timestamp1 = DateTime.now().millisecondsSinceEpoch;

              String filenamepunchout =
                  _offlineLoggedInData.details[0].employeeID.toString() +
                      "_" +
                      DateTime.now().day.toString() +
                      "_" +
                      DateTime.now().month.toString() +
                      "_" +
                      DateTime.now().year.toString() +
                      "_" +
                      timestamp1.toString() +
                      extension;

              final targetPath = dir.absolute.path + "/" + filenamepunchout;
              File file1231 = await testCompressAndGetFile(file1, targetPath);
              final bytes = file1.readAsBytesSync().lengthInBytes;
              final kb = bytes / 1024;
              final mb = kb / 1024;

              print("Image File Is Largre" +
                  " KB : " +
                  kb.toString() +
                  " MB : " +
                  mb.toString());
              final snackBar = SnackBar(
                content:
                    Text(" KB : " + kb.toString() + " MB : " + mb.toString()),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              _dashBoardScreenBloc.add(PunchAttendanceSaveRequestEvent(
                  file1231,
                  PunchAttendanceSaveRequest(
                    pkID: "0",
                    CompanyId: CompanyID.toString(),
                    Mode: "punchout",
                    EmployeeID:
                        _offlineLoggedInData.details[0].employeeID.toString(),
                    FileName: filenamepunchout,
                    PresenceDate: selectedDate.year.toString() +
                        "-" +
                        selectedDate.month.toString() +
                        "-" +
                        selectedDate.day.toString(),
                    Time: selectedTime.hour.toString() +
                        ":" +
                        selectedTime.minute.toString(),
                    Notes: "",
                    Latitude: Latitude,
                    Longitude: Longitude,
                    LocationAddress: Address,
                    LoginUserId: LoginUserID,
                  )));
            } /*else {
              showCommonDialogWithSingleOption(
                  context, "Something Went Wrong File Not Found Exception !",
                  positiveButtonTitle: "OK");
            }*/
          }
        }
      }
    } else {
      showCommonDialogWithSingleOption(context, "Punch in Is Required !",
          positiveButtonTitle: "OK");
    }
  }

  lunchoutLogic() async {
    if (isLunchIn == true) {
      //EmailTO.text = model.emailAddress;
      TimeOfDay selectedTime = TimeOfDay.now();

      if (isPunchOut == false) {
        PunchAttendanceSaveRequest punchAttendanceSaveRequest =
            PunchAttendanceSaveRequest(
          pkID: "0",
          CompanyId: CompanyID.toString(),
          Mode: "lunchout",
          EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
          FileName: "demo.png",
          PresenceDate: selectedDate.year.toString() +
              "-" +
              selectedDate.month.toString() +
              "-" +
              selectedDate.day.toString(),
          Time: selectedTime.hour.toString() +
              ":" +
              selectedTime.minute.toString(),
          Notes: "",
          Latitude: Latitude,
          Longitude: Longitude,
          LocationAddress: Address,
          LoginUserId: LoginUserID,
        );
        /* PunchAttendanceSaveRequest(
          Mode: "lunchout",
          pkID: "0",
          EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
          PresenceDate: selectedDate.year.toString() +
              "-" +
              selectedDate.month.toString() +
              "-" +
              selectedDate.day.toString(),
          TimeIn: selectedTime.hour.toString() +
              ":" +
              selectedTime.minute.toString(),
          TimeOut: "",
          LunchIn: selectedTime.hour.toString() +
              ":" +
              selectedTime.minute.toString(),
          LunchOut: selectedTime.hour.toString() +
              ":" +
              selectedTime.minute.toString(),
          LoginUserID: LoginUserID,
          Notes: "",
          Latitude: Latitude,
          Longitude: Longitude,
          LocationAddress: Address,
          CompanyId: CompanyID.toString(),
        );*/

        /*_offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                    "SW0T-GLA5-IND7-AS71" ||
                _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                    "SI08-SB94-MY45-RY15" */ /* ||
              _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                  "TEST-0000-SI0F-0208"*/ /*
            ? showcustomdialogSendEmail(
                context1: context, att: punchAttendanceSaveRequest)
            : Container();*/
        // _showMyDialog();

        if (isLunchOut == true) {
          /*if (_offlineLoggedInData
                      .details[0].serialKey
                      .toUpperCase() ==
                  "SW0T-GLA5-IND7-AS71" ||
              _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                  "SI08-SB94-MY45-RY15" ||
              _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                  "TEST-0000-SI0F-0208") {
            showcustomdialogSendEmail(
                context1: context, att: punchAttendanceSaveRequest);
          } else {
            showCommonDialogWithSingleOption(
                context,
                _offlineLoggedInData.details[0].employeeName +
                    " \n Punch Out : " +
                    PuchOutTime.text,
                positiveButtonTitle: "OK");
          }*/

          showCommonDialogWithSingleOption(
              context,
              _offlineLoggedInData.details[0].employeeName +
                  " \n Lunch Out : " +
                  LunchOutTime.text,
              positiveButtonTitle: "OK");
        } else {
          if (ConstantMAster.toString() == "" ||
              ConstantMAster.toString().toLowerCase() == "no") {
            _dashBoardScreenBloc.add(
                PunchWithoutImageAttendanceSaveRequestEvent(
                    PunchWithoutImageAttendanceSaveRequest(
                        Mode: "lunchout",
                        pkID: "0",
                        EmployeeID: _offlineLoggedInData.details[0].employeeID
                            .toString(),
                        PresenceDate: selectedDate.year.toString() +
                            "-" +
                            selectedDate.month.toString() +
                            "-" +
                            selectedDate.day.toString(),
                        TimeIn: "",
                        TimeOut: "",
                        LunchIn: "",
                        LunchOut: selectedTime.hour.toString() +
                            ":" +
                            selectedTime.minute.toString(),
                        LoginUserID: LoginUserID,
                        Notes: "",
                        Latitude: Latitude,
                        Longitude: Longitude,
                        LocationAddress: Address,
                        CompanyId: CompanyID.toString())));
          } else {
            final imagepicker = ImagePicker();

            XFile file = await imagepicker.pickImage(
              source: ImageSource.camera,
              imageQuality: 85,
            );

            if (file != null) {
              File file1 = File(file.path);

              final dir = await path_provider.getTemporaryDirectory();

              final extension = p.extension(file1.path);

              int timestamp1 = DateTime.now().millisecondsSinceEpoch;

              String filenameLunchOut =
                  _offlineLoggedInData.details[0].employeeID.toString() +
                      "_" +
                      DateTime.now().day.toString() +
                      "_" +
                      DateTime.now().month.toString() +
                      "_" +
                      DateTime.now().year.toString() +
                      "_" +
                      timestamp1.toString() +
                      extension;

              final targetPath = dir.absolute.path + "/" + filenameLunchOut;
              File file1231 = await testCompressAndGetFile(file1, targetPath);
              final bytes = file1.readAsBytesSync().lengthInBytes;
              final kb = bytes / 1024;
              final mb = kb / 1024;

              print("Image File Is Largre" +
                  " KB : " +
                  kb.toString() +
                  " MB : " +
                  mb.toString());
              final snackBar = SnackBar(
                content:
                    Text(" KB : " + kb.toString() + " MB : " + mb.toString()),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              _dashBoardScreenBloc.add(PunchAttendanceSaveRequestEvent(
                  file1231,
                  PunchAttendanceSaveRequest(
                    pkID: "0",
                    CompanyId: CompanyID.toString(),
                    Mode: "lunchout",
                    EmployeeID:
                        _offlineLoggedInData.details[0].employeeID.toString(),
                    FileName: filenameLunchOut,
                    PresenceDate: selectedDate.year.toString() +
                        "-" +
                        selectedDate.month.toString() +
                        "-" +
                        selectedDate.day.toString(),
                    Time: selectedTime.hour.toString() +
                        ":" +
                        selectedTime.minute.toString(),
                    Notes: "",
                    Latitude: Latitude,
                    Longitude: Longitude,
                    LocationAddress: Address,
                    LoginUserId: LoginUserID,
                  )));
            }
          }
        }
        /*isLunchOut == true
            ?
            _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                        "SW0T-GLA5-IND7-AS71" ||
                    _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                        "SI08-SB94-MY45-RY15" ||
                    _offlineLoggedInData.details[0].serialKey.toUpperCase() ==
                        "TEST-0000-SI0F-0208"
                ? showcustomdialogSendEmail(
                    context1: context, att: punchAttendanceSaveRequest)
                : showCommonDialogWithSingleOption(
                    context,
                    _offlineLoggedInData.details[0].employeeName +
                        " \n Punch Out : " +
                        PuchOutTime.text,
                    positiveButtonTitle: "OK")
            : _dashBoardScreenBloc.add(PunchAttendanceSaveRequestEvent(
                Lunch_In_OUT_File, punchAttendanceSaveRequest));*/
      } else {
        if (isLunchOut == false) {
          showCommonDialogWithSingleOption(
              context, "After Punch Out, You can't be able to do Lunch Out!!",
              positiveButtonTitle: "OK");
        }
      }
    } else {
      showCommonDialogWithSingleOption(context, "Lunch in Is Required !",
          positiveButtonTitle: "OK");
    }
  }

  void _OnFethEmployeeImage(EmployeeListResponseState state) {
    for (int i = 0; i < state.employeeListResponse.details.length; i++) {
      if (_offlineLoggedInData.details[0].employeeID ==
          state.employeeListResponse.details[i].pkID) {
        if (state.employeeListResponse.details[i].employeeImage != "") {
          ImgFromTextFiled.text = "";
          ImgFromTextFiled.text = _offlineCompanyData.details[0].siteURL +
              state.employeeListResponse.details[i].employeeImage;

          print("rjrjj" + EmployeeImage);
          break;
        }
      }
    }
  }

  void getcurrentTimeInfoFromMaindfd() async {
    DateTime startDate = await NTP.now();
    print('NTP DateTime: ${startDate} ${DateTime.now()}');

    var now = startDate;
    var formatter = new DateFormat('yyyy-MM-ddTHH');
    String currentday = formatter.format(now);
    String PresentDate1 = formatter.format(DateTime.now());
    print(
        'NTP DateTime123456: ${DateTime.parse(currentday)} ${DateTime.parse(PresentDate1)}');

    if (DateTime.parse(currentday) != DateTime.parse(PresentDate1)) {
      //  navigateTo(context, AttendanceListScreen.routeName, clearAllStack: true);
      isCurrentTime = false;

      return showCommonDialogWithSingleOption(Globals.context,
          "Your Device DateTime is not correct as per current DateTime , Kindly Update Your Device Time !",
          positiveButtonTitle: "OK", onTapOfPositiveButton: () {
        //navigateTo(context, HomeScreen.routeName, clearAllStack: true);
        Navigator.pop(Globals.context);
      });
    } else {
      isCurrentTime = true;
    }
  }

  void _OnTokenUpdateResponse(APITokenUpdateState state) {
    if (state.firebaseTokenResponse.details[0].column2 != "") {
      print("APDdfd" +
          " API Token Response : " +
          state.firebaseTokenResponse.details[0].column2);
    }
  }

  void MovetoFollowupScreen(
      BuildContext Notifycontext, String Title, String BodyDetails) {
    SplitSTr = BodyDetails.split("By");
    print("NotificationSplitedValue" +
        " Value : " +
        SplitSTr[0].toString() +
        " 2nd : " +
        SplitSTr[1].toString());
    //navigateTo(context, FollowupListScreen.routeName, clearAllStack: true);
  }

  onTimerFinished() {}

  void _OnwebSucessResponse(PunchOutWebMethodState state) {
    print("Webresponse" + state.response);
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void checkPhotoPermissionStatus() async {
    bool granted = await Permission.storage.isGranted;
    bool Denied = await Permission.storage.isDenied;
    bool PermanentlyDenied = await Permission.storage.isPermanentlyDenied;
    print("PermissionStatus" +
        "Granted : " +
        granted.toString() +
        " Denied : " +
        Denied.toString() +
        " PermanentlyDenied : " +
        PermanentlyDenied.toString());
    if (Denied == true) {
      await Permission.storage.request();
    }
    if (await Permission.location.isRestricted) {
      openAppSettings();
    }
    if (PermanentlyDenied == true) {
      openAppSettings();
    }
    if (granted == true) {}
  }

  void getDetailsOfImage(String docURLFromListing, String docname) async {
    await urlToFile(docURLFromListing, docname.toString());
  }

  urlToFile(String imageUrl, String filenamee) async {
    if (Uri.parse(imageUrl).isAbsolute == true) {
      try {
        http.Response response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          Directory dir = await getApplicationDocumentsDirectory();
          dir.exists();
          String pathName = p.join(dir.path, filenamee);

          print("77575sdd7" + imageUrl);

          File file = new File(pathName);

          print("7757sds5sdd7" + file.path);

          try {
            await file.writeAsBytes(response.bodyBytes);
          } catch (e) {
            print("hdfhjfdhh" + e.toString());
          }

          Lunch_In_OUT_File = file;
        }
      } catch (e) {
        print("775757" + e.toString());
      }

      setState(() {});
    }
  }

  void _onGetConstant(ConstantResponseState state) {
    print("ConstantValue" + state.response.details[0].value.toString());

    ConstantMAster = state.response.details[0].value.toString();
  }

  void _OnPunchOutWithoutImageSucess(
      PunchWithoutAttendenceSaveResponseState state) {
    _dashBoardScreenBloc.add(AttendanceCallEvent(AttendanceApiRequest(
        pkID: "",
        EmployeeID: _offlineLoggedInData.details[0].employeeID.toString(),
        Month: selectedDate.month.toString(),
        Year: selectedDate.year.toString(),
        CompanyId: CompanyID.toString(),
        LoginUserID: LoginUserID)));
  }

  Future<void> OpenDriveLink(String phoneNumber) async {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
    // such as spaces in the input, which would cause `launch` to fail on some
    // platforms.
    final Uri launchUri = Uri.parse(phoneNumber);
    await launch(launchUri.toString());
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print('testCompressAndGetFile');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
    );
    print(file.lengthSync());
    print(result?.lengthSync());
    return result;
  }

  UserProfileDialog({BuildContext context1}) async {
    await showDialog(
      barrierDismissible: false,
      context: context1,
      builder: (BuildContext context123) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          children: [
            SizedBox(
                width: MediaQuery.of(context123).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(8), // Border width
                      decoration: BoxDecoration(
                          color: colorLightGray, shape: BoxShape.circle),
                      child: ClipOval(
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(80), // Image radius
                          child: ImageFullScreenWrapperWidget(
                            child: Image.network(ImgFromTextFiled.text,
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    /*Center(
                      child: Image.network(
                        ImgFromTextFiled.text,
                        key: ValueKey(new Random().nextInt(100)),
                        height: 200,
                        width: 200,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace stackTrace) {
                          return Image.network(
                              "https://img.icons8.com/color/2x/no-image.png",
                              height: 48,
                              width: 48);
                        },
                      ),
                    ),*/
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "User : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                              child: Text(
                                  _offlineLoggedInData.details[0].employeeName,
                                  style: TextStyle(
                                    color: colorBlack,
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "Role : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            child:
                                Text(_offlineLoggedInData.details[0].roleName,
                                    style: TextStyle(
                                      color: colorBlack,
                                    )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 25),
                      child: Row(
                        children: [
                          Container(
                            child: Text(
                              "State : ",
                              style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            child:
                                Text(_offlineLoggedInData.details[0].StateName,
                                    style: TextStyle(
                                      color: colorBlack,
                                    )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: getCommonButton(baseTheme, () {
                        Navigator.pop(context123);
                      }, "Close", backGroundColor: colorPrimary, radius: 25.0),
                    ),
                  ],
                )),
          ],
        );
      },
    );
  }

  Future<void> showInformationDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          bool isChecked = false;
          // timeChangesEvent();

          return StatefulBuilder(builder: (context, setState) {
            isPunchIn = PuchInboolcontroller.text == "" ||
                    PuchInboolcontroller.text == "false"
                ? false
                : true;
            isPunchOut = PuchOutboolcontroller.text == "" ||
                    PuchOutboolcontroller.text == "false"
                ? false
                : true;
            isLunchIn = LunchInboolcontroller.text == "" ||
                    LunchInboolcontroller.text == "false"
                ? false
                : true;
            isLunchOut = LunchOutboolcontroller.text == "" ||
                    LunchOutboolcontroller.text == "false"
                ? false
                : true;
            return AlertDialog(
              content: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      TimeOfDay selectedTime = TimeOfDay.now();

                      if (isCurrentTime == true) {
                        if (isPunchIn == true) {
                          showCommonDialogWithSingleOption(
                              context,
                              _offlineLoggedInData.details[0].employeeName +
                                  " \n Punch In : " +
                                  PuchInTime.text,
                              positiveButtonTitle: "OK");
                        } else {
                          if (await Permission.storage.isDenied) {
                            //await Permission.storage.request();

                            checkPhotoPermissionStatus();
                          } else {
                            if (ConstantMAster.toString() == "" ||
                                ConstantMAster.toString().toLowerCase() ==
                                    "no") {
                              _dashBoardScreenBloc.add(
                                  PunchWithoutImageAttendanceSaveRequestEvent(
                                      PunchWithoutImageAttendanceSaveRequest(
                                          Mode: "punchin",
                                          pkID: "0",
                                          EmployeeID: _offlineLoggedInData
                                              .details[0].employeeID
                                              .toString(),
                                          PresenceDate: selectedDate.year
                                                  .toString() +
                                              "-" +
                                              selectedDate.month.toString() +
                                              "-" +
                                              selectedDate.day.toString(),
                                          TimeIn: selectedTime.hour.toString() +
                                              ":" +
                                              selectedTime.minute.toString(),
                                          TimeOut: "",
                                          LunchIn: "",
                                          LunchOut: "",
                                          LoginUserID: LoginUserID,
                                          Notes: "",
                                          Latitude: Latitude,
                                          Longitude: Longitude,
                                          LocationAddress: Address,
                                          CompanyId: CompanyID.toString())));
                            } else {
                              final imagepicker = ImagePicker();

                              XFile file = await imagepicker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 85,
                              );

                              if (file != null) {
                                File file1 = File(file.path);

                                final dir =
                                    await path_provider.getTemporaryDirectory();

                                final extension = p.extension(file1.path);

                                int timestamp1 =
                                    DateTime.now().millisecondsSinceEpoch;

                                String filenamepunchin = _offlineLoggedInData
                                        .details[0].employeeID
                                        .toString() +
                                    "_" +
                                    DateTime.now().day.toString() +
                                    "_" +
                                    DateTime.now().month.toString() +
                                    "_" +
                                    DateTime.now().year.toString() +
                                    "_" +
                                    timestamp1.toString() +
                                    extension;

                                final targetPath =
                                    dir.absolute.path + "/" + filenamepunchin;
                                File file1231 = await testCompressAndGetFile(
                                    file1, targetPath);
                                final bytes =
                                    file1.readAsBytesSync().lengthInBytes;
                                final kb = bytes / 1024;
                                final mb = kb / 1024;

                                print("Image File Is Largre" +
                                    " KB : " +
                                    kb.toString() +
                                    " MB : " +
                                    mb.toString());
                                final snackBar = SnackBar(
                                  content: Text(" KB : " +
                                      kb.toString() +
                                      " MB : " +
                                      mb.toString()),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);

                                _dashBoardScreenBloc
                                    .add(PunchAttendanceSaveRequestEvent(
                                        file1231,
                                        PunchAttendanceSaveRequest(
                                          pkID: "0",
                                          CompanyId: CompanyID.toString(),
                                          Mode: "punchIN",
                                          EmployeeID: _offlineLoggedInData
                                              .details[0].employeeID
                                              .toString(),
                                          FileName: filenamepunchin,
                                          PresenceDate: selectedDate.year
                                                  .toString() +
                                              "-" +
                                              selectedDate.month.toString() +
                                              "-" +
                                              selectedDate.day.toString(),
                                          Time: selectedTime.hour.toString() +
                                              ":" +
                                              selectedTime.minute.toString(),
                                          Notes: "",
                                          Latitude: Latitude,
                                          Longitude: Longitude,
                                          LocationAddress: Address,
                                          LoginUserId: LoginUserID,
                                        )));
                              } /*else {
                                            showCommonDialogWithSingleOption(
                                                context,
                                                "Something Went Wrong File Not Found Exception!",
                                                positiveButtonTitle:
                                                    "OK");
                                          }*/
                            }
                          }
                        }
                      } else {
                        getcurrentTimeInfoFromMaindfd();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        children: [
                          Icon(
                            isPunchIn == true
                                ? Icons.file_download_done
                                : Icons.ac_unit,
                            color: isPunchIn == true
                                ? colorPresentDay
                                : colorAbsentfDay,
                            size: 42,
                          ),
                          Card(
                            elevation: 5,
                            color: PuchInTime.text == ""
                                ? colorAbsentfDay
                                : colorPresentDay,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              height: 50,
                              width: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Punch In",
                                        style: TextStyle(
                                            color: colorWhite,
                                            // <-- Change this
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isPunchIn == true
                              ? Icon(
                                  Icons.access_alarm,
                                  color: colorPrimary,
                                )
                              : Container(),
                          isPunchIn == true
                              ? Text(
                                  PuchInTime.text,
                                  style: TextStyle(
                                      fontSize: 15, color: colorPrimary),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      TimeOfDay selectedTime = TimeOfDay.now();

                      if (isCurrentTime == true) {
                        if (isPunchIn == true) {
                          if (isPunchOut == false) {
                            if (isLunchIn == true) {
                              showCommonDialogWithSingleOption(
                                  context,
                                  _offlineLoggedInData.details[0].employeeName +
                                      " \n Lunch In : " +
                                      LunchInTime.text,
                                  positiveButtonTitle: "OK");
                            } else {
                              if (ConstantMAster.toString() == "" ||
                                  ConstantMAster.toString().toLowerCase() ==
                                      "no") {
                                _dashBoardScreenBloc.add(
                                    PunchWithoutImageAttendanceSaveRequestEvent(
                                        PunchWithoutImageAttendanceSaveRequest(
                                            Mode: "lunchin",
                                            pkID: "0",
                                            EmployeeID: _offlineLoggedInData
                                                .details[0].employeeID
                                                .toString(),
                                            PresenceDate: selectedDate.year
                                                    .toString() +
                                                "-" +
                                                selectedDate.month.toString() +
                                                "-" +
                                                selectedDate.day.toString(),
                                            TimeIn: "",
                                            TimeOut: "",
                                            LunchIn: selectedTime.hour
                                                    .toString() +
                                                ":" +
                                                selectedTime.minute.toString(),
                                            LunchOut: "",
                                            LoginUserID: LoginUserID,
                                            Notes: "",
                                            Latitude: "",
                                            Longitude: "",
                                            LocationAddress: "",
                                            CompanyId: CompanyID.toString())));
                              } else {
                                final imagepicker = ImagePicker();

                                XFile file = await imagepicker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 85,
                                );

                                if (file != null) {
                                  File file1 = File(file.path);

                                  final dir = await path_provider
                                      .getTemporaryDirectory();

                                  final extension = p.extension(file1.path);

                                  int timestamp1 =
                                      DateTime.now().millisecondsSinceEpoch;

                                  String filenameLunchIn = _offlineLoggedInData
                                          .details[0].employeeID
                                          .toString() +
                                      "_" +
                                      DateTime.now().day.toString() +
                                      "_" +
                                      DateTime.now().month.toString() +
                                      "_" +
                                      DateTime.now().year.toString() +
                                      "_" +
                                      timestamp1.toString() +
                                      extension;

                                  final targetPath =
                                      dir.absolute.path + "/" + filenameLunchIn;
                                  File file1231 = await testCompressAndGetFile(
                                      file1, targetPath);
                                  final bytes =
                                      file1.readAsBytesSync().lengthInBytes;
                                  final kb = bytes / 1024;
                                  final mb = kb / 1024;

                                  print("Image File Is Largre" +
                                      " KB : " +
                                      kb.toString() +
                                      " MB : " +
                                      mb.toString());
                                  final snackBar = SnackBar(
                                    content: Text(" KB : " +
                                        kb.toString() +
                                        " MB : " +
                                        mb.toString()),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);

                                  _dashBoardScreenBloc
                                      .add(PunchAttendanceSaveRequestEvent(
                                          file1231,
                                          PunchAttendanceSaveRequest(
                                            pkID: "0",
                                            CompanyId: CompanyID.toString(),
                                            Mode: "lunchin",
                                            EmployeeID: _offlineLoggedInData
                                                .details[0].employeeID
                                                .toString(),
                                            FileName: filenameLunchIn,
                                            PresenceDate: selectedDate.year
                                                    .toString() +
                                                "-" +
                                                selectedDate.month.toString() +
                                                "-" +
                                                selectedDate.day.toString(),
                                            Time: selectedTime.hour.toString() +
                                                ":" +
                                                selectedTime.minute.toString(),
                                            Notes: "",
                                            Latitude: Latitude,
                                            Longitude: Longitude,
                                            LocationAddress: Address,
                                            LoginUserId: LoginUserID,
                                          )));
                                }
                              }
                            }
                          } else {
                            if (isLunchIn == false) {
                              showCommonDialogWithSingleOption(context,
                                  "After Punch Out, You can't be able to do Lunch In!!",
                                  positiveButtonTitle: "OK");
                            }
                          }
                        } else {
                          showCommonDialogWithSingleOption(
                              context, "Punch in Is Required !",
                              positiveButtonTitle: "OK");
                        }
                      } else {
                        getcurrentTimeInfoFromMaindfd();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            isLunchIn == true
                                ? Icons.file_download_done
                                : Icons.ac_unit,
                            color: isLunchIn == true
                                ? colorPresentDay
                                : colorAbsentfDay,
                            size: 42,
                          ),
                          Card(
                            elevation: 5,
                            color: LunchInTime.text == ""
                                ? colorAbsentfDay
                                : colorPresentDay,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              height: 50,
                              width: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Lunch In",
                                        style: TextStyle(
                                            color: colorWhite,
                                            // <-- Change this
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isLunchIn == true
                              ? Icon(
                                  Icons.access_alarm,
                                  color: colorPrimary,
                                )
                              : Container(),
                          isLunchIn == true
                              ? Text(
                                  LunchInTime.text,
                                  style: TextStyle(
                                      fontSize: 15, color: colorPrimary),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (isCurrentTime == true) {
                        lunchoutLogic();
                      } else {
                        getcurrentTimeInfoFromMaindfd();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            isLunchOut == true
                                ? Icons.file_download_done
                                : Icons.ac_unit,
                            color: isLunchOut == true
                                ? colorPresentDay
                                : colorAbsentfDay,
                            size: 42,
                          ),
                          Card(
                            elevation: 5,
                            color: LunchOutTime.text == ""
                                ? colorAbsentfDay
                                : colorPresentDay,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              height: 50,
                              width: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Lunch Out",
                                        style: TextStyle(
                                            color: colorWhite,
                                            // <-- Change this
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isLunchOut == true
                              ? Icon(
                                  Icons.access_alarm,
                                  color: colorPrimary,
                                )
                              : Container(),
                          isLunchOut == true
                              ? Text(
                                  LunchOutTime.text,
                                  style: TextStyle(
                                      fontSize: 15, color: colorPrimary),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (isCurrentTime == true) {
                        punchoutLogic();
                      } else {
                        getcurrentTimeInfoFromMaindfd();
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            isPunchOut == true
                                ? Icons.file_download_done
                                : Icons.ac_unit,
                            color: isPunchOut == true
                                ? colorPresentDay
                                : colorAbsentfDay,
                            size: 42,
                          ),
                          Card(
                            elevation: 5,
                            color: PuchOutTime.text == ""
                                ? colorAbsentfDay
                                : colorPresentDay,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              height: 50,
                              width: 100,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Punch Out",
                                        style: TextStyle(
                                            color: colorWhite,
                                            // <-- Change this
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          isPunchOut == true
                              ? Icon(
                                  Icons.access_alarm,
                                  color: colorPrimary,
                                )
                              : Container(),
                          isPunchOut == true
                              ? Text(
                                  PuchOutTime.text,
                                  style: TextStyle(
                                      fontSize: 15, color: colorPrimary),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              title: Text('Stateful Dialog'),
              actions: <Widget>[
                InkWell(
                  child: Text('OK   '),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  timeChangesEvent() {
    setState(() {
      PuchInboolcontroller.text = isPunchIn.toString();
      PuchOutboolcontroller.text = isPunchOut.toString();
      LunchInboolcontroller.text = isLunchIn.toString();
      LunchOutboolcontroller.text = isLunchOut.toString();
    });
  }
}
