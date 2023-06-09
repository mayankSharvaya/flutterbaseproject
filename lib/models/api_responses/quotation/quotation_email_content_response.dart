class QuotationEmailContentResponse {
  List<QuotationEmailContentResponseDetails> details;
  int totalCount;

  QuotationEmailContentResponse({this.details, this.totalCount});

  QuotationEmailContentResponse.fromJson(Map<String, dynamic> json) {
    if (json['details'] != null) {
      details = [];
      json['details'].forEach((v) {
        details.add(new QuotationEmailContentResponseDetails.fromJson(v));
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

class QuotationEmailContentResponseDetails {
  int rowNum;
  int pkID;
  String subject;
  String contentData;

  QuotationEmailContentResponseDetails(
      {this.rowNum, this.pkID, this.subject, this.contentData});

  QuotationEmailContentResponseDetails.fromJson(Map<String, dynamic> json) {
    rowNum = json['RowNum'] == null ? 0 : json['RowNum'];
    pkID = json['pkID'] == null ? 0 : json['pkID'];
    subject = json['Subject'] == null ? "" : json['Subject'];
    contentData = json['ContentData'] == null ? "" : json['ContentData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RowNum'] = this.rowNum;
    data['pkID'] = this.pkID;
    data['Subject'] = this.subject;
    data['ContentData'] = this.contentData;
    return data;
  }
}
