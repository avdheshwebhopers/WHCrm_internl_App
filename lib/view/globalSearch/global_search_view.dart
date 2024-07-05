import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/colors/app_color.dart';
import '../../view_models/controller/global_search/global_search_viewmodel.dart';
import 'CustomerDetailsTab.dart';
import 'LeadDetailsTab.dart';

class GlobalSearchScreen extends StatefulWidget {
  @override
  _GlobalSearchScreenState createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showTabs = false;
  GlobalSearchViewModel viewModel = GlobalSearchViewModel();
  bool _searchClicked = false;
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late String _directoryPath; // Variable to store the directory path


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    viewModel = Get.put(GlobalSearchViewModel());
    _directoryPath = Get.arguments; // Retrieve directory path from route arguments
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
      setState(() {
        _searchClicked = false;
      });
    });
  }

  void _onSearchButtonClicked() {
    setState(() {
      _searchClicked = true;
      _showTabs = true;
      viewModel.search(_searchController.text); // Perform search when search icon is clicked
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Global Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
            if (_showTabs && _searchClicked)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10,top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                      ),
                      child: TabBar(
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: Colors.black54,
                        labelStyle: TextStyle(fontSize: 16),
                        dividerColor: Colors.transparent,
                        tabs: <Widget>[
                          Tab(
                            child: Obx(() =>
                                Text(
                                  'Customer details \n(${viewModel.customerResult.length})',
                                  style: TextStyle(fontSize: 16),
                                )),
                          ),
                          Tab(
                            child: Obx(() =>
                                Text(
                                  'Lead Details\n(${viewModel.leadResult.length})',
                                  // Display count dynamically
                                  style: TextStyle(fontSize: 16),
                                )),
                          ),
                        ],
                        controller: _tabController,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const ScrollPhysics(),
                        controller: _tabController,
                        children: <Widget>[
                          Obx(() => viewModel.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : CustomerDetailsTab(
                              directoryPath: _directoryPath,
                              data: viewModel.getCustomerData())),
                          Obx(() => viewModel.isLoading.value
                              ? const Center(child: CircularProgressIndicator())
                              : LeadDetailsTab(
                              directoryPath: _directoryPath,
                              data: viewModel.getLeadData())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
