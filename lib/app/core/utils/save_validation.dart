import '../../models/rebirth_data.dart';
import '../../models/game_save_data.dart';
import '../../models/user_data.dart';

class SaveValidation {
  static int _getTotalRebirths(RebirthData rebirthData) {
    return rebirthData.rebirthCount +
        rebirthData.ascensionCount +
        rebirthData.transcendenceCount;
  }

  static int _getCloudRebirths(UserData userData) {
    if (userData.rebirthData == null) return 0;
    
    final rebirthCount = userData.rebirthData!['rebirthCount'] as int? ?? 0;
    final ascensionCount = userData.rebirthData!['ascensionCount'] as int? ?? 0;
    final transcendenceCount = userData.rebirthData!['transcendenceCount'] as int? ?? 0;
    
    return rebirthCount + ascensionCount + transcendenceCount;
  }

  static bool isLocalSaveSmaller(GameSaveData localSave, UserData cloudSave) {
    final localRebirths = _getTotalRebirths(localSave.rebirthData);
    final cloudRebirths = _getCloudRebirths(cloudSave);
    
    return localRebirths < cloudRebirths;
  }

  static RebirthData getCloudRebirthData(UserData userData) {
    if (userData.rebirthData == null) {
      return const RebirthData();
    }
    
    return RebirthData.fromJson(userData.rebirthData!);
  }
}

