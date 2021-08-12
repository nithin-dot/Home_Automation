class Getdata {
  int id;
  String sname;
  // ignore: non_constant_identifier_names
  String switch_zone;
  String val;

  Getdata(
      {this.id,
      this.sname,
      // ignore: non_constant_identifier_names
      this.switch_zone,
      this.val});

  factory Getdata.fromJson(Map<String, dynamic> json) {
    return Getdata(
        id: json["id"],
        sname: json["sname"],
        switch_zone: json["switch_zone"],
        val: json["val"]);
  }
}
