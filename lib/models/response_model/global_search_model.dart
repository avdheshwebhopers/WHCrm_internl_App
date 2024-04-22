
class GlobalSearch {
  List<CustomerResult>? customerResult;
  List<LeadResult>? leadResult;

  GlobalSearch({this.customerResult, this.leadResult});

  GlobalSearch.fromJson(Map<String, dynamic> json) {
    if (json['customerResult'] != null) {
      customerResult = <CustomerResult>[];
      json['customerResult'].forEach((v) {
        customerResult!.add(CustomerResult.fromJson(v));
      });
    }

    if (json['leadResult'] != null) {
      leadResult = <LeadResult>[];
      json['leadResult'].forEach((v) {
        leadResult!.add(LeadResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (customerResult != null) {
      data['customerResult'] = customerResult!.map((v) => v.toJson()).toList();
    }
    if (leadResult != null) {
      data['leadResult'] = leadResult!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerResult {
  String? id;
  String? firstName;
  String? lastName;
  String? primaryEmail;
  String? primaryContact;

  CustomerResult({this.id, this.firstName, this.lastName, this.primaryEmail, this.primaryContact});

  CustomerResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    primaryEmail = json['primary_email'];
    primaryContact = json['primary_contact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['primary_email'] = primaryEmail;
    data['primary_contact'] = primaryContact;
    return data;
  }
}

class LeadResult {
  String? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? email;

  LeadResult({this.id, this.firstName, this.lastName, this.mobile, this.email});

  LeadResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['mobile'] = mobile;
    data['email'] = email;
    return data;
  }
}