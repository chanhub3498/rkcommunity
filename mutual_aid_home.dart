import 'dart:async';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// DESIGN TOKENS & PALETTE (Warmth & Hearth theme)
// -----------------------------------------------------------------------------
class AppColors {
  static const Color background = Color(0xFFFFF8F3);
  static const Color onBackground = Color(0xFF1F1B15);
  static const Color surface = Color(0xFFFFF8F3);
  static const Color onSurface = Color(0xFF1F1B15);
  
  static const Color primary = Color(0xFF3E6842);
  static const Color primaryContainer = Color(0xFF8FBC8F);
  static const Color onPrimaryContainer = Color(0xFF234C29);
  
  static const Color secondary = Color(0xFF755B00);
  static const Color secondaryContainer = Color(0xFFFCCC38);
  static const Color onSecondaryContainer = Color(0xFF6F5600);
  static const Color onSecondaryFixedVariant = Color(0xFF584400);

  static const Color tertiary = Color(0xFFA13F20);
  static const Color tertiaryContainer = Color(0xFFFF9475);
  static const Color onTertiaryContainer = Color(0xFF7D2507);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color surfaceContainerLow = Color(0xFFFCF2E7);
  static const Color surfaceContainerHigh = Color(0xFFF0E7DC);
  static const Color surfaceContainerHighest = Color(0xFFEAE1D6);
  static const Color outline = Color(0xFF727970);
  static const Color outlineVariant = Color(0xFFC2C9BE);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double base = 8.0;
  static const double sm = 12.0;
  static const double md = 20.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double containerPadding = 20.0;
}

// -----------------------------------------------------------------------------
// APP ENTRY POINT & RUNNABLE HOST (For demo/testing)
// -----------------------------------------------------------------------------
void main() {
  runApp(const MutualAidApp());
}

class MutualAidApp extends StatelessWidget {
  const MutualAidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workplace Help',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
          onBackground: AppColors.onBackground,
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          tertiary: AppColors.tertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
        ),
      ),
      home: const MutualAidHomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN STATE ENUM
// -----------------------------------------------------------------------------
enum HelpState {
  idle,
  broadcasting, // Countdown/Grace period
  tracking,     // Map/Search simulation
  completion    // Success Modal/Selection
}

// -----------------------------------------------------------------------------
// MAIN HOME SCREEN
// -----------------------------------------------------------------------------
class MutualAidHomeScreen extends StatefulWidget {
  const MutualAidHomeScreen({Key? key}) : super(key: key);

  @override
  State<MutualAidHomeScreen> createState() => _MutualAidHomeScreenState();
}

class _MutualAidHomeScreenState extends State<MutualAidHomeScreen> {
  HelpState _currentState = HelpState.idle;
  String _selectedCategory = 'heavy'; // heavy, tech, medical
  int _credits = 120;
  
  // Timer state variables
  int _countdownSeconds = 3;
  Timer? _countdownTimer;
  
  // Tracking state simulator variables
  bool _helperAccepted = false;
  Timer? _acceptanceTimer;

  // Completion Dialog helpers
  String _selectedHelper = 'Neoh'; // Neoh or Sarah

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _acceptanceTimer?.cancel();
    super.dispose();
  }

  // Transitions
  void _startRequestBroadcast(String category) {
    setState(() {
      _selectedCategory = category;
      _currentState = HelpState.broadcasting;
      _countdownSeconds = 3;
      _helperAccepted = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        timer.cancel();
        _goToTrackingState();
      }
    });
  }

  void _cancelBroadcast() {
    _countdownTimer?.cancel();
    setState(() {
      _currentState = HelpState.idle;
    });
  }

  void _goToTrackingState() {
    setState(() {
      _currentState = HelpState.tracking;
    });

    // Simulate helper accepting after 3 seconds
    _acceptanceTimer?.cancel();
    _acceptanceTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _currentState == HelpState.tracking) {
        setState(() {
          _helperAccepted = true;
        });
      }
    });
  }

  void _finishRequest() {
    setState(() {
      _currentState = HelpState.completion;
    });
  }

  void _confirmCompletion() {
    // Reward credits animation/toast
    setState(() {
      _currentState = HelpState.idle;
      _credits -= 20; // deduct some credits
    });
    
    // Show custom toast/snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: 100),
        content: Row(
          children: const [
            Icon(Icons.favorite, color: AppColors.primaryContainer),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Thank you for spreading the warmth! ❤️',
              style: TextStyle(
                color: AppColors.background,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top App Bar
                _buildTopAppBar(),
                
                // Main Content View
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.containerPadding,
                        vertical: AppSpacing.base,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildCurrentStateView(),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Nav Bar (Hidden during broadcasting/completion modal overlay)
                if (_currentState != HelpState.broadcasting) _buildBottomNavBar(),
              ],
            ),
            
            // Completion Modal Overlay
            if (_currentState == HelpState.completion) _buildCompletionOverlay(),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // WIDGET BUILDERS
  // -----------------------------------------------------------------------------

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceContainerHigh, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAl7IpSlDN3b_o3e_M7rYVAwYwjt9b2r_LGT6sG20YyltZfJwSv-ANC50-Ze6-2Dxt4dNjWxslQH9EfC8cPlNro_Lnj9kiDsE6NSFdzdBIEZP_SPqw9hcebdgRfCWpa-xAsf0Ohl7aMoacwxKQwq-t5NcltSO-2uHJp71qndUMeP7jjzob87msKQnNQGrccN_SeaM1EqbCvd6xk6ufIoWx8mNswy0vHBc3OnPP9b7w8QQDqZRXz8Vph',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hello, Alex!',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                    ),
                  ),
                  Text(
                    'Workplace Help',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bakery_dining,
                  color: AppColors.secondary,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_credits Credits',
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSecondaryFixedVariant,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_currentState) {
      case HelpState.idle:
        return _buildIdleView();
      case HelpState.broadcasting:
        return _buildBroadcastingView();
      case HelpState.tracking:
        return _buildTrackingView();
      case HelpState.completion:
        return Container(); // Controlled by overlay
    }
  }

  // --- IDLE VIEW ---
  Widget _buildIdleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'How can we help?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const Text(
          'Hold button to broadcast request',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Be Vietnam Pro',
            fontSize: 14,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Broadcast Buttons
        _LongPressBroadcastButton(
          title: '📦 Heavy Load!',
          subtitle: 'Food, catering, groceries',
          icon: Icons.inventory_2,
          backgroundColor: AppColors.primaryContainer,
          onComplete: () => _startRequestBroadcast('heavy'),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        
        _LongPressBroadcastButton(
          title: '🔧 Tech Breakdown',
          subtitle: 'Machine or IT glitch',
          icon: Icons.build,
          backgroundColor: AppColors.secondaryContainer,
          onComplete: () => _startRequestBroadcast('tech'),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        
        _LongPressBroadcastButton(
          title: '🚨 Medical Help',
          subtitle: 'Injuries or unwell',
          icon: Icons.medical_services,
          backgroundColor: AppColors.tertiaryContainer,
          onComplete: () => _startRequestBroadcast('medical'),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        // Community Scorecard
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Community Spirit',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '42 helps completed today',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Overlapping Avatar Stack
              SizedBox(
                width: 72,
                height: 32,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDHaAS313hH3t0YFe7bWsq--J0smoMqNckgoSq380JX1l3Yx_i0lCet2o_VnNJTBbA3wjaj64teGZ943ET-fZ8gHsTrh8UwueG8oN1RxJMPjHlwYxbDKD249HN13L-T2jIEFLiUxLrZrEbU8Fr1IP0Z2-nCKwRJNr4RPDN1OoF-7KOBJ1ad0Dti6tK1UThbtmxCTtG8LHi5CrD58hGiVrm_ZoLvDyFV3vv2ttqL_uvq1yZp1Zg4DZYr'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBhhseSu0LJZrlumUM4myw49-PrKFrdkhVoRl7ucQa0uUeEixG8jE1Txl7ckSle31gOcnoGkN1Hi55MuYsaVTC1rMOCuDjwLXl0CM1pKbbFC-fCEwPOF4X_ctMQoHWgeO277y8JRrlcnck1ACVpwvVwqvMY8BXN6t7ZP2ep1IEJuv75Gi1AZyEibjSoeWcHnMcn5DIsHc1VeOX8uTxpz78TAymXEpXyBHxsxCA6rxtXn4gZHItekxGj'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 36,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHighest,
                          border: Border.all(color: AppColors.surfaceContainerLow, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            '+12',
                            style: TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // --- BROADCASTING VIEW ---
  Widget _buildBroadcastingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3), width: 2),
          ),
          child: Column(
            children: [
              // Bouncy Countdown Circular Indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _countdownSeconds / 3.0,
                      strokeWidth: 6,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    Text(
                      '$_countdownSeconds',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Broadcasting request...',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'You have 3 seconds to cancel',
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Cancel Button
              ElevatedButton.icon(
                onPressed: _cancelBroadcast,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancel Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TRACKING VIEW ---
  Widget _buildTrackingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D574F).withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const Text(
                    'Req #8821',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Hand-drawn dog trolley animation mockup (Custom widget with animation)
              Container(
                height: 128,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const _AnimatedTrolleyMockup(),
              ),
              const SizedBox(height: AppSpacing.md),
              
              const Text(
                'Finding someone to help...',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your "${_selectedCategory.toUpperCase()} LOAD" request is visible to team members nearby.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Helper Tags
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 2),
                    ),
                    child: const Text('Guardhouse Pick-up', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 2),
                    ),
                    child: const Text('Need Trolley', style: TextStyle(fontSize: 11)),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Accepted Notification Panel (Animated)
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _helperAccepted
              ? Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5D574F).withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDHaAS313hH3t0YFe7bWsq--J0smoMqNckgoSq380JX1l3Yx_i0lCet2o_VnNJTBbA3wjaj64teGZ943ET-fZ8gHsTrh8UwueG8oN1RxJMPjHlwYxbDKD249HN13L-T2jIEFLiUxLrZrEbU8Fr1IP0Z2-nCKwRJNr4RPDN1OoF-7KOBJ1ad0Dti6tK1UThbtmxCTtG8LHi5CrD58hGiVrm_ZoLvDyFV3vv2ttqL_uvq1yZp1Zg4DZYr'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kao-tim! Neoh has accepted!',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                              Text(
                                'Arriving in ~2 mins',
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 14,
                                  color: AppColors.onSecondaryContainer,
                                  opacity: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.onSecondaryContainer,
                        ),
                        child: const Icon(
                          Icons.call,
                          color: AppColors.secondaryContainer,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ),
        
        // Done Button (Only clickable once accepted)
        ElevatedButton.icon(
          onPressed: _helperAccepted ? _finishRequest : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('✨ Kao-tim (Done)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            textStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- COMPLETION DIALOG OVERLAY ---
  Widget _buildCompletionOverlay() {
    return Container(
      color: AppColors.onBackground.withOpacity(0.4),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        maxHeight: 500,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mission Success!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Who helped you sweat it out today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 16,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Helpers select list
            _buildHelperChoice('Neoh', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDm4RbShA6ZyMiO4DJF2ulxIg_CVMPVVNPGgpsaPasgtCrYPmavQ86fuk5sibyNdV1uLhd-vfh45zagKSCSf99DLeb3oRgy0_uDDLJVlakTmmzPLv9yjVnWOs899lR1j-T8pF0lco5MkZ2n7n26xHqBMZ-wIEcNIaAsJsrkCaK6PXoT5IBuy5GL0EIwk-gg_zRwhzNqdI50sfHXMv6vJyYGBKNdCeVdYRCz638lA_uR6NpCTWU66t5Z'),
            const SizedBox(height: AppSpacing.sm),
            _buildHelperChoice('Sarah (Security)', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBhhseSu0LJZrlumUM4myw49-PrKFrdkhVoRl7ucQa0uUeEixG8jE1Txl7ckSle31gOcnoGkN1Hi55MuYsaVTC1rMOCuDjwLXl0CM1pKbbFC-fCEwPOF4X_ctMQoHWgeO277y8JRrlcnck1ACVpwvVwqvMY8BXN6t7ZP2ep1IEJuv75Gi1AZyEibjSoeWcHnMcn5DIsHc1VeOX8uTxpz78TAymXEpXyBHxsxCA6rxtXn4gZHItekxGj'),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Confirm Button
            ElevatedButton(
              onPressed: _confirmCompletion,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.onSecondaryContainer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                textStyle: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Confirm & Give Credits'),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Both helpers will receive 20 Snack Credits each',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 11,
                color: AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelperChoice(String name, String imageUrl) {
    bool isSelected = _selectedHelper == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHelper = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            )
          ],
        ),
      ),
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D574F).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: const [
                Icon(Icons.home, color: AppColors.onSecondaryContainer),
                SizedBox(width: 4),
                Text(
                  'Home',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks
          IconButton(
            onPressed: () {},
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.assignment, color: AppColors.outline),
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          
          // Shop
          IconButton(
            onPressed: () {},
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.storefront, color: AppColors.outline),
                Text(
                  'Shop',
                  style: TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BROADCAST BUTTON - DETECTS LONG PRESS
// -----------------------------------------------------------------------------
class _LongPressBroadcastButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onComplete;

  const _LongPressBroadcastButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  State<_LongPressBroadcastButton> createState() => _LongPressBroadcastButtonState();
}

class _LongPressBroadcastButtonState extends State<_LongPressBroadcastButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2 seconds hold to trigger
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
        _controller.reset();
        setState(() {
          _isPressing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isPressing = true;
    });
    _controller.forward();
  }

  void _onPressEnd() {
    setState(() {
      _isPressing = false;
    });
    if (!_controller.isCompleted) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onPressStart(),
      onTapUp: (_) => _onPressEnd(),
      onTapCancel: () => _onPressEnd(),
      child: AnimatedScale(
        scale: _isPressing ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D574F).withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          color: AppColors.onPrimaryContainer,
                          opacity: 0.9,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    widget.icon,
                    size: 48,
                    color: AppColors.onPrimaryContainer.withOpacity(0.2),
                  ),
                ],
              ),
              // Circular progress overlay on press
              if (_isPressing)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _RadialProgressPainter(progress: _controller.value),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RADIAL PROGRESS PAINTER FOR BUTTON PRESS
// -----------------------------------------------------------------------------
class _RadialProgressPainter extends CustomPainter {
  final double progress;

  _RadialProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width - 24, size.height / 2);
    final radius = 24.0;
    
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
      
    final progressPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
      
    canvas.drawCircle(center, radius, bgPaint);
    
    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// -----------------------------------------------------------------------------
// ANIMATED TROLLEY MOCKUP WIDGET
// -----------------------------------------------------------------------------
class _AnimatedTrolleyMockup extends StatefulWidget {
  const _AnimatedTrolleyMockup({Key? key}) : super(key: key);

  @override
  State<_AnimatedTrolleyMockup> createState() => _AnimatedTrolleyMockupState();
}

class _AnimatedTrolleyMockupState extends State<_AnimatedTrolleyMockup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -30.0, end: 30.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Track line
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Container(
            height: 2,
            color: AppColors.outlineVariant,
          ),
        ),
        // Moving trolley + dog icons
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_animation.value, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.pets,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 2),
                  Icon(
                    Icons.shopping_cart,
                    size: 28,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
