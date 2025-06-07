class RolePermissions {
  final bool canManageMembers;
  final bool canCreateChannels;
  final bool canDeleteMessages;
  final bool canKickMembers;

  RolePermissions({
    this.canManageMembers = false,
    this.canCreateChannels = false,
    this.canDeleteMessages = false,
    this.canKickMembers = false,
  });
}

