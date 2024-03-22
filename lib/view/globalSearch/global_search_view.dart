import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  GlobalSearchViewModel viewModel = GlobalSearchViewModel();
  bool _searchClicked = false;
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    viewModel = Get.put(GlobalSearchViewModel());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  void _onSearchTextChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Debounce the search function
      setState(() {
        _searchClicked = false;
      });
    });
  }

  void _onSearchButtonClicked() {
    setState(() {
      _searchClicked = true;
      _showTabs = true;
      viewModel.search(
          _searchController.text); // Perform search when search icon is clicked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10.h,
        centerTitle: false,
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _onSearchButtonClicked,
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
          if (_showTabs && _searchClicked)
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: Column(
                  children: [
                    Container(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Customer details',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 5),
                                // Add spacing between text and count
                                Obx(() =>
                                    Text(
                                      '(${viewModel.customerResult.length})',
                                      // Display count dynamically
                                      style: TextStyle(fontSize: 16.sp),
                                    )),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lead Details',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 5),
                                // Add spacing between text and count
                                Obx(() =>
                                    Text(
                                      '(${viewModel.leadResult.length})',
                                      // Display count dynamically
                                      style: TextStyle(fontSize: 16.sp),
                                    )),
                              ],
                            ),
                          ),
                        ],
                        controller: _tabController,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: ScrollPhysics(),
                        controller: _tabController,
                        children: <Widget>[
                          Obx(() =>
                          viewModel.isLoading.value ? const Center(
                              child: CircularProgressIndicator())
                              : CustomerDetailsTab(
                              data: viewModel.getCustomerData())),
                          Obx(() =>
                          viewModel.isLoading.value ? const Center(
                              child: CircularProgressIndicator())
                              : LeadDetailsTab(data: viewModel.getLeadData())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}