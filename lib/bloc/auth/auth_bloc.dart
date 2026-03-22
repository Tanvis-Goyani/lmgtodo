import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lmgtodo/repository/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await userRepository.login(email: event.email, password: event.password);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await userRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(_parseError(e.toString())));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await userRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Incorrect email or password';
    }
    if (error.contains('email-already-in-use')) {
      return 'Email already registered';
    }
    if (error.contains('weak-password')) {
      return 'Password must be at least 6 characters';
    }
    if (error.contains('invalid-email')) {
      return 'Please enter a valid email';
    }
    if (error.contains('network-request-failed')) {
      return 'Check your internet connection';
    }
    return 'Something went wrong. Please try again';
  }
}
