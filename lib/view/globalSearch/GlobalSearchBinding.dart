import 'package:get/get.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/lead_detail_viewmodel.dart';
import 'package:whsuites_calling/view_models/controller/global_search/global_search_viewmodel.dart';

import '../../view_models/controller/call_type/call_type_viewmodel.dart';


class GlobalSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LeadDetailsViewModel());
    Get.put(CallTypeViewmodel());
    Get.lazyPut(() => GlobalSearchViewModel());
  }
}
