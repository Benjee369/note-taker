import 'package:flutter/material.dart';
import 'package:notes/auth/sign_in_screen.dart';
import 'package:notes/shared/providers/note_provider.dart';
import 'package:notes/shared/providers/system_settings_provider.dart';
import 'package:notes/shared/providers/user_details_provider.dart';
import 'package:notes/shared/widgets/text_widget.dart';
import 'package:notes/shared/constants/strings.dart';
import 'package:notes/shared/navigation/navigation.dart';
import 'package:notes/shared/constants/app_images.dart';
import 'package:notes/shared/constants/app_sizes.dart';
import 'package:notes/features/notes/home_screen.dart';
import 'package:provider/provider.dart';
import '../shared/database/first_open_database.dart';
import '../shared/widgets/custom_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _totalSteps = 4;
  static const _startupTimeout = Duration(seconds: 8);

  int _completedSteps = 0;
  bool _isFirstOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void _completeStep() {
    if (!mounted) return;
    setState(() {
      _completedSteps++;
    });
  }

  Future<void> _loadFirstOpen() async {
    try {
      _isFirstOpen = await FirstOpenDatabase().getFirstOpenState();
    } catch (_) {
      _isFirstOpen = false;
    } finally {
      _completeStep();
    }
  }

  Future<void> _awaitStep(Future<void> step) async {
    try {
      await step;
    } catch (_) {
    } finally {
      _completeStep();
    }
  }

  Future<void> init() async {
    final user = context.read<UserDetailsProvider>();
    final systemSettings = context.read<SystemSettingsProvider>();
    final noteProvider = context.read<NoteProvider>();

    await Future.wait([
      _loadFirstOpen(),
      _awaitStep(user.initialLoad),
      _awaitStep(systemSettings.initialLoad),
      _awaitStep(noteProvider.initialLoad),
    ]).timeout(
      _startupTimeout,
      onTimeout: () => <void>[],
    );

    if (!mounted) return;

    if (_isFirstOpen && !user.isSignedIn) {
      Navigation.navigateAndReplace(
        context,
        SignInScreen(),
      );
      return;
    }

    Navigation.navigateAndReplace(
      context,
      HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: AppImages.splashImage,
                  height: 180,
                  width: 180,
                ),
                gapH12,
                TextWidget(
                  text: Strings.noteTaker,
                  size: 20,
                  fontWeight: FontWeight.bold,
                ),
                gapH20,
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    end: _completedSteps / _totalSteps,
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(value: value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
