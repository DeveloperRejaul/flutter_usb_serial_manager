import 'dart:convert';

class UsbDevice {
  final int vendorId;
  final int productId;
  final String? manufacturer;

  const UsbDevice({
    required this.vendorId,
    required this.productId,
    this.manufacturer,
  });

  UsbDevice copyWith({
    int? vendorId,
    int? productId,
    String? manufacturer,
  }) {
    return UsbDevice(
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'vendorId': vendorId,
      'productId': productId,
      'manufacturer': manufacturer,
    };
  }

  factory UsbDevice.fromMap(Map<String, dynamic> map) {
    return UsbDevice(
      vendorId: (map['vendorId'] as num?)?.toInt() ?? 0,
      productId: (map['productId'] as num?)?.toInt() ?? 0,
      manufacturer: map['manufacturer'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UsbDevice.fromJson(String source) =>
      UsbDevice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UsbDevice(vendorId: $vendorId, productId: $productId, manufacturer: $manufacturer)';

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
