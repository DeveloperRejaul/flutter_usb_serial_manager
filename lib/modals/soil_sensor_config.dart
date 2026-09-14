/// Configuration for a Modbus soil sensor, mirrors native `SoilSensorConfig`.
class SoilSensorConfig {
  final int slaveId;
  final int startAddress;
  final int registerCount;
  final int responseDelayMs;

  const SoilSensorConfig({
    this.slaveId = 1,
    this.startAddress = 0x0000,
    this.registerCount = 8,
    this.responseDelayMs = 300,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slaveId': slaveId,
      'startAddress': startAddress,
      'registerCount': registerCount,
      'responseDelayMs': responseDelayMs,
    };
  }

  @override
  String toString() =>
      'SoilSensorConfig(slaveId: $slaveId, startAddress: $startAddress, '
      'registerCount: $registerCount, responseDelayMs: $responseDelayMs)';
}
