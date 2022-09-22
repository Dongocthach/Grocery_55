class Grocery {
  final int? id;
  final String masp;
  final String name;
  final double dongia;
  final String donvi;
  Grocery({this.id,required this.masp, required this.name, required this.dongia, required this.donvi});
  factory Grocery.fromMap(Map<String, dynamic> json) => new Grocery(
        id: json['id'],
        masp: json['masp'],
        name: json['name'],
        dongia: json['dongia'],
        donvi: json['donvi'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'masp': masp,
      'name': name,
      'dongia': dongia,
      'donvi': donvi,
    };
  }

 
}
