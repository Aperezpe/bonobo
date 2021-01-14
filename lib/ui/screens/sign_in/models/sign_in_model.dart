import 'package:bonobo/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../validators.dart';

enum EmailSignInFormType { signIn, signUp }

class SignInModel with EmailAndPasswordValidators, ChangeNotifier {
  SignInModel({
    @required this.auth,
    this.name = '',
    this.email = '',
    this.password = '',
    this.retypePassword = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });

  final AuthBase auth;
  String name;
  String password;
  String retypePassword;
  String email;
  EmailSignInFormType formType;
  bool isLoading;
  bool submitted;

  Future<void> submit() async {
    updateWith(submitted: true, isLoading: true);
    try {
      if (formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(
          email,
          password,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          name,
          email,
          password,
        );
      }
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  String get primaryText {
    return formType == EmailSignInFormType.signIn
        ? 'Sign In'
        : 'Create an account';
  }

  String get secondaryText {
    return formType == EmailSignInFormType.signIn
        ? 'Need an account? Sign Up'
        : 'Have an account? Sing In';
  }

  String get socialMediaText {
    return formType == EmailSignInFormType.signIn
        ? 'Sign In with:'
        : 'Sing Up with:';
  }

  bool get canSubmit =>
      emailValidator.isValid(email) &&
      passwordValidator.isValid(password) &&
      !isLoading;

  String get nameErrorText {
    bool showErrorText = submitted && !nameValidator.isValid(name);
    return showErrorText ? invalidNameErrorText : null;
  }

  String get emailErrorText {
    bool showErrorText = submitted && !emailValidator.isValid(email);
    return showErrorText ? invalidEmailErrorText : null;
  }

  String get passwordErrorText {
    bool showErrorText = submitted && !passwordValidator.isValid(password);
    return showErrorText ? invalidPasswordErrorText : null;
  }

  void toogleFormType() {
    final formType = this.formType == EmailSignInFormType.signIn
        ? EmailSignInFormType.signUp
        : EmailSignInFormType.signIn;
    updateWith(
      name: '',
      email: '',
      password: '',
      retypePassword: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  void updateName(String name) => updateWith(name: name);
  void updateEmail(String email) => updateWith(email: email);
  void updatePassword(String password) => updateWith(password: password);
  void updateRetypePassword(String retypePassword) =>
      updateWith(retypePassword: retypePassword);

  void updateWith({
    String name,
    String email,
    String password,
    String retypePassword,
    EmailSignInFormType formType,
    bool isLoading,
    bool submitted,
  }) {
    this.name = name ?? this.name;
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.retypePassword = retypePassword ?? this.retypePassword;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      updateWith(isLoading: true);
      return await signInMethod();
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);
}
