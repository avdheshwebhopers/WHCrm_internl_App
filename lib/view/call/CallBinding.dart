
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:whsuites_calling/view/call/CallControllers.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/customer_detail_viewmodel.dart';
import 'package:whsuites_calling/view_models/controller/call_detail/lead_detail_viewmodel.dart';
import 'package:whsuites_calling/view_models/controller/call_type/call_type_viewmodel.dart';


class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LeadDetailsViewModel());
    Get.put(CustomerDetailsViewModel());
    Get.put(CallTypeViewmodel());
    Get.lazyPut<CallControllers>(
          () => CallControllers(),
    );
  }
}



