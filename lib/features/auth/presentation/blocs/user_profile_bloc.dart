import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

// Events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfileEvent extends UserProfileEvent {
  final UserProfile profile;

  const UpdateUserProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

// States
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;

  const UserProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;

  UserProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event,
      Emitter<UserProfileState> emit,
      ) async {
    emit(UserProfileLoading());
    try {
      final profile = await getUserProfile(event.userId);
      emit(UserProfileLoaded(profile));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfileEvent event,
      Emitter<UserProfileState> emit,
      ) async {
    emit(UserProfileLoading());
    try {
      await updateUserProfile(event.profile);
      // Перезагружаем данные профиля после обновления
      final updatedProfile = await getUserProfile(event.profile.uid);
      emit(UserProfileLoaded(updatedProfile));
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
