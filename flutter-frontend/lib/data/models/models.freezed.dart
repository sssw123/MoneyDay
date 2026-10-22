// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 int get id; String get username; String get role; String get status; bool get mustChangePassword; String? get createdAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,role,status,mustChangePassword,createdAt);

@override
String toString() {
  return 'UserProfile(id: $id, username: $username, role: $role, status: $status, mustChangePassword: $mustChangePassword, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 int id, String username, String role, String status, bool mustChangePassword, String? createdAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? role = null,Object? status = null,Object? mustChangePassword = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username,  String role,  String status,  bool mustChangePassword,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.status,_that.mustChangePassword,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username,  String role,  String status,  bool mustChangePassword,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.username,_that.role,_that.status,_that.mustChangePassword,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username,  String role,  String status,  bool mustChangePassword,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.username,_that.role,_that.status,_that.mustChangePassword,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({this.id = 0, this.username = '', this.role = 'USER', this.status = 'ACTIVE', this.mustChangePassword = false, this.createdAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String username;
@override@JsonKey() final  String role;
@override@JsonKey() final  String status;
@override@JsonKey() final  bool mustChangePassword;
@override final  String? createdAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,role,status,mustChangePassword,createdAt);

@override
String toString() {
  return 'UserProfile(id: $id, username: $username, role: $role, status: $status, mustChangePassword: $mustChangePassword, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String username, String role, String status, bool mustChangePassword, String? createdAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? role = null,Object? status = null,Object? mustChangePassword = null,Object? createdAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LoginResult {

 String get token; String get expiresAt; UserProfile get user;
/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResultCopyWith<LoginResult> get copyWith => _$LoginResultCopyWithImpl<LoginResult>(this as LoginResult, _$identity);

  /// Serializes this LoginResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResult&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,expiresAt,user);

@override
String toString() {
  return 'LoginResult(token: $token, expiresAt: $expiresAt, user: $user)';
}


}

/// @nodoc
abstract mixin class $LoginResultCopyWith<$Res>  {
  factory $LoginResultCopyWith(LoginResult value, $Res Function(LoginResult) _then) = _$LoginResultCopyWithImpl;
@useResult
$Res call({
 String token, String expiresAt, UserProfile user
});


$UserProfileCopyWith<$Res> get user;

}
/// @nodoc
class _$LoginResultCopyWithImpl<$Res>
    implements $LoginResultCopyWith<$Res> {
  _$LoginResultCopyWithImpl(this._self, this._then);

  final LoginResult _self;
  final $Res Function(LoginResult) _then;

/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? expiresAt = null,Object? user = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile,
  ));
}
/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get user {
  
  return $UserProfileCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginResult].
extension LoginResultPatterns on LoginResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResult value)  $default,){
final _that = this;
switch (_that) {
case _LoginResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResult value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  String expiresAt,  UserProfile user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResult() when $default != null:
return $default(_that.token,_that.expiresAt,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  String expiresAt,  UserProfile user)  $default,) {final _that = this;
switch (_that) {
case _LoginResult():
return $default(_that.token,_that.expiresAt,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  String expiresAt,  UserProfile user)?  $default,) {final _that = this;
switch (_that) {
case _LoginResult() when $default != null:
return $default(_that.token,_that.expiresAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _LoginResult implements LoginResult {
  const _LoginResult({required this.token, required this.expiresAt, required this.user});
  factory _LoginResult.fromJson(Map<String, dynamic> json) => _$LoginResultFromJson(json);

@override final  String token;
@override final  String expiresAt;
@override final  UserProfile user;

/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResultCopyWith<_LoginResult> get copyWith => __$LoginResultCopyWithImpl<_LoginResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResult&&(identical(other.token, token) || other.token == token)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,expiresAt,user);

@override
String toString() {
  return 'LoginResult(token: $token, expiresAt: $expiresAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$LoginResultCopyWith<$Res> implements $LoginResultCopyWith<$Res> {
  factory _$LoginResultCopyWith(_LoginResult value, $Res Function(_LoginResult) _then) = __$LoginResultCopyWithImpl;
@override @useResult
$Res call({
 String token, String expiresAt, UserProfile user
});


@override $UserProfileCopyWith<$Res> get user;

}
/// @nodoc
class __$LoginResultCopyWithImpl<$Res>
    implements _$LoginResultCopyWith<$Res> {
  __$LoginResultCopyWithImpl(this._self, this._then);

  final _LoginResult _self;
  final $Res Function(_LoginResult) _then;

/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? expiresAt = null,Object? user = null,}) {
  return _then(_LoginResult(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserProfile,
  ));
}

/// Create a copy of LoginResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get user {
  
  return $UserProfileCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$UserPage {

 List<UserProfile> get records; int get total;
/// Create a copy of UserPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPageCopyWith<UserPage> get copyWith => _$UserPageCopyWithImpl<UserPage>(this as UserPage, _$identity);

  /// Serializes this UserPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPage&&const DeepCollectionEquality().equals(other.records, records)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records),total);

@override
String toString() {
  return 'UserPage(records: $records, total: $total)';
}


}

/// @nodoc
abstract mixin class $UserPageCopyWith<$Res>  {
  factory $UserPageCopyWith(UserPage value, $Res Function(UserPage) _then) = _$UserPageCopyWithImpl;
@useResult
$Res call({
 List<UserProfile> records, int total
});




}
/// @nodoc
class _$UserPageCopyWithImpl<$Res>
    implements $UserPageCopyWith<$Res> {
  _$UserPageCopyWithImpl(this._self, this._then);

  final UserPage _self;
  final $Res Function(UserPage) _then;

/// Create a copy of UserPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,Object? total = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<UserProfile>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPage].
extension UserPagePatterns on UserPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPage value)  $default,){
final _that = this;
switch (_that) {
case _UserPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPage value)?  $default,){
final _that = this;
switch (_that) {
case _UserPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserProfile> records,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPage() when $default != null:
return $default(_that.records,_that.total);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserProfile> records,  int total)  $default,) {final _that = this;
switch (_that) {
case _UserPage():
return $default(_that.records,_that.total);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserProfile> records,  int total)?  $default,) {final _that = this;
switch (_that) {
case _UserPage() when $default != null:
return $default(_that.records,_that.total);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UserPage implements UserPage {
  const _UserPage({final  List<UserProfile> records = const <UserProfile>[], this.total = 0}): _records = records;
  factory _UserPage.fromJson(Map<String, dynamic> json) => _$UserPageFromJson(json);

 final  List<UserProfile> _records;
@override@JsonKey() List<UserProfile> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}

@override@JsonKey() final  int total;

/// Create a copy of UserPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPageCopyWith<_UserPage> get copyWith => __$UserPageCopyWithImpl<_UserPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPage&&const DeepCollectionEquality().equals(other._records, _records)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records),total);

@override
String toString() {
  return 'UserPage(records: $records, total: $total)';
}


}

/// @nodoc
abstract mixin class _$UserPageCopyWith<$Res> implements $UserPageCopyWith<$Res> {
  factory _$UserPageCopyWith(_UserPage value, $Res Function(_UserPage) _then) = __$UserPageCopyWithImpl;
@override @useResult
$Res call({
 List<UserProfile> records, int total
});




}
/// @nodoc
class __$UserPageCopyWithImpl<$Res>
    implements _$UserPageCopyWith<$Res> {
  __$UserPageCopyWithImpl(this._self, this._then);

  final _UserPage _self;
  final $Res Function(_UserPage) _then;

/// Create a copy of UserPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,Object? total = null,}) {
  return _then(_UserPage(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<UserProfile>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Account {

 int get id; String get name; String get type; num get initialBalance; num get currentBalance;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,initialBalance,currentBalance);

@override
String toString() {
  return 'Account(id: $id, name: $name, type: $type, initialBalance: $initialBalance, currentBalance: $currentBalance)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 int id, String name, String type, num initialBalance, num currentBalance
});




}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? currentBalance = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as num,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String type,  num initialBalance,  num currentBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.currentBalance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String type,  num initialBalance,  num currentBalance)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.currentBalance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String type,  num initialBalance,  num currentBalance)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.currentBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account implements Account {
  const _Account({this.id = 0, this.name = '', this.type = '', this.initialBalance = 0, this.currentBalance = 0});
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String type;
@override@JsonKey() final  num initialBalance;
@override@JsonKey() final  num currentBalance;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,initialBalance,currentBalance);

@override
String toString() {
  return 'Account(id: $id, name: $name, type: $type, initialBalance: $initialBalance, currentBalance: $currentBalance)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String type, num initialBalance, num currentBalance
});




}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? currentBalance = null,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as num,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$Category {

 int get id; String get name; int get type; int get isActive;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isActive);

@override
String toString() {
  return 'Category(id: $id, name: $name, type: $type, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 int id, String name, int type, int isActive
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int type,  int isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int type,  int isActive)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.type,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int type,  int isActive)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Category implements Category {
  const _Category({this.id = 0, this.name = '', this.type = 1, this.isActive = 1});
  factory _Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  int type;
@override@JsonKey() final  int isActive;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,isActive);

@override
String toString() {
  return 'Category(id: $id, name: $name, type: $type, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int type, int isActive
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isActive = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TransactionEntry {

 int get id; int get type; int get accountId; num get amount; String get transactionDate; int? get categoryId; int? get toAccountId; int? get liabilityId; String? get remark;
/// Create a copy of TransactionEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionEntryCopyWith<TransactionEntry> get copyWith => _$TransactionEntryCopyWithImpl<TransactionEntry>(this as TransactionEntry, _$identity);

  /// Serializes this TransactionEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.remark, remark) || other.remark == remark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,accountId,amount,transactionDate,categoryId,toAccountId,liabilityId,remark);

@override
String toString() {
  return 'TransactionEntry(id: $id, type: $type, accountId: $accountId, amount: $amount, transactionDate: $transactionDate, categoryId: $categoryId, toAccountId: $toAccountId, liabilityId: $liabilityId, remark: $remark)';
}


}

/// @nodoc
abstract mixin class $TransactionEntryCopyWith<$Res>  {
  factory $TransactionEntryCopyWith(TransactionEntry value, $Res Function(TransactionEntry) _then) = _$TransactionEntryCopyWithImpl;
@useResult
$Res call({
 int id, int type, int accountId, num amount, String transactionDate, int? categoryId, int? toAccountId, int? liabilityId, String? remark
});




}
/// @nodoc
class _$TransactionEntryCopyWithImpl<$Res>
    implements $TransactionEntryCopyWith<$Res> {
  _$TransactionEntryCopyWithImpl(this._self, this._then);

  final TransactionEntry _self;
  final $Res Function(TransactionEntry) _then;

/// Create a copy of TransactionEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? accountId = null,Object? amount = null,Object? transactionDate = null,Object? categoryId = freezed,Object? toAccountId = freezed,Object? liabilityId = freezed,Object? remark = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as int?,liabilityId: freezed == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as int?,remark: freezed == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionEntry].
extension TransactionEntryPatterns on TransactionEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionEntry value)  $default,){
final _that = this;
switch (_that) {
case _TransactionEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int type,  int accountId,  num amount,  String transactionDate,  int? categoryId,  int? toAccountId,  int? liabilityId,  String? remark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionEntry() when $default != null:
return $default(_that.id,_that.type,_that.accountId,_that.amount,_that.transactionDate,_that.categoryId,_that.toAccountId,_that.liabilityId,_that.remark);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int type,  int accountId,  num amount,  String transactionDate,  int? categoryId,  int? toAccountId,  int? liabilityId,  String? remark)  $default,) {final _that = this;
switch (_that) {
case _TransactionEntry():
return $default(_that.id,_that.type,_that.accountId,_that.amount,_that.transactionDate,_that.categoryId,_that.toAccountId,_that.liabilityId,_that.remark);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int type,  int accountId,  num amount,  String transactionDate,  int? categoryId,  int? toAccountId,  int? liabilityId,  String? remark)?  $default,) {final _that = this;
switch (_that) {
case _TransactionEntry() when $default != null:
return $default(_that.id,_that.type,_that.accountId,_that.amount,_that.transactionDate,_that.categoryId,_that.toAccountId,_that.liabilityId,_that.remark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionEntry implements TransactionEntry {
  const _TransactionEntry({this.id = 0, this.type = 1, this.accountId = 0, this.amount = 0, this.transactionDate = '', this.categoryId, this.toAccountId, this.liabilityId, this.remark});
  factory _TransactionEntry.fromJson(Map<String, dynamic> json) => _$TransactionEntryFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int type;
@override@JsonKey() final  int accountId;
@override@JsonKey() final  num amount;
@override@JsonKey() final  String transactionDate;
@override final  int? categoryId;
@override final  int? toAccountId;
@override final  int? liabilityId;
@override final  String? remark;

/// Create a copy of TransactionEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionEntryCopyWith<_TransactionEntry> get copyWith => __$TransactionEntryCopyWithImpl<_TransactionEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.transactionDate, transactionDate) || other.transactionDate == transactionDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.toAccountId, toAccountId) || other.toAccountId == toAccountId)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.remark, remark) || other.remark == remark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,accountId,amount,transactionDate,categoryId,toAccountId,liabilityId,remark);

@override
String toString() {
  return 'TransactionEntry(id: $id, type: $type, accountId: $accountId, amount: $amount, transactionDate: $transactionDate, categoryId: $categoryId, toAccountId: $toAccountId, liabilityId: $liabilityId, remark: $remark)';
}


}

/// @nodoc
abstract mixin class _$TransactionEntryCopyWith<$Res> implements $TransactionEntryCopyWith<$Res> {
  factory _$TransactionEntryCopyWith(_TransactionEntry value, $Res Function(_TransactionEntry) _then) = __$TransactionEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, int type, int accountId, num amount, String transactionDate, int? categoryId, int? toAccountId, int? liabilityId, String? remark
});




}
/// @nodoc
class __$TransactionEntryCopyWithImpl<$Res>
    implements _$TransactionEntryCopyWith<$Res> {
  __$TransactionEntryCopyWithImpl(this._self, this._then);

  final _TransactionEntry _self;
  final $Res Function(_TransactionEntry) _then;

/// Create a copy of TransactionEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? accountId = null,Object? amount = null,Object? transactionDate = null,Object? categoryId = freezed,Object? toAccountId = freezed,Object? liabilityId = freezed,Object? remark = freezed,}) {
  return _then(_TransactionEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,transactionDate: null == transactionDate ? _self.transactionDate : transactionDate // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,toAccountId: freezed == toAccountId ? _self.toAccountId : toAccountId // ignore: cast_nullable_to_non_nullable
as int?,liabilityId: freezed == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as int?,remark: freezed == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FixedItem {

 String get id; String get name; String get type; num get amount; int? get expectedDay; int? get accountId; int? get liabilityId; int? get transactionId; int? get categoryId; String? get categoryName; bool get isBooked;
/// Create a copy of FixedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixedItemCopyWith<FixedItem> get copyWith => _$FixedItemCopyWithImpl<FixedItem>(this as FixedItem, _$identity);

  /// Serializes this FixedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FixedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expectedDay, expectedDay) || other.expectedDay == expectedDay)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,amount,expectedDay,accountId,liabilityId,transactionId,categoryId,categoryName,isBooked);

@override
String toString() {
  return 'FixedItem(id: $id, name: $name, type: $type, amount: $amount, expectedDay: $expectedDay, accountId: $accountId, liabilityId: $liabilityId, transactionId: $transactionId, categoryId: $categoryId, categoryName: $categoryName, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class $FixedItemCopyWith<$Res>  {
  factory $FixedItemCopyWith(FixedItem value, $Res Function(FixedItem) _then) = _$FixedItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, num amount, int? expectedDay, int? accountId, int? liabilityId, int? transactionId, int? categoryId, String? categoryName, bool isBooked
});




}
/// @nodoc
class _$FixedItemCopyWithImpl<$Res>
    implements $FixedItemCopyWith<$Res> {
  _$FixedItemCopyWithImpl(this._self, this._then);

  final FixedItem _self;
  final $Res Function(FixedItem) _then;

/// Create a copy of FixedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? amount = null,Object? expectedDay = freezed,Object? accountId = freezed,Object? liabilityId = freezed,Object? transactionId = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? isBooked = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,expectedDay: freezed == expectedDay ? _self.expectedDay : expectedDay // ignore: cast_nullable_to_non_nullable
as int?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,liabilityId: freezed == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as int?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FixedItem].
extension FixedItemPatterns on FixedItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FixedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FixedItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FixedItem value)  $default,){
final _that = this;
switch (_that) {
case _FixedItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FixedItem value)?  $default,){
final _that = this;
switch (_that) {
case _FixedItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  num amount,  int? expectedDay,  int? accountId,  int? liabilityId,  int? transactionId,  int? categoryId,  String? categoryName,  bool isBooked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FixedItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.amount,_that.expectedDay,_that.accountId,_that.liabilityId,_that.transactionId,_that.categoryId,_that.categoryName,_that.isBooked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  num amount,  int? expectedDay,  int? accountId,  int? liabilityId,  int? transactionId,  int? categoryId,  String? categoryName,  bool isBooked)  $default,) {final _that = this;
switch (_that) {
case _FixedItem():
return $default(_that.id,_that.name,_that.type,_that.amount,_that.expectedDay,_that.accountId,_that.liabilityId,_that.transactionId,_that.categoryId,_that.categoryName,_that.isBooked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  num amount,  int? expectedDay,  int? accountId,  int? liabilityId,  int? transactionId,  int? categoryId,  String? categoryName,  bool isBooked)?  $default,) {final _that = this;
switch (_that) {
case _FixedItem() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.amount,_that.expectedDay,_that.accountId,_that.liabilityId,_that.transactionId,_that.categoryId,_that.categoryName,_that.isBooked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FixedItem implements FixedItem {
  const _FixedItem({this.id = '', this.name = '', this.type = 'EXPENSE', this.amount = 0, this.expectedDay, this.accountId, this.liabilityId, this.transactionId, this.categoryId, this.categoryName, this.isBooked = false});
  factory _FixedItem.fromJson(Map<String, dynamic> json) => _$FixedItemFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String type;
@override@JsonKey() final  num amount;
@override final  int? expectedDay;
@override final  int? accountId;
@override final  int? liabilityId;
@override final  int? transactionId;
@override final  int? categoryId;
@override final  String? categoryName;
@override@JsonKey() final  bool isBooked;

/// Create a copy of FixedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FixedItemCopyWith<_FixedItem> get copyWith => __$FixedItemCopyWithImpl<_FixedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FixedItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expectedDay, expectedDay) || other.expectedDay == expectedDay)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.liabilityId, liabilityId) || other.liabilityId == liabilityId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.isBooked, isBooked) || other.isBooked == isBooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,amount,expectedDay,accountId,liabilityId,transactionId,categoryId,categoryName,isBooked);

@override
String toString() {
  return 'FixedItem(id: $id, name: $name, type: $type, amount: $amount, expectedDay: $expectedDay, accountId: $accountId, liabilityId: $liabilityId, transactionId: $transactionId, categoryId: $categoryId, categoryName: $categoryName, isBooked: $isBooked)';
}


}

/// @nodoc
abstract mixin class _$FixedItemCopyWith<$Res> implements $FixedItemCopyWith<$Res> {
  factory _$FixedItemCopyWith(_FixedItem value, $Res Function(_FixedItem) _then) = __$FixedItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, num amount, int? expectedDay, int? accountId, int? liabilityId, int? transactionId, int? categoryId, String? categoryName, bool isBooked
});




}
/// @nodoc
class __$FixedItemCopyWithImpl<$Res>
    implements _$FixedItemCopyWith<$Res> {
  __$FixedItemCopyWithImpl(this._self, this._then);

  final _FixedItem _self;
  final $Res Function(_FixedItem) _then;

/// Create a copy of FixedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? amount = null,Object? expectedDay = freezed,Object? accountId = freezed,Object? liabilityId = freezed,Object? transactionId = freezed,Object? categoryId = freezed,Object? categoryName = freezed,Object? isBooked = null,}) {
  return _then(_FixedItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,expectedDay: freezed == expectedDay ? _self.expectedDay : expectedDay // ignore: cast_nullable_to_non_nullable
as int?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int?,liabilityId: freezed == liabilityId ? _self.liabilityId : liabilityId // ignore: cast_nullable_to_non_nullable
as int?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,isBooked: null == isBooked ? _self.isBooked : isBooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CycleTemplate {

 int get id; int get startDay; int get isDefault; String get name; List<FixedItem> get fixedItems;
/// Create a copy of CycleTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleTemplateCopyWith<CycleTemplate> get copyWith => _$CycleTemplateCopyWithImpl<CycleTemplate>(this as CycleTemplate, _$identity);

  /// Serializes this CycleTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.startDay, startDay) || other.startDay == startDay)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.fixedItems, fixedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startDay,isDefault,name,const DeepCollectionEquality().hash(fixedItems));

@override
String toString() {
  return 'CycleTemplate(id: $id, startDay: $startDay, isDefault: $isDefault, name: $name, fixedItems: $fixedItems)';
}


}

/// @nodoc
abstract mixin class $CycleTemplateCopyWith<$Res>  {
  factory $CycleTemplateCopyWith(CycleTemplate value, $Res Function(CycleTemplate) _then) = _$CycleTemplateCopyWithImpl;
@useResult
$Res call({
 int id, int startDay, int isDefault, String name, List<FixedItem> fixedItems
});




}
/// @nodoc
class _$CycleTemplateCopyWithImpl<$Res>
    implements $CycleTemplateCopyWith<$Res> {
  _$CycleTemplateCopyWithImpl(this._self, this._then);

  final CycleTemplate _self;
  final $Res Function(CycleTemplate) _then;

/// Create a copy of CycleTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startDay = null,Object? isDefault = null,Object? name = null,Object? fixedItems = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startDay: null == startDay ? _self.startDay : startDay // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fixedItems: null == fixedItems ? _self.fixedItems : fixedItems // ignore: cast_nullable_to_non_nullable
as List<FixedItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleTemplate].
extension CycleTemplatePatterns on CycleTemplate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleTemplate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleTemplate value)  $default,){
final _that = this;
switch (_that) {
case _CycleTemplate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _CycleTemplate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int startDay,  int isDefault,  String name,  List<FixedItem> fixedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleTemplate() when $default != null:
return $default(_that.id,_that.startDay,_that.isDefault,_that.name,_that.fixedItems);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int startDay,  int isDefault,  String name,  List<FixedItem> fixedItems)  $default,) {final _that = this;
switch (_that) {
case _CycleTemplate():
return $default(_that.id,_that.startDay,_that.isDefault,_that.name,_that.fixedItems);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int startDay,  int isDefault,  String name,  List<FixedItem> fixedItems)?  $default,) {final _that = this;
switch (_that) {
case _CycleTemplate() when $default != null:
return $default(_that.id,_that.startDay,_that.isDefault,_that.name,_that.fixedItems);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CycleTemplate implements CycleTemplate {
  const _CycleTemplate({this.id = 0, this.startDay = 1, this.isDefault = 0, this.name = '', final  List<FixedItem> fixedItems = const <FixedItem>[]}): _fixedItems = fixedItems;
  factory _CycleTemplate.fromJson(Map<String, dynamic> json) => _$CycleTemplateFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int startDay;
@override@JsonKey() final  int isDefault;
@override@JsonKey() final  String name;
 final  List<FixedItem> _fixedItems;
@override@JsonKey() List<FixedItem> get fixedItems {
  if (_fixedItems is EqualUnmodifiableListView) return _fixedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fixedItems);
}


/// Create a copy of CycleTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleTemplateCopyWith<_CycleTemplate> get copyWith => __$CycleTemplateCopyWithImpl<_CycleTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CycleTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.startDay, startDay) || other.startDay == startDay)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._fixedItems, _fixedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startDay,isDefault,name,const DeepCollectionEquality().hash(_fixedItems));

@override
String toString() {
  return 'CycleTemplate(id: $id, startDay: $startDay, isDefault: $isDefault, name: $name, fixedItems: $fixedItems)';
}


}

/// @nodoc
abstract mixin class _$CycleTemplateCopyWith<$Res> implements $CycleTemplateCopyWith<$Res> {
  factory _$CycleTemplateCopyWith(_CycleTemplate value, $Res Function(_CycleTemplate) _then) = __$CycleTemplateCopyWithImpl;
@override @useResult
$Res call({
 int id, int startDay, int isDefault, String name, List<FixedItem> fixedItems
});




}
/// @nodoc
class __$CycleTemplateCopyWithImpl<$Res>
    implements _$CycleTemplateCopyWith<$Res> {
  __$CycleTemplateCopyWithImpl(this._self, this._then);

  final _CycleTemplate _self;
  final $Res Function(_CycleTemplate) _then;

/// Create a copy of CycleTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startDay = null,Object? isDefault = null,Object? name = null,Object? fixedItems = null,}) {
  return _then(_CycleTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startDay: null == startDay ? _self.startDay : startDay // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fixedItems: null == fixedItems ? _self._fixedItems : fixedItems // ignore: cast_nullable_to_non_nullable
as List<FixedItem>,
  ));
}


}


/// @nodoc
mixin _$CycleRecord {

 int get id; String get cycleStartDate; String get cycleEndDate; List<FixedItem> get fixedItems; num get income; num get expense; num get balance;
/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleRecordCopyWith<CycleRecord> get copyWith => _$CycleRecordCopyWithImpl<CycleRecord>(this as CycleRecord, _$identity);

  /// Serializes this CycleRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleStartDate, cycleStartDate) || other.cycleStartDate == cycleStartDate)&&(identical(other.cycleEndDate, cycleEndDate) || other.cycleEndDate == cycleEndDate)&&const DeepCollectionEquality().equals(other.fixedItems, fixedItems)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cycleStartDate,cycleEndDate,const DeepCollectionEquality().hash(fixedItems),income,expense,balance);

@override
String toString() {
  return 'CycleRecord(id: $id, cycleStartDate: $cycleStartDate, cycleEndDate: $cycleEndDate, fixedItems: $fixedItems, income: $income, expense: $expense, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $CycleRecordCopyWith<$Res>  {
  factory $CycleRecordCopyWith(CycleRecord value, $Res Function(CycleRecord) _then) = _$CycleRecordCopyWithImpl;
@useResult
$Res call({
 int id, String cycleStartDate, String cycleEndDate, List<FixedItem> fixedItems, num income, num expense, num balance
});




}
/// @nodoc
class _$CycleRecordCopyWithImpl<$Res>
    implements $CycleRecordCopyWith<$Res> {
  _$CycleRecordCopyWithImpl(this._self, this._then);

  final CycleRecord _self;
  final $Res Function(CycleRecord) _then;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cycleStartDate = null,Object? cycleEndDate = null,Object? fixedItems = null,Object? income = null,Object? expense = null,Object? balance = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cycleStartDate: null == cycleStartDate ? _self.cycleStartDate : cycleStartDate // ignore: cast_nullable_to_non_nullable
as String,cycleEndDate: null == cycleEndDate ? _self.cycleEndDate : cycleEndDate // ignore: cast_nullable_to_non_nullable
as String,fixedItems: null == fixedItems ? _self.fixedItems : fixedItems // ignore: cast_nullable_to_non_nullable
as List<FixedItem>,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as num,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as num,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleRecord].
extension CycleRecordPatterns on CycleRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleRecord value)  $default,){
final _that = this;
switch (_that) {
case _CycleRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleRecord value)?  $default,){
final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String cycleStartDate,  String cycleEndDate,  List<FixedItem> fixedItems,  num income,  num expense,  num balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that.id,_that.cycleStartDate,_that.cycleEndDate,_that.fixedItems,_that.income,_that.expense,_that.balance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String cycleStartDate,  String cycleEndDate,  List<FixedItem> fixedItems,  num income,  num expense,  num balance)  $default,) {final _that = this;
switch (_that) {
case _CycleRecord():
return $default(_that.id,_that.cycleStartDate,_that.cycleEndDate,_that.fixedItems,_that.income,_that.expense,_that.balance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String cycleStartDate,  String cycleEndDate,  List<FixedItem> fixedItems,  num income,  num expense,  num balance)?  $default,) {final _that = this;
switch (_that) {
case _CycleRecord() when $default != null:
return $default(_that.id,_that.cycleStartDate,_that.cycleEndDate,_that.fixedItems,_that.income,_that.expense,_that.balance);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CycleRecord implements CycleRecord {
  const _CycleRecord({this.id = 0, this.cycleStartDate = '', this.cycleEndDate = '', final  List<FixedItem> fixedItems = const <FixedItem>[], this.income = 0, this.expense = 0, this.balance = 0}): _fixedItems = fixedItems;
  factory _CycleRecord.fromJson(Map<String, dynamic> json) => _$CycleRecordFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String cycleStartDate;
@override@JsonKey() final  String cycleEndDate;
 final  List<FixedItem> _fixedItems;
@override@JsonKey() List<FixedItem> get fixedItems {
  if (_fixedItems is EqualUnmodifiableListView) return _fixedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fixedItems);
}

@override@JsonKey() final  num income;
@override@JsonKey() final  num expense;
@override@JsonKey() final  num balance;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleRecordCopyWith<_CycleRecord> get copyWith => __$CycleRecordCopyWithImpl<_CycleRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CycleRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.cycleStartDate, cycleStartDate) || other.cycleStartDate == cycleStartDate)&&(identical(other.cycleEndDate, cycleEndDate) || other.cycleEndDate == cycleEndDate)&&const DeepCollectionEquality().equals(other._fixedItems, _fixedItems)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cycleStartDate,cycleEndDate,const DeepCollectionEquality().hash(_fixedItems),income,expense,balance);

@override
String toString() {
  return 'CycleRecord(id: $id, cycleStartDate: $cycleStartDate, cycleEndDate: $cycleEndDate, fixedItems: $fixedItems, income: $income, expense: $expense, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$CycleRecordCopyWith<$Res> implements $CycleRecordCopyWith<$Res> {
  factory _$CycleRecordCopyWith(_CycleRecord value, $Res Function(_CycleRecord) _then) = __$CycleRecordCopyWithImpl;
@override @useResult
$Res call({
 int id, String cycleStartDate, String cycleEndDate, List<FixedItem> fixedItems, num income, num expense, num balance
});




}
/// @nodoc
class __$CycleRecordCopyWithImpl<$Res>
    implements _$CycleRecordCopyWith<$Res> {
  __$CycleRecordCopyWithImpl(this._self, this._then);

  final _CycleRecord _self;
  final $Res Function(_CycleRecord) _then;

/// Create a copy of CycleRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cycleStartDate = null,Object? cycleEndDate = null,Object? fixedItems = null,Object? income = null,Object? expense = null,Object? balance = null,}) {
  return _then(_CycleRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cycleStartDate: null == cycleStartDate ? _self.cycleStartDate : cycleStartDate // ignore: cast_nullable_to_non_nullable
as String,cycleEndDate: null == cycleEndDate ? _self.cycleEndDate : cycleEndDate // ignore: cast_nullable_to_non_nullable
as String,fixedItems: null == fixedItems ? _self._fixedItems : fixedItems // ignore: cast_nullable_to_non_nullable
as List<FixedItem>,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as num,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as num,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$CategoryExpense {

 String get name; num get value;
/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryExpenseCopyWith<CategoryExpense> get copyWith => _$CategoryExpenseCopyWithImpl<CategoryExpense>(this as CategoryExpense, _$identity);

  /// Serializes this CategoryExpense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryExpense&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'CategoryExpense(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $CategoryExpenseCopyWith<$Res>  {
  factory $CategoryExpenseCopyWith(CategoryExpense value, $Res Function(CategoryExpense) _then) = _$CategoryExpenseCopyWithImpl;
@useResult
$Res call({
 String name, num value
});




}
/// @nodoc
class _$CategoryExpenseCopyWithImpl<$Res>
    implements $CategoryExpenseCopyWith<$Res> {
  _$CategoryExpenseCopyWithImpl(this._self, this._then);

  final CategoryExpense _self;
  final $Res Function(CategoryExpense) _then;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryExpense].
extension CategoryExpensePatterns on CategoryExpense {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryExpense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryExpense value)  $default,){
final _that = this;
switch (_that) {
case _CategoryExpense():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryExpense value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  num value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that.name,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  num value)  $default,) {final _that = this;
switch (_that) {
case _CategoryExpense():
return $default(_that.name,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  num value)?  $default,) {final _that = this;
switch (_that) {
case _CategoryExpense() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryExpense implements CategoryExpense {
  const _CategoryExpense({this.name = '', this.value = 0});
  factory _CategoryExpense.fromJson(Map<String, dynamic> json) => _$CategoryExpenseFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  num value;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryExpenseCopyWith<_CategoryExpense> get copyWith => __$CategoryExpenseCopyWithImpl<_CategoryExpense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryExpense&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'CategoryExpense(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$CategoryExpenseCopyWith<$Res> implements $CategoryExpenseCopyWith<$Res> {
  factory _$CategoryExpenseCopyWith(_CategoryExpense value, $Res Function(_CategoryExpense) _then) = __$CategoryExpenseCopyWithImpl;
@override @useResult
$Res call({
 String name, num value
});




}
/// @nodoc
class __$CategoryExpenseCopyWithImpl<$Res>
    implements _$CategoryExpenseCopyWith<$Res> {
  __$CategoryExpenseCopyWithImpl(this._self, this._then);

  final _CategoryExpense _self;
  final $Res Function(_CategoryExpense) _then;

/// Create a copy of CategoryExpense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_CategoryExpense(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$Stats {

 num get totalAssets; num get totalLiabilities; num get availableAssets; num get totalTargets; num get targetAllocated; num get currentIncome; num get currentExpense; num get currentFixedDeposit; num get currentBalance; num get currentFinalBalance; num get cumulativeBalance; bool get isOverdraft; List<CategoryExpense> get categoryExpenses;
/// Create a copy of Stats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsCopyWith<Stats> get copyWith => _$StatsCopyWithImpl<Stats>(this as Stats, _$identity);

  /// Serializes this Stats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Stats&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalLiabilities, totalLiabilities) || other.totalLiabilities == totalLiabilities)&&(identical(other.availableAssets, availableAssets) || other.availableAssets == availableAssets)&&(identical(other.totalTargets, totalTargets) || other.totalTargets == totalTargets)&&(identical(other.targetAllocated, targetAllocated) || other.targetAllocated == targetAllocated)&&(identical(other.currentIncome, currentIncome) || other.currentIncome == currentIncome)&&(identical(other.currentExpense, currentExpense) || other.currentExpense == currentExpense)&&(identical(other.currentFixedDeposit, currentFixedDeposit) || other.currentFixedDeposit == currentFixedDeposit)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.currentFinalBalance, currentFinalBalance) || other.currentFinalBalance == currentFinalBalance)&&(identical(other.cumulativeBalance, cumulativeBalance) || other.cumulativeBalance == cumulativeBalance)&&(identical(other.isOverdraft, isOverdraft) || other.isOverdraft == isOverdraft)&&const DeepCollectionEquality().equals(other.categoryExpenses, categoryExpenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAssets,totalLiabilities,availableAssets,totalTargets,targetAllocated,currentIncome,currentExpense,currentFixedDeposit,currentBalance,currentFinalBalance,cumulativeBalance,isOverdraft,const DeepCollectionEquality().hash(categoryExpenses));

@override
String toString() {
  return 'Stats(totalAssets: $totalAssets, totalLiabilities: $totalLiabilities, availableAssets: $availableAssets, totalTargets: $totalTargets, targetAllocated: $targetAllocated, currentIncome: $currentIncome, currentExpense: $currentExpense, currentFixedDeposit: $currentFixedDeposit, currentBalance: $currentBalance, currentFinalBalance: $currentFinalBalance, cumulativeBalance: $cumulativeBalance, isOverdraft: $isOverdraft, categoryExpenses: $categoryExpenses)';
}


}

/// @nodoc
abstract mixin class $StatsCopyWith<$Res>  {
  factory $StatsCopyWith(Stats value, $Res Function(Stats) _then) = _$StatsCopyWithImpl;
@useResult
$Res call({
 num totalAssets, num totalLiabilities, num availableAssets, num totalTargets, num targetAllocated, num currentIncome, num currentExpense, num currentFixedDeposit, num currentBalance, num currentFinalBalance, num cumulativeBalance, bool isOverdraft, List<CategoryExpense> categoryExpenses
});




}
/// @nodoc
class _$StatsCopyWithImpl<$Res>
    implements $StatsCopyWith<$Res> {
  _$StatsCopyWithImpl(this._self, this._then);

  final Stats _self;
  final $Res Function(Stats) _then;

/// Create a copy of Stats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalAssets = null,Object? totalLiabilities = null,Object? availableAssets = null,Object? totalTargets = null,Object? targetAllocated = null,Object? currentIncome = null,Object? currentExpense = null,Object? currentFixedDeposit = null,Object? currentBalance = null,Object? currentFinalBalance = null,Object? cumulativeBalance = null,Object? isOverdraft = null,Object? categoryExpenses = null,}) {
  return _then(_self.copyWith(
totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as num,totalLiabilities: null == totalLiabilities ? _self.totalLiabilities : totalLiabilities // ignore: cast_nullable_to_non_nullable
as num,availableAssets: null == availableAssets ? _self.availableAssets : availableAssets // ignore: cast_nullable_to_non_nullable
as num,totalTargets: null == totalTargets ? _self.totalTargets : totalTargets // ignore: cast_nullable_to_non_nullable
as num,targetAllocated: null == targetAllocated ? _self.targetAllocated : targetAllocated // ignore: cast_nullable_to_non_nullable
as num,currentIncome: null == currentIncome ? _self.currentIncome : currentIncome // ignore: cast_nullable_to_non_nullable
as num,currentExpense: null == currentExpense ? _self.currentExpense : currentExpense // ignore: cast_nullable_to_non_nullable
as num,currentFixedDeposit: null == currentFixedDeposit ? _self.currentFixedDeposit : currentFixedDeposit // ignore: cast_nullable_to_non_nullable
as num,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as num,currentFinalBalance: null == currentFinalBalance ? _self.currentFinalBalance : currentFinalBalance // ignore: cast_nullable_to_non_nullable
as num,cumulativeBalance: null == cumulativeBalance ? _self.cumulativeBalance : cumulativeBalance // ignore: cast_nullable_to_non_nullable
as num,isOverdraft: null == isOverdraft ? _self.isOverdraft : isOverdraft // ignore: cast_nullable_to_non_nullable
as bool,categoryExpenses: null == categoryExpenses ? _self.categoryExpenses : categoryExpenses // ignore: cast_nullable_to_non_nullable
as List<CategoryExpense>,
  ));
}

}


/// Adds pattern-matching-related methods to [Stats].
extension StatsPatterns on Stats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Stats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Stats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Stats value)  $default,){
final _that = this;
switch (_that) {
case _Stats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Stats value)?  $default,){
final _that = this;
switch (_that) {
case _Stats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num totalAssets,  num totalLiabilities,  num availableAssets,  num totalTargets,  num targetAllocated,  num currentIncome,  num currentExpense,  num currentFixedDeposit,  num currentBalance,  num currentFinalBalance,  num cumulativeBalance,  bool isOverdraft,  List<CategoryExpense> categoryExpenses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Stats() when $default != null:
return $default(_that.totalAssets,_that.totalLiabilities,_that.availableAssets,_that.totalTargets,_that.targetAllocated,_that.currentIncome,_that.currentExpense,_that.currentFixedDeposit,_that.currentBalance,_that.currentFinalBalance,_that.cumulativeBalance,_that.isOverdraft,_that.categoryExpenses);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num totalAssets,  num totalLiabilities,  num availableAssets,  num totalTargets,  num targetAllocated,  num currentIncome,  num currentExpense,  num currentFixedDeposit,  num currentBalance,  num currentFinalBalance,  num cumulativeBalance,  bool isOverdraft,  List<CategoryExpense> categoryExpenses)  $default,) {final _that = this;
switch (_that) {
case _Stats():
return $default(_that.totalAssets,_that.totalLiabilities,_that.availableAssets,_that.totalTargets,_that.targetAllocated,_that.currentIncome,_that.currentExpense,_that.currentFixedDeposit,_that.currentBalance,_that.currentFinalBalance,_that.cumulativeBalance,_that.isOverdraft,_that.categoryExpenses);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num totalAssets,  num totalLiabilities,  num availableAssets,  num totalTargets,  num targetAllocated,  num currentIncome,  num currentExpense,  num currentFixedDeposit,  num currentBalance,  num currentFinalBalance,  num cumulativeBalance,  bool isOverdraft,  List<CategoryExpense> categoryExpenses)?  $default,) {final _that = this;
switch (_that) {
case _Stats() when $default != null:
return $default(_that.totalAssets,_that.totalLiabilities,_that.availableAssets,_that.totalTargets,_that.targetAllocated,_that.currentIncome,_that.currentExpense,_that.currentFixedDeposit,_that.currentBalance,_that.currentFinalBalance,_that.cumulativeBalance,_that.isOverdraft,_that.categoryExpenses);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Stats implements Stats {
  const _Stats({this.totalAssets = 0, this.totalLiabilities = 0, this.availableAssets = 0, this.totalTargets = 0, this.targetAllocated = 0, this.currentIncome = 0, this.currentExpense = 0, this.currentFixedDeposit = 0, this.currentBalance = 0, this.currentFinalBalance = 0, this.cumulativeBalance = 0, this.isOverdraft = false, final  List<CategoryExpense> categoryExpenses = const <CategoryExpense>[]}): _categoryExpenses = categoryExpenses;
  factory _Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);

@override@JsonKey() final  num totalAssets;
@override@JsonKey() final  num totalLiabilities;
@override@JsonKey() final  num availableAssets;
@override@JsonKey() final  num totalTargets;
@override@JsonKey() final  num targetAllocated;
@override@JsonKey() final  num currentIncome;
@override@JsonKey() final  num currentExpense;
@override@JsonKey() final  num currentFixedDeposit;
@override@JsonKey() final  num currentBalance;
@override@JsonKey() final  num currentFinalBalance;
@override@JsonKey() final  num cumulativeBalance;
@override@JsonKey() final  bool isOverdraft;
 final  List<CategoryExpense> _categoryExpenses;
@override@JsonKey() List<CategoryExpense> get categoryExpenses {
  if (_categoryExpenses is EqualUnmodifiableListView) return _categoryExpenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryExpenses);
}


/// Create a copy of Stats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsCopyWith<_Stats> get copyWith => __$StatsCopyWithImpl<_Stats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stats&&(identical(other.totalAssets, totalAssets) || other.totalAssets == totalAssets)&&(identical(other.totalLiabilities, totalLiabilities) || other.totalLiabilities == totalLiabilities)&&(identical(other.availableAssets, availableAssets) || other.availableAssets == availableAssets)&&(identical(other.totalTargets, totalTargets) || other.totalTargets == totalTargets)&&(identical(other.targetAllocated, targetAllocated) || other.targetAllocated == targetAllocated)&&(identical(other.currentIncome, currentIncome) || other.currentIncome == currentIncome)&&(identical(other.currentExpense, currentExpense) || other.currentExpense == currentExpense)&&(identical(other.currentFixedDeposit, currentFixedDeposit) || other.currentFixedDeposit == currentFixedDeposit)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.currentFinalBalance, currentFinalBalance) || other.currentFinalBalance == currentFinalBalance)&&(identical(other.cumulativeBalance, cumulativeBalance) || other.cumulativeBalance == cumulativeBalance)&&(identical(other.isOverdraft, isOverdraft) || other.isOverdraft == isOverdraft)&&const DeepCollectionEquality().equals(other._categoryExpenses, _categoryExpenses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAssets,totalLiabilities,availableAssets,totalTargets,targetAllocated,currentIncome,currentExpense,currentFixedDeposit,currentBalance,currentFinalBalance,cumulativeBalance,isOverdraft,const DeepCollectionEquality().hash(_categoryExpenses));

@override
String toString() {
  return 'Stats(totalAssets: $totalAssets, totalLiabilities: $totalLiabilities, availableAssets: $availableAssets, totalTargets: $totalTargets, targetAllocated: $targetAllocated, currentIncome: $currentIncome, currentExpense: $currentExpense, currentFixedDeposit: $currentFixedDeposit, currentBalance: $currentBalance, currentFinalBalance: $currentFinalBalance, cumulativeBalance: $cumulativeBalance, isOverdraft: $isOverdraft, categoryExpenses: $categoryExpenses)';
}


}

/// @nodoc
abstract mixin class _$StatsCopyWith<$Res> implements $StatsCopyWith<$Res> {
  factory _$StatsCopyWith(_Stats value, $Res Function(_Stats) _then) = __$StatsCopyWithImpl;
@override @useResult
$Res call({
 num totalAssets, num totalLiabilities, num availableAssets, num totalTargets, num targetAllocated, num currentIncome, num currentExpense, num currentFixedDeposit, num currentBalance, num currentFinalBalance, num cumulativeBalance, bool isOverdraft, List<CategoryExpense> categoryExpenses
});




}
/// @nodoc
class __$StatsCopyWithImpl<$Res>
    implements _$StatsCopyWith<$Res> {
  __$StatsCopyWithImpl(this._self, this._then);

  final _Stats _self;
  final $Res Function(_Stats) _then;

/// Create a copy of Stats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalAssets = null,Object? totalLiabilities = null,Object? availableAssets = null,Object? totalTargets = null,Object? targetAllocated = null,Object? currentIncome = null,Object? currentExpense = null,Object? currentFixedDeposit = null,Object? currentBalance = null,Object? currentFinalBalance = null,Object? cumulativeBalance = null,Object? isOverdraft = null,Object? categoryExpenses = null,}) {
  return _then(_Stats(
totalAssets: null == totalAssets ? _self.totalAssets : totalAssets // ignore: cast_nullable_to_non_nullable
as num,totalLiabilities: null == totalLiabilities ? _self.totalLiabilities : totalLiabilities // ignore: cast_nullable_to_non_nullable
as num,availableAssets: null == availableAssets ? _self.availableAssets : availableAssets // ignore: cast_nullable_to_non_nullable
as num,totalTargets: null == totalTargets ? _self.totalTargets : totalTargets // ignore: cast_nullable_to_non_nullable
as num,targetAllocated: null == targetAllocated ? _self.targetAllocated : targetAllocated // ignore: cast_nullable_to_non_nullable
as num,currentIncome: null == currentIncome ? _self.currentIncome : currentIncome // ignore: cast_nullable_to_non_nullable
as num,currentExpense: null == currentExpense ? _self.currentExpense : currentExpense // ignore: cast_nullable_to_non_nullable
as num,currentFixedDeposit: null == currentFixedDeposit ? _self.currentFixedDeposit : currentFixedDeposit // ignore: cast_nullable_to_non_nullable
as num,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as num,currentFinalBalance: null == currentFinalBalance ? _self.currentFinalBalance : currentFinalBalance // ignore: cast_nullable_to_non_nullable
as num,cumulativeBalance: null == cumulativeBalance ? _self.cumulativeBalance : cumulativeBalance // ignore: cast_nullable_to_non_nullable
as num,isOverdraft: null == isOverdraft ? _self.isOverdraft : isOverdraft // ignore: cast_nullable_to_non_nullable
as bool,categoryExpenses: null == categoryExpenses ? _self._categoryExpenses : categoryExpenses // ignore: cast_nullable_to_non_nullable
as List<CategoryExpense>,
  ));
}


}


/// @nodoc
mixin _$Goal {

 int get id; int get isRealized; int get progress; String get name; String get type; num get targetAmount; num get availableFunds; num get gap; String? get startDate; String? get deadline; String? get estimatedCompletionDate; String? get estimatedReason; bool get isEstimatedFallback;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);

  /// Serializes this Goal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.isRealized, isRealized) || other.isRealized == isRealized)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.availableFunds, availableFunds) || other.availableFunds == availableFunds)&&(identical(other.gap, gap) || other.gap == gap)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.estimatedCompletionDate, estimatedCompletionDate) || other.estimatedCompletionDate == estimatedCompletionDate)&&(identical(other.estimatedReason, estimatedReason) || other.estimatedReason == estimatedReason)&&(identical(other.isEstimatedFallback, isEstimatedFallback) || other.isEstimatedFallback == isEstimatedFallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isRealized,progress,name,type,targetAmount,availableFunds,gap,startDate,deadline,estimatedCompletionDate,estimatedReason,isEstimatedFallback);

@override
String toString() {
  return 'Goal(id: $id, isRealized: $isRealized, progress: $progress, name: $name, type: $type, targetAmount: $targetAmount, availableFunds: $availableFunds, gap: $gap, startDate: $startDate, deadline: $deadline, estimatedCompletionDate: $estimatedCompletionDate, estimatedReason: $estimatedReason, isEstimatedFallback: $isEstimatedFallback)';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 int id, int isRealized, int progress, String name, String type, num targetAmount, num availableFunds, num gap, String? startDate, String? deadline, String? estimatedCompletionDate, String? estimatedReason, bool isEstimatedFallback
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isRealized = null,Object? progress = null,Object? name = null,Object? type = null,Object? targetAmount = null,Object? availableFunds = null,Object? gap = null,Object? startDate = freezed,Object? deadline = freezed,Object? estimatedCompletionDate = freezed,Object? estimatedReason = freezed,Object? isEstimatedFallback = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,isRealized: null == isRealized ? _self.isRealized : isRealized // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as num,availableFunds: null == availableFunds ? _self.availableFunds : availableFunds // ignore: cast_nullable_to_non_nullable
as num,gap: null == gap ? _self.gap : gap // ignore: cast_nullable_to_non_nullable
as num,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,estimatedCompletionDate: freezed == estimatedCompletionDate ? _self.estimatedCompletionDate : estimatedCompletionDate // ignore: cast_nullable_to_non_nullable
as String?,estimatedReason: freezed == estimatedReason ? _self.estimatedReason : estimatedReason // ignore: cast_nullable_to_non_nullable
as String?,isEstimatedFallback: null == isEstimatedFallback ? _self.isEstimatedFallback : isEstimatedFallback // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int isRealized,  int progress,  String name,  String type,  num targetAmount,  num availableFunds,  num gap,  String? startDate,  String? deadline,  String? estimatedCompletionDate,  String? estimatedReason,  bool isEstimatedFallback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.isRealized,_that.progress,_that.name,_that.type,_that.targetAmount,_that.availableFunds,_that.gap,_that.startDate,_that.deadline,_that.estimatedCompletionDate,_that.estimatedReason,_that.isEstimatedFallback);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int isRealized,  int progress,  String name,  String type,  num targetAmount,  num availableFunds,  num gap,  String? startDate,  String? deadline,  String? estimatedCompletionDate,  String? estimatedReason,  bool isEstimatedFallback)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.isRealized,_that.progress,_that.name,_that.type,_that.targetAmount,_that.availableFunds,_that.gap,_that.startDate,_that.deadline,_that.estimatedCompletionDate,_that.estimatedReason,_that.isEstimatedFallback);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int isRealized,  int progress,  String name,  String type,  num targetAmount,  num availableFunds,  num gap,  String? startDate,  String? deadline,  String? estimatedCompletionDate,  String? estimatedReason,  bool isEstimatedFallback)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.isRealized,_that.progress,_that.name,_that.type,_that.targetAmount,_that.availableFunds,_that.gap,_that.startDate,_that.deadline,_that.estimatedCompletionDate,_that.estimatedReason,_that.isEstimatedFallback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Goal implements Goal {
  const _Goal({this.id = 0, this.isRealized = 0, this.progress = 0, this.name = '', this.type = 'LONG_TERM', this.targetAmount = 0, this.availableFunds = 0, this.gap = 0, this.startDate, this.deadline, this.estimatedCompletionDate, this.estimatedReason, this.isEstimatedFallback = false});
  factory _Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  int isRealized;
@override@JsonKey() final  int progress;
@override@JsonKey() final  String name;
@override@JsonKey() final  String type;
@override@JsonKey() final  num targetAmount;
@override@JsonKey() final  num availableFunds;
@override@JsonKey() final  num gap;
@override final  String? startDate;
@override final  String? deadline;
@override final  String? estimatedCompletionDate;
@override final  String? estimatedReason;
@override@JsonKey() final  bool isEstimatedFallback;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.isRealized, isRealized) || other.isRealized == isRealized)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.availableFunds, availableFunds) || other.availableFunds == availableFunds)&&(identical(other.gap, gap) || other.gap == gap)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.estimatedCompletionDate, estimatedCompletionDate) || other.estimatedCompletionDate == estimatedCompletionDate)&&(identical(other.estimatedReason, estimatedReason) || other.estimatedReason == estimatedReason)&&(identical(other.isEstimatedFallback, isEstimatedFallback) || other.isEstimatedFallback == isEstimatedFallback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isRealized,progress,name,type,targetAmount,availableFunds,gap,startDate,deadline,estimatedCompletionDate,estimatedReason,isEstimatedFallback);

@override
String toString() {
  return 'Goal(id: $id, isRealized: $isRealized, progress: $progress, name: $name, type: $type, targetAmount: $targetAmount, availableFunds: $availableFunds, gap: $gap, startDate: $startDate, deadline: $deadline, estimatedCompletionDate: $estimatedCompletionDate, estimatedReason: $estimatedReason, isEstimatedFallback: $isEstimatedFallback)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 int id, int isRealized, int progress, String name, String type, num targetAmount, num availableFunds, num gap, String? startDate, String? deadline, String? estimatedCompletionDate, String? estimatedReason, bool isEstimatedFallback
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isRealized = null,Object? progress = null,Object? name = null,Object? type = null,Object? targetAmount = null,Object? availableFunds = null,Object? gap = null,Object? startDate = freezed,Object? deadline = freezed,Object? estimatedCompletionDate = freezed,Object? estimatedReason = freezed,Object? isEstimatedFallback = null,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,isRealized: null == isRealized ? _self.isRealized : isRealized // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as num,availableFunds: null == availableFunds ? _self.availableFunds : availableFunds // ignore: cast_nullable_to_non_nullable
as num,gap: null == gap ? _self.gap : gap // ignore: cast_nullable_to_non_nullable
as num,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,estimatedCompletionDate: freezed == estimatedCompletionDate ? _self.estimatedCompletionDate : estimatedCompletionDate // ignore: cast_nullable_to_non_nullable
as String?,estimatedReason: freezed == estimatedReason ? _self.estimatedReason : estimatedReason // ignore: cast_nullable_to_non_nullable
as String?,isEstimatedFallback: null == isEstimatedFallback ? _self.isEstimatedFallback : isEstimatedFallback // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Liability {

 int get id; String get name; num get principal; num get totalAmount; int get totalPeriods; int get currentPeriod; num get periodAmount; String get rateType; num get interestRate; int get repaymentDay; String? get nextRepaymentDate; int? get defaultAccountId; int? get categoryId; int get autoCycleFixedExpense; String get status; String? get startDate; String? get settledAt; String? get createdAt; String? get updatedAt; int get remainingPeriods; num get remainingAmount; int get progressPercent; String? get defaultAccountName; String? get categoryName;
/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiabilityCopyWith<Liability> get copyWith => _$LiabilityCopyWithImpl<Liability>(this as Liability, _$identity);

  /// Serializes this Liability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Liability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalPeriods, totalPeriods) || other.totalPeriods == totalPeriods)&&(identical(other.currentPeriod, currentPeriod) || other.currentPeriod == currentPeriod)&&(identical(other.periodAmount, periodAmount) || other.periodAmount == periodAmount)&&(identical(other.rateType, rateType) || other.rateType == rateType)&&(identical(other.interestRate, interestRate) || other.interestRate == interestRate)&&(identical(other.repaymentDay, repaymentDay) || other.repaymentDay == repaymentDay)&&(identical(other.nextRepaymentDate, nextRepaymentDate) || other.nextRepaymentDate == nextRepaymentDate)&&(identical(other.defaultAccountId, defaultAccountId) || other.defaultAccountId == defaultAccountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.autoCycleFixedExpense, autoCycleFixedExpense) || other.autoCycleFixedExpense == autoCycleFixedExpense)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remainingPeriods, remainingPeriods) || other.remainingPeriods == remainingPeriods)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.defaultAccountName, defaultAccountName) || other.defaultAccountName == defaultAccountName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,principal,totalAmount,totalPeriods,currentPeriod,periodAmount,rateType,interestRate,repaymentDay,nextRepaymentDate,defaultAccountId,categoryId,autoCycleFixedExpense,status,startDate,settledAt,createdAt,updatedAt,remainingPeriods,remainingAmount,progressPercent,defaultAccountName,categoryName]);

@override
String toString() {
  return 'Liability(id: $id, name: $name, principal: $principal, totalAmount: $totalAmount, totalPeriods: $totalPeriods, currentPeriod: $currentPeriod, periodAmount: $periodAmount, rateType: $rateType, interestRate: $interestRate, repaymentDay: $repaymentDay, nextRepaymentDate: $nextRepaymentDate, defaultAccountId: $defaultAccountId, categoryId: $categoryId, autoCycleFixedExpense: $autoCycleFixedExpense, status: $status, startDate: $startDate, settledAt: $settledAt, createdAt: $createdAt, updatedAt: $updatedAt, remainingPeriods: $remainingPeriods, remainingAmount: $remainingAmount, progressPercent: $progressPercent, defaultAccountName: $defaultAccountName, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class $LiabilityCopyWith<$Res>  {
  factory $LiabilityCopyWith(Liability value, $Res Function(Liability) _then) = _$LiabilityCopyWithImpl;
@useResult
$Res call({
 int id, String name, num principal, num totalAmount, int totalPeriods, int currentPeriod, num periodAmount, String rateType, num interestRate, int repaymentDay, String? nextRepaymentDate, int? defaultAccountId, int? categoryId, int autoCycleFixedExpense, String status, String? startDate, String? settledAt, String? createdAt, String? updatedAt, int remainingPeriods, num remainingAmount, int progressPercent, String? defaultAccountName, String? categoryName
});




}
/// @nodoc
class _$LiabilityCopyWithImpl<$Res>
    implements $LiabilityCopyWith<$Res> {
  _$LiabilityCopyWithImpl(this._self, this._then);

  final Liability _self;
  final $Res Function(Liability) _then;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? principal = null,Object? totalAmount = null,Object? totalPeriods = null,Object? currentPeriod = null,Object? periodAmount = null,Object? rateType = null,Object? interestRate = null,Object? repaymentDay = null,Object? nextRepaymentDate = freezed,Object? defaultAccountId = freezed,Object? categoryId = freezed,Object? autoCycleFixedExpense = null,Object? status = null,Object? startDate = freezed,Object? settledAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? remainingPeriods = null,Object? remainingAmount = null,Object? progressPercent = null,Object? defaultAccountName = freezed,Object? categoryName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as num,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num,totalPeriods: null == totalPeriods ? _self.totalPeriods : totalPeriods // ignore: cast_nullable_to_non_nullable
as int,currentPeriod: null == currentPeriod ? _self.currentPeriod : currentPeriod // ignore: cast_nullable_to_non_nullable
as int,periodAmount: null == periodAmount ? _self.periodAmount : periodAmount // ignore: cast_nullable_to_non_nullable
as num,rateType: null == rateType ? _self.rateType : rateType // ignore: cast_nullable_to_non_nullable
as String,interestRate: null == interestRate ? _self.interestRate : interestRate // ignore: cast_nullable_to_non_nullable
as num,repaymentDay: null == repaymentDay ? _self.repaymentDay : repaymentDay // ignore: cast_nullable_to_non_nullable
as int,nextRepaymentDate: freezed == nextRepaymentDate ? _self.nextRepaymentDate : nextRepaymentDate // ignore: cast_nullable_to_non_nullable
as String?,defaultAccountId: freezed == defaultAccountId ? _self.defaultAccountId : defaultAccountId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,autoCycleFixedExpense: null == autoCycleFixedExpense ? _self.autoCycleFixedExpense : autoCycleFixedExpense // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,remainingPeriods: null == remainingPeriods ? _self.remainingPeriods : remainingPeriods // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,defaultAccountName: freezed == defaultAccountName ? _self.defaultAccountName : defaultAccountName // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Liability].
extension LiabilityPatterns on Liability {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Liability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Liability value)  $default,){
final _that = this;
switch (_that) {
case _Liability():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Liability value)?  $default,){
final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  num principal,  num totalAmount,  int totalPeriods,  int currentPeriod,  num periodAmount,  String rateType,  num interestRate,  int repaymentDay,  String? nextRepaymentDate,  int? defaultAccountId,  int? categoryId,  int autoCycleFixedExpense,  String status,  String? startDate,  String? settledAt,  String? createdAt,  String? updatedAt,  int remainingPeriods,  num remainingAmount,  int progressPercent,  String? defaultAccountName,  String? categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that.id,_that.name,_that.principal,_that.totalAmount,_that.totalPeriods,_that.currentPeriod,_that.periodAmount,_that.rateType,_that.interestRate,_that.repaymentDay,_that.nextRepaymentDate,_that.defaultAccountId,_that.categoryId,_that.autoCycleFixedExpense,_that.status,_that.startDate,_that.settledAt,_that.createdAt,_that.updatedAt,_that.remainingPeriods,_that.remainingAmount,_that.progressPercent,_that.defaultAccountName,_that.categoryName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  num principal,  num totalAmount,  int totalPeriods,  int currentPeriod,  num periodAmount,  String rateType,  num interestRate,  int repaymentDay,  String? nextRepaymentDate,  int? defaultAccountId,  int? categoryId,  int autoCycleFixedExpense,  String status,  String? startDate,  String? settledAt,  String? createdAt,  String? updatedAt,  int remainingPeriods,  num remainingAmount,  int progressPercent,  String? defaultAccountName,  String? categoryName)  $default,) {final _that = this;
switch (_that) {
case _Liability():
return $default(_that.id,_that.name,_that.principal,_that.totalAmount,_that.totalPeriods,_that.currentPeriod,_that.periodAmount,_that.rateType,_that.interestRate,_that.repaymentDay,_that.nextRepaymentDate,_that.defaultAccountId,_that.categoryId,_that.autoCycleFixedExpense,_that.status,_that.startDate,_that.settledAt,_that.createdAt,_that.updatedAt,_that.remainingPeriods,_that.remainingAmount,_that.progressPercent,_that.defaultAccountName,_that.categoryName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  num principal,  num totalAmount,  int totalPeriods,  int currentPeriod,  num periodAmount,  String rateType,  num interestRate,  int repaymentDay,  String? nextRepaymentDate,  int? defaultAccountId,  int? categoryId,  int autoCycleFixedExpense,  String status,  String? startDate,  String? settledAt,  String? createdAt,  String? updatedAt,  int remainingPeriods,  num remainingAmount,  int progressPercent,  String? defaultAccountName,  String? categoryName)?  $default,) {final _that = this;
switch (_that) {
case _Liability() when $default != null:
return $default(_that.id,_that.name,_that.principal,_that.totalAmount,_that.totalPeriods,_that.currentPeriod,_that.periodAmount,_that.rateType,_that.interestRate,_that.repaymentDay,_that.nextRepaymentDate,_that.defaultAccountId,_that.categoryId,_that.autoCycleFixedExpense,_that.status,_that.startDate,_that.settledAt,_that.createdAt,_that.updatedAt,_that.remainingPeriods,_that.remainingAmount,_that.progressPercent,_that.defaultAccountName,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Liability implements Liability {
  const _Liability({this.id = 0, this.name = '', this.principal = 0, this.totalAmount = 0, this.totalPeriods = 1, this.currentPeriod = 0, this.periodAmount = 0, this.rateType = 'NONE', this.interestRate = 0, this.repaymentDay = 1, this.nextRepaymentDate, this.defaultAccountId, this.categoryId, this.autoCycleFixedExpense = 0, this.status = 'REPAYING', this.startDate, this.settledAt, this.createdAt, this.updatedAt, this.remainingPeriods = 0, this.remainingAmount = 0, this.progressPercent = 0, this.defaultAccountName, this.categoryName});
  factory _Liability.fromJson(Map<String, dynamic> json) => _$LiabilityFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  num principal;
@override@JsonKey() final  num totalAmount;
@override@JsonKey() final  int totalPeriods;
@override@JsonKey() final  int currentPeriod;
@override@JsonKey() final  num periodAmount;
@override@JsonKey() final  String rateType;
@override@JsonKey() final  num interestRate;
@override@JsonKey() final  int repaymentDay;
@override final  String? nextRepaymentDate;
@override final  int? defaultAccountId;
@override final  int? categoryId;
@override@JsonKey() final  int autoCycleFixedExpense;
@override@JsonKey() final  String status;
@override final  String? startDate;
@override final  String? settledAt;
@override final  String? createdAt;
@override final  String? updatedAt;
@override@JsonKey() final  int remainingPeriods;
@override@JsonKey() final  num remainingAmount;
@override@JsonKey() final  int progressPercent;
@override final  String? defaultAccountName;
@override final  String? categoryName;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiabilityCopyWith<_Liability> get copyWith => __$LiabilityCopyWithImpl<_Liability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Liability&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.totalPeriods, totalPeriods) || other.totalPeriods == totalPeriods)&&(identical(other.currentPeriod, currentPeriod) || other.currentPeriod == currentPeriod)&&(identical(other.periodAmount, periodAmount) || other.periodAmount == periodAmount)&&(identical(other.rateType, rateType) || other.rateType == rateType)&&(identical(other.interestRate, interestRate) || other.interestRate == interestRate)&&(identical(other.repaymentDay, repaymentDay) || other.repaymentDay == repaymentDay)&&(identical(other.nextRepaymentDate, nextRepaymentDate) || other.nextRepaymentDate == nextRepaymentDate)&&(identical(other.defaultAccountId, defaultAccountId) || other.defaultAccountId == defaultAccountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.autoCycleFixedExpense, autoCycleFixedExpense) || other.autoCycleFixedExpense == autoCycleFixedExpense)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.settledAt, settledAt) || other.settledAt == settledAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remainingPeriods, remainingPeriods) || other.remainingPeriods == remainingPeriods)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.defaultAccountName, defaultAccountName) || other.defaultAccountName == defaultAccountName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,principal,totalAmount,totalPeriods,currentPeriod,periodAmount,rateType,interestRate,repaymentDay,nextRepaymentDate,defaultAccountId,categoryId,autoCycleFixedExpense,status,startDate,settledAt,createdAt,updatedAt,remainingPeriods,remainingAmount,progressPercent,defaultAccountName,categoryName]);

@override
String toString() {
  return 'Liability(id: $id, name: $name, principal: $principal, totalAmount: $totalAmount, totalPeriods: $totalPeriods, currentPeriod: $currentPeriod, periodAmount: $periodAmount, rateType: $rateType, interestRate: $interestRate, repaymentDay: $repaymentDay, nextRepaymentDate: $nextRepaymentDate, defaultAccountId: $defaultAccountId, categoryId: $categoryId, autoCycleFixedExpense: $autoCycleFixedExpense, status: $status, startDate: $startDate, settledAt: $settledAt, createdAt: $createdAt, updatedAt: $updatedAt, remainingPeriods: $remainingPeriods, remainingAmount: $remainingAmount, progressPercent: $progressPercent, defaultAccountName: $defaultAccountName, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$LiabilityCopyWith<$Res> implements $LiabilityCopyWith<$Res> {
  factory _$LiabilityCopyWith(_Liability value, $Res Function(_Liability) _then) = __$LiabilityCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, num principal, num totalAmount, int totalPeriods, int currentPeriod, num periodAmount, String rateType, num interestRate, int repaymentDay, String? nextRepaymentDate, int? defaultAccountId, int? categoryId, int autoCycleFixedExpense, String status, String? startDate, String? settledAt, String? createdAt, String? updatedAt, int remainingPeriods, num remainingAmount, int progressPercent, String? defaultAccountName, String? categoryName
});




}
/// @nodoc
class __$LiabilityCopyWithImpl<$Res>
    implements _$LiabilityCopyWith<$Res> {
  __$LiabilityCopyWithImpl(this._self, this._then);

  final _Liability _self;
  final $Res Function(_Liability) _then;

/// Create a copy of Liability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? principal = null,Object? totalAmount = null,Object? totalPeriods = null,Object? currentPeriod = null,Object? periodAmount = null,Object? rateType = null,Object? interestRate = null,Object? repaymentDay = null,Object? nextRepaymentDate = freezed,Object? defaultAccountId = freezed,Object? categoryId = freezed,Object? autoCycleFixedExpense = null,Object? status = null,Object? startDate = freezed,Object? settledAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? remainingPeriods = null,Object? remainingAmount = null,Object? progressPercent = null,Object? defaultAccountName = freezed,Object? categoryName = freezed,}) {
  return _then(_Liability(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as num,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num,totalPeriods: null == totalPeriods ? _self.totalPeriods : totalPeriods // ignore: cast_nullable_to_non_nullable
as int,currentPeriod: null == currentPeriod ? _self.currentPeriod : currentPeriod // ignore: cast_nullable_to_non_nullable
as int,periodAmount: null == periodAmount ? _self.periodAmount : periodAmount // ignore: cast_nullable_to_non_nullable
as num,rateType: null == rateType ? _self.rateType : rateType // ignore: cast_nullable_to_non_nullable
as String,interestRate: null == interestRate ? _self.interestRate : interestRate // ignore: cast_nullable_to_non_nullable
as num,repaymentDay: null == repaymentDay ? _self.repaymentDay : repaymentDay // ignore: cast_nullable_to_non_nullable
as int,nextRepaymentDate: freezed == nextRepaymentDate ? _self.nextRepaymentDate : nextRepaymentDate // ignore: cast_nullable_to_non_nullable
as String?,defaultAccountId: freezed == defaultAccountId ? _self.defaultAccountId : defaultAccountId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,autoCycleFixedExpense: null == autoCycleFixedExpense ? _self.autoCycleFixedExpense : autoCycleFixedExpense // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,settledAt: freezed == settledAt ? _self.settledAt : settledAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,remainingPeriods: null == remainingPeriods ? _self.remainingPeriods : remainingPeriods // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,defaultAccountName: freezed == defaultAccountName ? _self.defaultAccountName : defaultAccountName // ignore: cast_nullable_to_non_nullable
as String?,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TodoItem {

 int get id; String get type; String get title; String get content; String get bizId; String get status; String? get createdAt;
/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoItemCopyWith<TodoItem> get copyWith => _$TodoItemCopyWithImpl<TodoItem>(this as TodoItem, _$identity);

  /// Serializes this TodoItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.bizId, bizId) || other.bizId == bizId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,content,bizId,status,createdAt);

@override
String toString() {
  return 'TodoItem(id: $id, type: $type, title: $title, content: $content, bizId: $bizId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TodoItemCopyWith<$Res>  {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) _then) = _$TodoItemCopyWithImpl;
@useResult
$Res call({
 int id, String type, String title, String content, String bizId, String status, String? createdAt
});




}
/// @nodoc
class _$TodoItemCopyWithImpl<$Res>
    implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._self, this._then);

  final TodoItem _self;
  final $Res Function(TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? content = null,Object? bizId = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,bizId: null == bizId ? _self.bizId : bizId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoItem].
extension TodoItemPatterns on TodoItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoItem value)  $default,){
final _that = this;
switch (_that) {
case _TodoItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoItem value)?  $default,){
final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String type,  String title,  String content,  String bizId,  String status,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.bizId,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String type,  String title,  String content,  String bizId,  String status,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TodoItem():
return $default(_that.id,_that.type,_that.title,_that.content,_that.bizId,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String type,  String title,  String content,  String bizId,  String status,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TodoItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.content,_that.bizId,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodoItem implements TodoItem {
  const _TodoItem({this.id = 0, this.type = '', this.title = '', this.content = '', this.bizId = '', this.status = 'PENDING', this.createdAt});
  factory _TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String type;
@override@JsonKey() final  String title;
@override@JsonKey() final  String content;
@override@JsonKey() final  String bizId;
@override@JsonKey() final  String status;
@override final  String? createdAt;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoItemCopyWith<_TodoItem> get copyWith => __$TodoItemCopyWithImpl<_TodoItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodoItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.bizId, bizId) || other.bizId == bizId)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,content,bizId,status,createdAt);

@override
String toString() {
  return 'TodoItem(id: $id, type: $type, title: $title, content: $content, bizId: $bizId, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TodoItemCopyWith<$Res> implements $TodoItemCopyWith<$Res> {
  factory _$TodoItemCopyWith(_TodoItem value, $Res Function(_TodoItem) _then) = __$TodoItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String type, String title, String content, String bizId, String status, String? createdAt
});




}
/// @nodoc
class __$TodoItemCopyWithImpl<$Res>
    implements _$TodoItemCopyWith<$Res> {
  __$TodoItemCopyWithImpl(this._self, this._then);

  final _TodoItem _self;
  final $Res Function(_TodoItem) _then;

/// Create a copy of TodoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? content = null,Object? bizId = null,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_TodoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,bizId: null == bizId ? _self.bizId : bizId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
