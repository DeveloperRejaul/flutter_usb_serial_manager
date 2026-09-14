/// Configuration for raw serial reads, mirrors native `RawReadConfig`.
class RawReadConfig {
  final int bufferSize;
  final int timeout;

  const RawReadConfig({
    this.bufferSize = 1024,
    this.timeout = 1000,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bufferSize': bufferSize,
      'timeout': timeout,
    };
  }

  @override
  String toString() => 'RawReadConfig(bufferSize: $bufferSize, timeout: $timeout)';
}
