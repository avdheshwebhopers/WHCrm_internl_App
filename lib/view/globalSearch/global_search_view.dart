
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../res/colors/app_color.dart';
import '../../view_models/controller/global_search/global_search_viewmodel.dart';
import 'CustomerDetailsTab.dart';
import 'LeadDetailsTab.dart';


class GlobalSearchScreen extends StatefulWidget {
  @override
  _GlobalSearchScreenState createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTabs = false;
  GlobalSearchViewModel viewModel = GlobalSearchViewModel(); // Flag to control visibility of tab views

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    viewModel = Get.put(GlobalSearchViewModel());
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
      }

  void _onSearchTextChanged(String value) {
    viewModel.search(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10.h,
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Global Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 5.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _showTabs = !_showTabs; // Toggle visibility
                          });
                        },
                        icon: Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    onChanged: _onSearchTextChanged,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _showTabs, // Show tab views only if _showTabs is true
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.0.h),
              child: Container(
                height: 7.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0.h),
                  color: Colors.transparent,
                ),
                child: TabBar(
                  splashFactory: NoSplash.splashFactory,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: TextStyle(fontSize: 16.sp),
                  dividerColor: Colors.transparent,
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        'Customer details',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Lead Details',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                  controller: _tabController,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showTabs, // Show tab views only if _showTabs is true
            child: Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: TabBarView(
                  physics: ScrollPhysics(),
                  controller: _tabController,
                  children: <Widget>[
                    Obx(() =>
                    viewModel.isLoading.value? const Center(child: CircularProgressIndicator())
                        : CustomerDetailsTab(data: viewModel.getCustomerData())),
                    Obx(() =>
                    viewModel.isLoading.value? const Center(child: CircularProgressIndicator())
                        :LeadDetailsTab(data: viewModel.getLeadData())),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}