class AccuraBathComplaintNoToDeleteImageVideoResponse {
  List<AccuraBathComplaintNoToDeleteImageVideoResponseDetails> details;
  int totalCount;

  AccuraBathComplaintNoToDeleteImageVideoResponse(
      {this.details, this.totalCount});

  AccuraBathComplaintNoToDeleteImageVideoResponse.fromJson(
      Map<String, dynamic> json) {
    if (json['details'] != null) {
      details = [];
      json['details'].forEach((v) {
        details.add(
            new AccuraBathComplaintNoToDeleteImageVideoResponseDetails.fromJson(
                v));
      });
    }
    totalCount = json['TotalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.details != null) {
      data['details'] = this.details.map((v) => v.toJson()).toList();
    }
    data['TotalCount'] = this.totalCount;
    return data;
  }
}

class AccuraBathComplaintNoToDeleteImageVideoResponseDetails {
  int column1;
  String column2;
  String column3;

  AccuraBathComplaintNoToDeleteImageVideoResponseDetails(
      {this.column1, this.column2, this.column3});

  AccuraBathComplaintNoToDeleteImageVideoResponseDetails.fromJson(
      Map<String, dynamic> json) {
    column1 = json['Column1'];
    column2 = json['Column2'];
    column3 = json['Column3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Column1'] = this.column1;
    data['Column2'] = this.column2;
    data['Column3'] = this.column3;

    return data;
  }
}
