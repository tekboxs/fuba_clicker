import 'package:hive/hive.dart';
import '../core/utils/efficient_number.dart';

class EfficientNumberAdapter extends TypeAdapter<EfficientNumber> {
  @override
  final int typeId = 2;

  @override
  EfficientNumber read(BinaryReader reader) {
    final value = reader.readString();
    return EfficientNumber.parse(value);
  }

  @override
  void write(BinaryWriter writer, EfficientNumber obj) {
    writer.writeString(obj.toString());
  }
}


