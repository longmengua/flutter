import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hi365/pages/authentication/index.dart';
import 'package:hi365/pages/register/index.dart';
import 'package:hi365/utils/snackbars.dart';
import 'package:hi365/widgets/text_form_field_builder.dart';
import 'package:hi365/widgets/base_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    Key key,
    @required RegisterBloc registerBloc,
  })  : _registerBloc = registerBloc,
        super(key: key);

  final RegisterBloc _registerBloc;

  @override
  RegisterScreenState createState() => RegisterScreenState(_registerBloc);
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final RegisterBloc _registerBloc;

  bool _isEmailDirty = false;
  bool _isPasswordDirty = false;
  bool _showErrorMSg = false;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(RegisterState state) =>
      state.isFormValid && isPopulated && !state.isSubmitting;

  RegisterScreenState(this._registerBloc);

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isEmailDirty = true;
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _isPasswordDirty = true;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      bloc: widget._registerBloc,
      listener: _blocListenerHandler,
      child: BlocBuilder<RegisterBloc, RegisterState>(
        bloc: widget._registerBloc,
        builder: _blocBuilderHandler,
      ),
    );
  }

  void _blocListenerHandler(
    BuildContext context,
    RegisterState currentState,
  ) {
    if (currentState.isFailure) {
      String errMsg = currentState.errorMessage ?? '????????????';
      SnackBarBuilder.showError(context, errMsg);
    }
    if (currentState.isSubmitting) {
      SnackBarBuilder.showLoading(context, '????????????????????????');
    }
    if (currentState.isSuccess) {
      FocusScope.of(context).requestFocus(new FocusNode());
      SnackBarBuilder.showSuccess(context, '????????????');
      Future.delayed(
        Duration(seconds: 3),
        () => BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut()),
      );
    }
  }

  Widget _blocBuilderHandler(
    BuildContext context,
    RegisterState currentState,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.0),
      child: Form(
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _showEmailField(currentState),
            _showPasswordField(currentState),
            _showButtonList(currentState),
          ],
        ),
      ),
    );
  }

  Widget _showEmailField(RegisterState state) {
    return TextFormFieldBuilder(
      focusNode: _emailFocusNode,
      labelText: '????????????',
      hintText: '???????????????????????????',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validateFailureMessage:
          _showErrorMSg && !state.isEmailValid && _isEmailDirty
              ? '????????????????????????????????????'
              : null,
    );
  }

  Widget _showPasswordField(RegisterState state) {
    return TextFormFieldBuilder(
      focusNode: _passwordFocusNode,
      type: FieldType.PASSWORD,
      labelText: '??????',
      hintText: '?????????????????????',
      controller: _passwordController,
      validateFailureMessage:
          _showErrorMSg && !state.isPasswordValid && _isPasswordDirty
              ? '?????????????????????????????????????????????6???'
              : null,
    );
  }

  Widget _showButtonList(RegisterState state) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _showSignUpButton(state),
        ],
      ),
    );
  }

  Widget _showSignUpButton(RegisterState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: BaseButton(
        title: '??????',
        onPressed: () {
          showErrorMsg();
          if (isLoginButtonEnabled(state)) _onFormSubmitted();
        },
      ),
    );
  }

  void _onEmailChanged() {
    _registerBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> showErrorMsg() async {
    _showErrorMSg = true;
    setState(() {});
  }
}
