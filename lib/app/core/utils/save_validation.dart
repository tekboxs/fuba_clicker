import '../../models/rebirth_data.dart';
import '../../models/game_save_data.dart';
import '../../models/user_data.dart';

class SaveValidation {
  static bool isLocalSaveSmaller(GameSaveData localSave, UserData cloudSave) {
    final cloudRebirthData = RebirthData.fromJson(cloudSave.rebirthData ?? {});

    if (cloudRebirthData.rebirthCount > localSave.rebirthData.rebirthCount) {
      return true;
    }

    if (cloudRebirthData.ascensionCount >
        localSave.rebirthData.ascensionCount) {
      return true;
    }

    if (cloudRebirthData.transcendenceCount >
        localSave.rebirthData.transcendenceCount) {
      return true;
    }

    return false;
  }
}
