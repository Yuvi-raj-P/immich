//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AlbumUserResponseDto {
  /// Returns a new [AlbumUserResponseDto] instance.
  AlbumUserResponseDto({
    required this.role,
    required this.user,
  });

  AlbumUserRole role;

  UserResponseDto user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumUserResponseDto && other.role == role && other.user == user;

  @override
  int get hashCode =>
      // ignore: unnecessary_parenthesis
      (role.hashCode) + (user.hashCode);

  @override
  String toString() => 'AlbumUserResponseDto[role=$role, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json[r'role'] = this.role;
    json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [AlbumUserResponseDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AlbumUserResponseDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return AlbumUserResponseDto(
        role: AlbumUserRole.fromJson(json[r'role'])!,
        user: UserResponseDto.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<AlbumUserResponseDto> listFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final result = <AlbumUserResponseDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AlbumUserResponseDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AlbumUserResponseDto> mapFromJson(dynamic json) {
    final map = <String, AlbumUserResponseDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AlbumUserResponseDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AlbumUserResponseDto-objects as value to a dart map
  static Map<String, List<AlbumUserResponseDto>> mapListFromJson(
    dynamic json, {
    bool growable = false,
  }) {
    final map = <String, List<AlbumUserResponseDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AlbumUserResponseDto.listFromJson(
          entry.value,
          growable: growable,
        );
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'role',
    'user',
  };
}
