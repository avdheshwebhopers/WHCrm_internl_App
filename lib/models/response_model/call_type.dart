class call_type {
  Lead? lead;
  Customer? customer;

  call_type({this.lead, this.customer});

  call_type.fromJson(Map<String, dynamic> json) {
    lead = json['lead'] != null ? new Lead.fromJson(json['lead']) : null;
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lead != null) {
      data['lead'] = this.lead!.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Lead {
  String? numberBusy;
  String? answered;
  String? wrongNumber;
  String? notAnswered;
  String? meetingFixed;
  String? lookingForJob;

  Lead(
      {this.numberBusy,
        this.answered,
        this.wrongNumber,
        this.notAnswered,
        this.meetingFixed,
        this.lookingForJob});

  Lead.fromJson(Map<String, dynamic> json) {
    numberBusy = json['Number Busy'];
    answered = json['Answered'];
    wrongNumber = json['Wrong Number'];
    notAnswered = json['Not Answered'];
    meetingFixed = json['Meeting Fixed'];
    lookingForJob = json['Looking For Job'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Number Busy'] = this.numberBusy;
    data['Answered'] = this.answered;
    data['Wrong Number'] = this.wrongNumber;
    data['Not Answered'] = this.notAnswered;
    data['Meeting Fixed'] = this.meetingFixed;
    data['Looking For Job'] = this.lookingForJob;
    return data;
  }
}

class Customer {
  String? feedbackCallAnswered;
  String? notAnswered;
  String? wrongNumber;
  String? meetingFixed;
  String? numberBusy;
  String? renewalCallNotAnswered;
  String? pendingPaymentNotAnswered;
  String? renewalCallNumberBusy;
  String? answered;
  String? renewalCallAnswered;
  String? pendingPaymentAnswered;
  String? feedbackCallNotAnswered;
  String? feedbackCallNumberBusy;
  String? pendingPaymentNumberBusy;

  Customer(
      {this.feedbackCallAnswered,
        this.notAnswered,
        this.wrongNumber,
        this.meetingFixed,
        this.numberBusy,
        this.renewalCallNotAnswered,
        this.pendingPaymentNotAnswered,
        this.renewalCallNumberBusy,
        this.answered,
        this.renewalCallAnswered,
        this.pendingPaymentAnswered,
        this.feedbackCallNotAnswered,
        this.feedbackCallNumberBusy,
        this.pendingPaymentNumberBusy});

  Customer.fromJson(Map<String, dynamic> json) {
    feedbackCallAnswered = json['Feedback Call - Answered'];
    notAnswered = json['Not Answered'];
    wrongNumber = json['Wrong Number'];
    meetingFixed = json['Meeting Fixed'];
    numberBusy = json['Number Busy'];
    renewalCallNotAnswered = json['Renewal Call -Not Answered'];
    pendingPaymentNotAnswered = json['Pending Payment - Not Answered'];
    renewalCallNumberBusy = json['Renewal Call -Number Busy'];
    answered = json['Answered'];
    renewalCallAnswered = json['Renewal Call -Answered'];
    pendingPaymentAnswered = json['Pending Payment - Answered'];
    feedbackCallNotAnswered = json['Feedback Call - Not Answered'];
    feedbackCallNumberBusy = json['Feedback Call - Number Busy'];
    pendingPaymentNumberBusy = json['Pending Payment - Number Busy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Feedback Call - Answered'] = this.feedbackCallAnswered;
    data['Not Answered'] = this.notAnswered;
    data['Wrong Number'] = this.wrongNumber;
    data['Meeting Fixed'] = this.meetingFixed;
    data['Number Busy'] = this.numberBusy;
    data['Renewal Call -Not Answered'] = this.renewalCallNotAnswered;
    data['Pending Payment - Not Answered'] = this.pendingPaymentNotAnswered;
    data['Renewal Call -Number Busy'] = this.renewalCallNumberBusy;
    data['Answered'] = this.answered;
    data['Renewal Call -Answered'] = this.renewalCallAnswered;
    data['Pending Payment - Answered'] = this.pendingPaymentAnswered;
    data['Feedback Call - Not Answered'] = this.feedbackCallNotAnswered;
    data['Feedback Call - Number Busy'] = this.feedbackCallNumberBusy;
    data['Pending Payment - Number Busy'] = this.pendingPaymentNumberBusy;
    return data;
  }
}