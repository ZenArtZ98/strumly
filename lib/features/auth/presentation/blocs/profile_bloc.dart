import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strumly/features/auth/domain/entities/user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';


abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {
  final String uid;

  LoadProfileEvent(this.uid);
}

class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  UpdateProfileEvent(this.profile);
}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getUserProfile(event.uid);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await updateUserProfile(event.profile);
        emit(ProfileLoaded(event.profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}
