import 'package:big_decimal/big_decimal.dart';
import 'package:hive/hive.dart';

class BigDecimalAdapter extends TypeAdapter<BigDecimal> {
  @override
  final int typeId = 2;

  @override
  BigDecimal read(BinaryReader reader) {
    final value = reader.readString();
    return BigDecimal.parse(value);
  }

  @override
  void write(BinaryWriter writer, BigDecimal obj) {
    writer.writeString(obj.toString());
  }
}
