class AppStrings {
  // General UI
  static const String appName = 'FocusEd AI'; // Used in LoginScreen
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String loading = 'Loading...';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String connectionError = 'No internet connection. Check your network settings.';

  // Authentication
  static const String appWelcome = 'Welcome to FocusEd AI!';
  static const String loginTitle = 'Login'; // Used in LoginScreen
  static const String loginDirections = 'For Moodle, please log in with your username and password. For Google Classroom, please continue with Google below.'; // Used in LoginScreen
  static const String usernameLabel = 'Moodle Username'; // Used in LoginScreen
  static const String usernameHint = 'Moodle User'; // Used in LoginScreen
  static const String passwordLabel = 'Password'; // Used in LoginScreen
  static const String passwordHint = 'Your password'; // Used in LoginScreen
  static const String signInWithMoodleButton = 'Sign in with Moodle'; // Used in LoginScreen
  static const String orContinueWith = 'Google Classroom'; // Used in LoginScreen
  static const String googleButton = 'Continue with Google'; // Used in LoginScreen
  static const String termsAndPrivacyText = 'By clicking continue, you agree to our Terms of Service and Privacy Policy'; // Used in LoginScreen
  static const String loginFailed = 'Login failed'; // Used in LoginScreen (for SnackBar)
  static const String googleSignInFailed = 'Google Sign-in failed';

  // Validation Errors (used in LoginScreen's TextFormField validators)
  static const String usernameEmptyError = 'Email cannot be empty.';
  static const String passwordEmptyError = 'Password cannot be empty.';

  // Home Screen (examples)
  static const String homeWelcomeMessage = 'Welcome, ';
  static const String teacherDashboardTitle = 'Teacher Dashboard';
  static const String studentDashboardTitle = 'Student Dashboard';
  static const String logoutButton = 'Logout';

  // Other App Specific Strings
  static const String appVersion = '1.0.0';
  static const String defaultUserDisplayName = 'Guest User';
}