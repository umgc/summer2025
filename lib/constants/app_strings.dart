class AppStrings {
  // General UI
  static const String appName = 'FocusEd AI';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String loading = 'Loading...';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String connectionError = 'No internet connection. Check your network settings.';

  // Authentication
  static const String appWelcome = 'Welcome to FocusEd AI!';
  static const String loginTitle = 'Login';
  static const String loginDirections = 'For Moodle, please log in with your Moodle URL, username, and password. For Google Classroom, please sign in with Google below.';
  static const String moodleUrlLabel = 'Moodle URL';
  static const String moodleUrlHint = 'https://[Moodle domain]/moodle';
  static const String usernameLabel = 'Moodle Username';
  static const String usernameHint = 'Moodle User';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Your password';
  static const String signInWithMoodleButton = 'Sign in with Moodle';
  static const String orContinueWith = 'Google Classroom';
  static const String googleButton = 'Continue with Google';
  static const String termsAndPrivacyText = 'By clicking continue, you agree to our Terms of Service and Privacy Policy';
  static const String loginFailed = 'Login failed';
  static const String googleSignInFailed = 'Google Sign-in failed';

  // Validation Errors (used in LoginScreen's TextFormField validators)
  static const String moodleUrlEmptyError = 'Please enter your Moodle URL';
  static const String moodleUrlValidityError = 'Please enter a valid URL starting with http:// or https://';
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