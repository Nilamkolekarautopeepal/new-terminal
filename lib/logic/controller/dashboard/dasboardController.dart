// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:terminal/AppPreferences/app_areferences.dart';
// import 'package:terminal/api/app_envirments.dart';
// import 'package:terminal/api/app_urls.dart';
// import 'package:terminal/utils/snackbar_widget.dart';

// class DashboardController extends GetxController {
//   RxString lable = "DASHBOARD".obs;
//   RxBool isLoading = false.obs;
//   RxString selectedGroup = "".obs;

//   RxInt totalMembers = 0.obs;
//   RxInt verifiedMembers = 0.obs;
//   RxInt ungroupedMembers = 0.obs;
//   RxInt pendingVerification = 0.obs;

//   RxInt todaysCollection = 0.obs;
//   RxInt dueReport = 0.obs;
//   RxInt assignedGroup = 0.obs;
//   RxInt collectionByCash = 0.obs;

//   RxString fullName = "".obs;
//   RxString email = "".obs;

//   @override
//   void onInit() async {
//     loadFullName();
//     getLoanMemberCount();
//     getTotalLoanCount();
//     super.onInit();
//   }

//   void loadFullName() async {
//     final name = await AppPreferences.getName();
//     final emailId = await AppPreferences.getEmailId();
//     fullName.value = name ?? "-";
//     email.value = emailId ?? "-";
//   }

//   getLoanMemberCount() async {
//     final token = await AppPreferences.getToken();
//     isLoading.value = true;
//     try {
//       final response = await http.get(
//         Uri.parse(AppEnvironment.baseUrl + AppURLs.loanMemberCount),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": token!,
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final message = Message.fromJson(data['message']);

//         totalMembers.value = message.loanMembers ?? 0;
//         verifiedMembers.value = message.verifiedCount ?? 0;
//         ungroupedMembers.value = message.withoutGroupCount ?? 0;
//         pendingVerification.value = message.nonVerifiedCount ?? 0;
//       } else {
//         final Map<String, dynamic> errormsg = jsonDecode(response.body);
//         String msg = errormsg['message']['msg'];
//         CustomSnackBar.show(isIssue: true, message: msg);
//       }
//     } catch (e) {
//       CustomSnackBar.show(isIssue: true, message: "$e");
//       print("Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   getTotalLoanCount() async {
//     final token = await AppPreferences.getToken();
//     isLoading.value = true;
//     try {
//       final response = await http.get(
//         Uri.parse(AppEnvironment.baseUrl + AppURLs.totalLoanCount),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": token!,
//         },
//       );
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final message = TotalLoanCountMessage.fromJson(data['message']);

//         todaysCollection.value = message.totalLoans ?? 0;
//         dueReport.value = (message.totalRepaymentAmount ?? 0.0).toInt();
//         assignedGroup.value = message.approvedLoans ?? 0;
//         collectionByCash.value = message.totalEmis ?? 0;
//       } else {
//         final Map<String, dynamic> errormsg = jsonDecode(response.body);
//         String msg = errormsg['message']['msg'];
//         CustomSnackBar.show(isIssue: true, message: msg);
//       }
//     } catch (e) {
//       CustomSnackBar.show(isIssue: true, message: "$e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
  // Future<void> selectDate(BuildContext context,
  //     TextEditingController controller, RxString selectedDate) async {
  //   DateTime initialDate = controller.text.isNotEmpty
  //       ? DateTime.tryParse(controller.text) ?? DateTime.now()
  //       : DateTime.now();

  //   List<DateTime?>? picked = await showCalendarDatePicker2Dialog(
  //     context: context,
  //     config: CalendarDatePicker2WithActionButtonsConfig(
  //       calendarType: CalendarDatePicker2Type.single,
  //       okButtonTextStyle: const TextStyle(color: Colors.black),
  //       cancelButtonTextStyle: const TextStyle(color: Colors.black),
  //       selectedDayHighlightColor: Colors.grey,
  //       dayTextStyle: const TextStyle(color: Colors.black),
  //       firstDate: DateTime(2000),
  //       lastDate: DateTime.now(),
  //       currentDate: initialDate,
  //     ),
  //     dialogSize: const Size(350, 400),
  //     borderRadius: BorderRadius.circular(15),
  //   );

  //   if (picked != null && picked.isNotEmpty && picked.first != null) {
  //     String formatted = DateFormat('yyyy-MM-dd').format(picked.first!);
  //     controller.text = formatted;
  //     selectedDate.value = formatted;
  //   }
  // }