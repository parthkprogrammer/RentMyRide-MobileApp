import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/theme.dart';

part '../widget/auth/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.user;
  bool _isSignUp = false;
  bool _isSubmitting = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  ({String email, String password}) _demoCredentialsFor(UserRole role) {
    switch (role) {
      case UserRole.user:
        return (email: 'alex@example.com', password: 'password123');
      case UserRole.owner:
        return (email: 'marcus@example.com', password: 'password123');
      case UserRole.admin:
        return (email: 'admin@rentmyride.com', password: 'admin123');
    }
  }

  Future<void> _submit() async {
    final userService = context.read<UserService>();
    try {
      setState(() => _isSubmitting = true);

      // One-tap demo login: if fields are empty, use the default sample account
      // for the selected role.
      if (!_isSignUp &&
          _emailController.text.trim().isEmpty &&
          _passwordController.text.trim().isEmpty) {
        final demo = _demoCredentialsFor(_selectedRole);
        _emailController.text = demo.email;
        _passwordController.text = demo.password;
      }

      final user =
          _isSignUp
              ? await userService.signUp(
                name: _nameController.text,
                email: _emailController.text,
                password: _passwordController.text,
                role: _selectedRole,
              )
              : await userService.login(
                _emailController.text,
                _passwordController.text,
              );

      if (user != null && mounted) {
        if (!_isSignUp && user.role != _selectedRole) {
          _showSnack(
            'This account is a ${user.role.name.toUpperCase()} account. Switch role to continue.',
          );
          return;
        }
        switch (user.role) {
          case UserRole.user:
            context.go('/user-dashboard');
            break;
          case UserRole.owner:
            context.go('/owner-dashboard');
            break;
          case UserRole.admin:
            context.go('/admin-dashboard');
            break;
        }
      }
    } catch (e) {
      _showSnack((_isSignUp ? 'Sign up failed: ' : 'Login failed: ') + e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onGooglePressed() => _showSnack(
    'Google sign-in needs a backend. Open the Firebase or Supabase panel in Dreamflow and complete setup first.',
  );

  void _onApplePressed() => _showSnack(
    'Apple sign-in needs a backend. Open the Firebase or Supabase panel in Dreamflow and complete setup first.',
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final secondaryTextColor =
        isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'RentMyRide',
                style: context.textStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Premium vehicle rentals at your fingertips',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Select your role',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: RoleChip(
                      label: 'USER',
                      icon: Icons.person_rounded,
                      desc: 'Rent vehicles',
                      isSelected: _selectedRole == UserRole.user,
                      onTap: () => setState(() => _selectedRole = UserRole.user),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RoleChip(
                      label: 'OWNER',
                      icon: Icons.key_rounded,
                      desc: 'List vehicles',
                      isSelected: _selectedRole == UserRole.owner,
                      onTap: () => setState(() => _selectedRole = UserRole.owner),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RoleChip(
                      label: 'ADMIN',
                      icon: Icons.admin_panel_settings_rounded,
                      desc: 'Manage all',
                      isSelected: _selectedRole == UserRole.admin,
                      onTap: () => setState(() => _selectedRole = UserRole.admin),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child:
                    _isSignUp
                        ? Column(
                          key: const ValueKey('signup_fields'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Full Name',
                              style: context.textStyles.labelMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'e.g. Jordan Lee',
                                prefixIcon: Icon(
                                  Icons.badge_outlined,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        )
                        : const SizedBox.shrink(key: ValueKey('login_fields')),
              ),

              Text(
                'Email Address',
                style: context.textStyles.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined, color: secondaryTextColor),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Password',
                    style: context.textStyles.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Forgot Password?',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _isSubmitting ? null : _submit(),
                decoration: InputDecoration(
                  hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: secondaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child:
                    _isSubmitting
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(_isSignUp ? 'Create Account' : 'Sign In'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: Divider(color: dividerColor)),
                  Padding(
                    padding: AppSpacing.horizontalSm,
                    child: Text(
                      'OR',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: dividerColor)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      label: 'Google',
                      surfaceColor: surfaceColor,
                      dividerColor: dividerColor,
                      onTap: _onGooglePressed,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SocialButton(
                      label: 'Apple',
                      surfaceColor: surfaceColor,
                      dividerColor: dividerColor,
                      onTap: _onApplePressed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp
                        ? 'Already have an account? '
                        : 'Don\'t have an account? ',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => setState(() {
                          _isSignUp = !_isSignUp;
                          _passwordController.clear();
                        }),
                    child: Text(
                      _isSignUp ? 'Sign In' : 'Create Account',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
