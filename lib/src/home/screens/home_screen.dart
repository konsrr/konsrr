import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:konsrr/src/app/widgets/ads_displayer_widget.dart';
import 'package:konsrr/src/auth/controller/auth_controller.dart';
import 'package:konsrr/src/home/widgets/curated_for_you_widget.dart';
import 'package:konsrr/src/home/widgets/trending_now_widget.dart';
import 'package:konsrr/src/search/screens/search_screen.dart';

import '../../app/theme.dart';

class HomeScreen extends StatelessWidget {
  static const double adsHeightPercentage = 0.3;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => DefaultTextStyle(
        style: AppThemes.createTextTheme(Theme.of(context).textTheme).bodyText1,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, visible) {
              return [
                SliverAppBar(
                  expandedHeight: Get.height * adsHeightPercentage,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Visibility(
                      visible: visible,
                      child: AppBar(
                        title: Text('konsrr'),
                      ),
                    ),
                    titlePadding: EdgeInsets.zero,
                    background: AdsDisplayerWidget(),
                  ),
                ),
              ];
            },
            body: CustomScrollView(anchor: 0.0, slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(32.0),
                            topRight: const Radius.circular(32.0),
                          ),
                          boxShadow: [],
                        ),
                        child: SizedBox(
                          width: 60,
                          child: Center(
                            child: Container(
                              margin: EdgeInsets.only(top: 8.0),
                              height: 4,
                              width: 60,
                              decoration: BoxDecoration(
                                color: AppColors.neutralGrey,
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  _buildList(context),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  final authController = Get.find<AuthController>();

  User get user => authController.user.value;

  static double leftMargin = Get.width * 0.05;

  Widget padLeft(BuildContext context, {Widget child}) {
    return Container(
      padding: EdgeInsets.only(
        left: leftMargin,
        bottom: 2.0,
        top: 2.0,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  Widget padRight(BuildContext context, {Widget child}) {
    return Container(
      padding: EdgeInsets.only(right: leftMargin),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  List<Widget> _buildList(context) {
    return [
      padLeft(
        context,
        child: padRight(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${user?.displayName ?? ''}! 👋',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: false,
                child: InkWell(
                  onTap: () =>
                      Get.to(SearchScreen(), transition: Transition.downToUp),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(width: 1.0, color: Color(0xFFD1D0D1)),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Find your favorite concerts here...',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      padLeft(context, child: TrendingNowWidget()),
      padLeft(context, child: CuratedForYouWidget()),
      padLeft(context, child: SizedBox(height: 64.0)),
    ];
  }
}
