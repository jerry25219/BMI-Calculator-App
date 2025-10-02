
abstract class ApplicationState {
  const ApplicationState();
}

class ApplicationErrorState extends ApplicationState {
  final String error;
  ApplicationErrorState({required this.error});
}

class ApplicationInitialState extends ApplicationState {
  const ApplicationInitialState();
}

class ApplicationRegisteringState extends ApplicationState {
  const ApplicationRegisteringState();
}

class ApplicationReadyState extends ApplicationState {
  final List<String>? domains;
  const ApplicationReadyState({this.domains});
}
