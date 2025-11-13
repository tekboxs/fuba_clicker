class AvatarHelper {
  static const List<String> availableAvatars = [
    'assets/avatars/avatar.png',
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
    'assets/avatars/avatar9.png',
    'assets/avatars/avatar10.png',
  ];

  static String getDefaultAvatar() {
    return availableAvatars[0];
  }

  static bool isValidAvatar(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return false;
    return availableAvatars.contains(avatarPath);
  }

  static String getAvatarPath(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return getDefaultAvatar();
    }
    if (isValidAvatar(profilePicture)) {
      return profilePicture;
    }
    return getDefaultAvatar();
  }
}
