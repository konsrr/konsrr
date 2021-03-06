import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:konsrr/src/app/constants.dart';
import 'package:konsrr/src/app/models/booking.dart';
import 'package:konsrr/src/app/models/concert.dart';
import 'package:konsrr/src/app/models/my_user.dart';
import 'package:konsrr/src/app/screens/profile_screen.dart';
import 'package:konsrr/src/app/widgets/confirm_payment_widget.dart';
import 'package:konsrr/src/auth/controller/auth_controller.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BookingScreen extends StatefulWidget {
  final Booking booking;

  const BookingScreen({Key key, this.booking}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Concert get concert => widget.booking.concert;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Booking',
            style: Theme.of(context).primaryTextTheme.subtitle2),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: Column(
            children: [
              SizedBox(height: 16.0),
              _buildConcertCard(context),
              SizedBox(height: 16.0),
              _buildBookingDetailsCard(context),
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConcertCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: [
          Container(
            height: 120.0,
            decoration: concert.imageUrl != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(concert.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          Container(
              margin: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concert.name,
                    style: Theme.of(context).primaryTextTheme.subtitle2,
                  ),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).hintColor,
                  ),
                  Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 16.0),
                    SizedBox(width: 8.0),
                    Text(
                      concert.rangeInWIB,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).primaryTextTheme.caption.fontSize,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ])
                ],
              )),
        ],
      ),
    );
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController;
  TextEditingController phoneController;
  TextEditingController dateController;
  TextEditingController addressController;
  TextEditingController identificationNumberController;

  User get firebaseUser => Get.find<AuthController>().user.value;

  MyUser get myUser => Get.find<AuthController>().myUser.value;

  AuthController get authController => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: myUser?.name ?? firebaseUser.displayName);
    phoneController = TextEditingController(text: myUser?.phoneNumber ?? "");
    dateController = TextEditingController(text: myUser?.birthDate ?? "");
    addressController = TextEditingController(text: myUser?.address ?? "");
    identificationNumberController =
        TextEditingController(text: myUser?.identificationNumber ?? "");
  }

  String Function(String) nonEmptyValidator(String fieldName) => (String val) {
        if (val?.isEmpty ?? false) {
          return "$fieldName can't be empty!";
        }
        return null;
      };

  bool isSubmitting = false;

  DateTime birthDate;

  Future handle(context) async {
    setState(() {
      isSubmitting = true;
    });
    if (formKey.currentState.validate()) {
      final user = MyUser()
        ..name = nameController.value.text
        ..identificationNumber = identificationNumberController.value.text
        ..phoneNumber = phoneController.value.text
        ..email = firebaseUser.email
        ..address = addressController.value.text
        ..birthDate = dateController.value.text;
      await authController.myUserDocument.set(user.toData());
      showMaterialModalBottomSheet(
        context: context,
        builder: (context, _) => ConfirmPaymentWidget(booking: widget.booking),
      );
    }
    setState(() {
      isSubmitting = false;
    });
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Details',
              style: Theme.of(context).accentTextTheme.bodyText1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  Text('Name',
                      style: Theme.of(context).accentTextTheme.bodyText1),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        hintText: "Full Name (e.g: Budi Raharja)"),
                    validator: nonEmptyValidator('Name'),
                  ),
                  SizedBox(height: 16.0),
                  Text('Identity Number (KTP/SIM/Passport/Student ID)',
                      style: Theme.of(context).accentTextTheme.bodyText1),
                  TextFormField(
                    controller: identificationNumberController,
                    decoration: InputDecoration(
                        hintText: "KTP/SIM/Passport/Student ID"),
                    validator: nonEmptyValidator('Identity Number'),
                  ),
                  SizedBox(height: 16.0),
                  Text('Phone Number',
                      style: Theme.of(context).accentTextTheme.bodyText1),
                  TextFormField(
                    controller: phoneController,
                    validator: (String val) {
                      final nonEmptyValidation =
                          nonEmptyValidator('Phone Number')(val);
                      if (nonEmptyValidation?.isEmpty ?? true) {
                        if (GetUtils.isPhoneNumber(val)) {
                          return null;
                        }
                        return "Phone Number is not valid";
                      }
                      return nonEmptyValidation;
                    },
                    decoration: InputDecoration(
                        hintText: "Phone Number (e.g: +6281123010123)"),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.0),
                  Text('Birth Date',
                      style: Theme.of(context).accentTextTheme.bodyText1),
                  TextFormField(
                      controller: dateController,
                      validator: (String val) {
                        final nonEmptyResult =
                            nonEmptyValidator('Birth Date')(val);
                        if (nonEmptyResult?.isEmpty ?? true) {
                          if (!birthDateRegEx.hasMatch(val)) {
                            return "Birth date must follow yyyy-mm-dd format (e.g: 1998-08-08)";
                          }
                          return null;
                        }
                        return nonEmptyResult;
                      },
                      keyboardType: TextInputType.text),
                  SizedBox(height: 16.0),
                  Text('Shipping Address',
                      style: Theme.of(context).accentTextTheme.bodyText1),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                        hintText:
                            "Full Address (e.g: Jalan Margonda Raya No. 1, Kukusan, Beji, Depok, 68145"),
                    validator: nonEmptyValidator('Address'),
                    maxLines: 5,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : () => handle(context),
                    child: isSubmitting
                        ? Center(
                            child: SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator()))
                        : Text('CONTINUE TO PAYMENT'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget priceWidget(String title, int price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            flex: 4,
            child: Text('$title',
                style: Theme.of(context).accentTextTheme.subtitle2)),
        Flexible(
          flex: 1,
          child: Text('Rp$price',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.caption.fontSize,
              )),
        )
      ],
    );
  }

  Widget _buildBookingDetailsCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(
                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                  ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 8.0),
            priceWidget(
              concert.name,
              concert.price.round(),
            ),
            ...[
              for (var merchandise in widget.booking.merchandises)
                priceWidget(merchandise.name, merchandise.price.round()),
            ],
            Divider(
              color: Theme.of(context).hintColor,
              thickness: 2,
            ),
            priceWidget('Total', widget.booking.totalPrice.round()),
          ],
        ),
      ),
    );
  }
}
