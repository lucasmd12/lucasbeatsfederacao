import 'package:lucasbeatsfederacao/models/role_permissions.dart';

class CustomRole {
  final String id;
  final String nome;
  final RolePermissions permissions;

  CustomRole({
    required this.id,
    required this.nome,
    required this.permissions,
  });
}

