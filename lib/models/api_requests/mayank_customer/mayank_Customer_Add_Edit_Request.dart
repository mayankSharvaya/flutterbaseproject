/*CustomerId:0
CustomerName:Morari Dham
CustomerType:Customer
Address:9, Nandanvan Industrial Estate, Near Mahakali Mandir road, Bakrol Dhamatvan Road, Dhamatvan, Ahemdab
Area:Bakrol
CityCode:12
StateCode:350
PinCode:
ContactNo1:7082451657
ContactNo2:
EmailAddress:info@dolphin.com
GSTNO:
GSTNO:
LoginUserID:maulik
WebsiteAddress:www.dolphin.com
Latitude:234344
Longitude:2134232
CountryCode:IND
BlockCustomer:
CustomerSourceID:
CompanyId:4132
CustomerAddEditListScreenRequest*/

class CustomerAddEditListScreenRequest {
  String customerID;
  String customerName;
  String customerType;
  String address;
  String area;
  String pinCode;
  String cityCode;
  String gSTNo;
  String pANNo;
  String contactNo1;
  String contactNo2;
  String emailAddress;
  String websiteAddress;
  String latitude;
  String longitude;
  String loginUserID;
  String countryCode;
  String blockCustomer;
  String customerSourceID;
  String companyId;
  String stateCode;

  CustomerAddEditListScreenRequest({
    this.customerID,
    this.customerName,
    this.customerType,
    this.address,
    this.area,
    this.pinCode,
    this.cityCode,
    this.gSTNo,
    this.pANNo,
    this.contactNo1,
    this.contactNo2,
    this.emailAddress,
    this.websiteAddress,
    this.latitude,
    this.longitude,
    this.loginUserID,
    this.countryCode,
    this.stateCode,
    this.blockCustomer,
    this.customerSourceID,
    this.companyId,
  });

  CustomerAddEditListScreenRequest.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerId'];
    customerName = json['CustomerName'];
    customerType = json['CustomerType'];
    address = json['Address'];
    area = json['Area'];
    cityCode = json['CityCode'];
    stateCode = json['StateCode'];
    pinCode = json['PinCode'];
    contactNo1 = json['ContactNo1'];
    contactNo2 = json['ContactNo2'];
    emailAddress = json['EmailAddress'];

    gSTNo = json['GSTNO'];
    pANNo = json['PANNO'];
    loginUserID = json['LoginUserID'];

    websiteAddress = json['WebsiteAddress'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    countryCode = json['CountryCode'];
    blockCustomer = json['BlockCustomer'];
    customerSourceID = json['CustomerSourceID'];
    companyId = json['CompanyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustomerId'] = this.customerID;
    data['CustomerName'] = this.customerName;
    data['CustomerType'] = this.customerType;
    data['Address'] = this.address;
    data['Area'] = this.area;
    data['PinCode'] = this.pinCode;
    data['CityCode'] = this.cityCode;
    data['GSTNO'] = this.gSTNo;
    data['PANNO'] = this.pANNo;
    data['ContactNo1'] = this.contactNo1;
    data['ContactNo2'] = this.contactNo2;
    data['EmailAddress'] = this.emailAddress;
    data['WebsiteAddress'] = this.websiteAddress;
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    data['LoginUserID'] = this.loginUserID;
    data['CountryCode'] = this.countryCode;
    data['BlockCustomer'] = this.blockCustomer;
    data['CustomerSourceID'] = this.customerSourceID;
    data['CompanyId'] = this.companyId;
    data['StateCode'] = this.stateCode;
    return data;
  }
}
