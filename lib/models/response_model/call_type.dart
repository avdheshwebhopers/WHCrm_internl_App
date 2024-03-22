
class CallType {
  Map<String, dynamic>? lead;
  Map<String, dynamic>? customer;

  CallType({this.lead, this.customer});

  CallType.fromJson(Map<String, dynamic> json) {
    lead = json['lead'] != null ? Map<String, dynamic>.from(json['lead']) : null;
    customer = json['customer'] != null ? Map<String, dynamic>.from(json['customer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (lead != null) data['lead'] = lead;
    if (customer != null) data['customer'] = customer;
    return data;
  }
}

