import 'dart:convert';


class UsbDevice {
  final String vendorId;
  final int productId;
  final int manufacturer;
  UsbDevice({
    required this.vendorId,
    required this.productId,
    required this.manufacturer,
  });
  


  UsbDevice copyWith({
    String? vendorId,
    int? productId,
    int? manufacturer,
  }) {
    return UsbDevice(
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'vendorId': vendorId});
    result.addAll({'productId': productId});
    result.addAll({'manufacturer': manufacturer});
  
    return result;
  }

  factory UsbDevice.fromMap(Map<String, dynamic> map) {
    return UsbDevice(
      vendorId: map['vendorId'] ?? '',
      productId: map['productId']?.toInt() ?? 0,
      manufacturer: map['manufacturer']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UsbDevice.fromJson(String source) => UsbDevice.fromMap(json.decode(source));

  @override
  String toString() => 'UsbDevice(vendorId: $vendorId, productId: $productId, manufacturer: $manufacturer)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UsbDevice &&
      other.vendorId == vendorId &&
      other.productId == productId &&
      other.manufacturer == manufacturer;
  }

  @override
  int get hashCode => vendorId.hashCode ^ productId.hashCode ^ manufacturer.hashCode;
}
