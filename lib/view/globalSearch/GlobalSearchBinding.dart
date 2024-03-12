import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:whsuites_calling/view_models/controller/global_search/global_search_viewmodel.dart';


class GlobalSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GlobalSearchViewModel());
  }
}
