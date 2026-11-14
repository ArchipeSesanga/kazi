import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/kazi_colors.dart';
import '../../../core/theme/kazi_spacing.dart';
import '../../../core/widgets/kazi_button.dart';
import '../application/onboarding_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _total = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() => _completeOnboarding();

  Future<void> _completeOnboarding() async {
    await context.read<OnboardingController>().complete();
    if (mounted) context.go(Routes.authEmail);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = [
      _Slide(
        title: l.welcomeSlide1Title,
        body: l.welcomeSlide1Body,
        illustration: _IllustrationIndex.search,
      ),
      _Slide(
        title: l.welcomeSlide2Title,
        body: l.welcomeSlide2Body,
        illustration: _IllustrationIndex.whatsapp,
      ),
      _Slide(
        title: l.welcomeSlide3Title,
        body: l.welcomeSlide3Body,
        illustration: _IllustrationIndex.publish,
      ),
    ];

    return Scaffold(
      backgroundColor: KaziColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziSpacing.screenPadding,
                vertical: KaziSpacing.sm,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kazi',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: KaziColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      l.welcomeSkip,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KaziColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _total,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideView(slide: slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(KaziSpacing.screenPadding),
              child: Column(
                children: [
                  _DotIndicator(total: _total, current: _page),
                  const SizedBox(height: KaziSpacing.xl),
                  KaziButton(
                    label: _page == _total - 1 ? l.welcomeStart : l.buttonContinue,
                    onPressed: _next,
                  ),
                  const SizedBox(height: KaziSpacing.sm),
                  KaziButton(
                    label: l.welcomeLanguageTitle,
                    onPressed: () => context.push(Routes.myLanguage),
                    variant: KaziButtonVariant.text,
                    isFullWidth: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.illustration,
  });
  final String title;
  final String body;
  final _IllustrationIndex illustration;
}

enum _IllustrationIndex { search, whatsapp, publish }

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KaziSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Illustration(type: slide.illustration),
          const SizedBox(height: KaziSpacing.xxxl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: KaziColors.ink,
            ),
          ),
          const SizedBox(height: KaziSpacing.md),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              height: 1.5,
              color: KaziColors.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.type});

  final _IllustrationIndex type;

  @override
  Widget build(BuildContext context) {
    final (bg, icon) = switch (type) {
      _IllustrationIndex.search => (KaziColors.primarySurface, Icons.search_rounded),
      _IllustrationIndex.whatsapp => (const Color(0xFFE6FAF0), Icons.chat_bubble_rounded),
      _IllustrationIndex.publish => (const Color(0xFFFFF1EA), Icons.add_circle_rounded),
    };

    final iconColor = switch (type) {
      _IllustrationIndex.search => KaziColors.primary,
      _IllustrationIndex.whatsapp => KaziColors.whatsapp,
      _IllustrationIndex.publish => KaziColors.accent,
    };

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 88, color: iconColor),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? KaziColors.primary : KaziColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
