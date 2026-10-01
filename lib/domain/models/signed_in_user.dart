/// Profile fields shown in the app bar after Google sign-in.
class SignedInUser {
  const SignedInUser({
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String email;
  final String? displayName;
  final String? photoUrl;
}
