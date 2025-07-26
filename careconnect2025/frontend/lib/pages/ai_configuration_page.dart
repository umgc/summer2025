import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ai_config_service.dart';

class AIConfigurationPage extends StatefulWidget {
  const AIConfigurationPage({super.key});

  @override
  State<AIConfigurationPage> createState() => _AIConfigurationPageState();
}

class _AIConfigurationPageState extends State<AIConfigurationPage> {
  Widget _buildConfigForm() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(theme),
          const SizedBox(height: 24),
          _buildProviderSection(theme),
          const SizedBox(height: 24),
          _buildPersonalitySection(theme),
          const SizedBox(height: 24),
          _buildFeaturesSection(theme),
          const SizedBox(height: 24),
          _buildAdvancedSection(theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    if (user == null) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Configuration'),
        // ...existing code...
      ),
      drawer: const CommonDrawer(currentRoute: '/ai-configuration'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildConfigForm(),
    );
  }

  PatientAIConfigDTO? _currentConfig;
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  String _selectedProvider = 'DEFAULT';
  String _personality = 'PROFESSIONAL';
  bool _voiceEnabled = true;
  bool _emotionalSupport = true;
  bool _medicationReminders = true;
  bool _emergencyDetection = true;
  bool _contextMemoryEnabled = true;
  bool _medicalContextEnabled = true;
  int _maxTokens = 1000;
  double _temperature = 0.7;
  String _language = 'en';

  final List<String> _providers = [
    'DEFAULT',
    'DEEPSEEK',
    'OPENAI',
    'MEDICAL_SPECIALIST',
  ];
  final List<String> _personalities = [
    'PROFESSIONAL',
    'FRIENDLY',
    'EMPATHETIC',
    'DIRECT',
    'ENCOURAGING',
  ];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId != null) {
        final config = await AIConfigService.getPatientAIConfig(userId);
        if (config != null) {
          setState(() {
            _currentConfig = config;
            _selectedProvider = config.aiProvider;
            _personality = config.personalityStyle;
            _contextMemoryEnabled = config.contextMemoryEnabled;
            _medicalContextEnabled = config.medicalContextEnabled;
            _emergencyDetection = config.emergencyAlertsEnabled;
            _maxTokens = config.maxTokensPerSession;
            _temperature = config.temperature;
            _language = config.language;

            // Map enabled features to UI switches
            _voiceEnabled = config.enabledFeatures.contains('voice');
            _emotionalSupport = config.enabledFeatures.contains(
              'emotional_support',
            );
            _medicationReminders = config.enabledFeatures.contains(
              'medication_reminders',
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load AI configuration: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveConfiguration() async {
    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId != null) {
        // Build enabled features list
        List<String> enabledFeatures = [];
        if (_voiceEnabled) enabledFeatures.add('voice');
        if (_emotionalSupport) enabledFeatures.add('emotional_support');
        if (_medicationReminders) enabledFeatures.add('medication_reminders');

        final config = PatientAIConfigDTO(
          id: _currentConfig?.id,
          patientId: userId,
          aiProvider: _selectedProvider,
          preferences: {
            'language': _language,
            'voice_enabled': _voiceEnabled,
            'emotional_support': _emotionalSupport,
            'medication_reminders': _medicationReminders,
          },
          enabledFeatures: enabledFeatures,
          maxTokensPerSession: _maxTokens,
          temperature: _temperature,
          personalityStyle: _personality,
          contextMemoryEnabled: _contextMemoryEnabled,
          medicalContextEnabled: _medicalContextEnabled,
          language: _language,
          emergencyAlertsEnabled: _emergencyDetection,
        );

        final result = await AIConfigService.savePatientAIConfig(config);

        if (result != null) {
          setState(() => _currentConfig = result);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('AI configuration saved successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        } else {
          throw Exception('Failed to save configuration');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save configuration: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ...existing code...

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primaryContainer, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Configure your AI assistant to provide personalized care support tailored to your needs.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSection(ThemeData theme) {
    return _buildSection(
      theme,
      'AI Provider',
      Icons.android, // Changed from Icons.smart_toy for better compatibility
      [
        DropdownButtonFormField<String>(
          value: _selectedProvider,
          decoration: InputDecoration(
            labelText: 'Select AI Provider',
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          items: _providers.map((provider) {
            return DropdownMenuItem(
              value: provider,
              child: Text(
                provider,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedProvider = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPersonalitySection(ThemeData theme) {
    return _buildSection(
      theme,
      'Personality',
      Icons.person, // Changed from Icons.psychology for better compatibility
      [
        DropdownButtonFormField<String>(
          value: _personality,
          decoration: InputDecoration(
            labelText: 'Assistant Personality',
            labelStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          items: _personalities.map((personality) {
            return DropdownMenuItem(
              value: personality,
              child: Text(
                personality,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _personality = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(ThemeData theme) {
    return _buildSection(theme, 'Features', Icons.tune, [
      _buildSwitchTile(
        theme,
        'Voice Interaction',
        'Enable voice-based conversations',
        _voiceEnabled,
        (value) {
          setState(() => _voiceEnabled = value);
        },
      ),
      _buildSwitchTile(
        theme,
        'Emotional Support',
        'Provide emotional support and encouragement',
        _emotionalSupport,
        (value) {
          setState(() => _emotionalSupport = value);
        },
      ),
      _buildSwitchTile(
        theme,
        'Medication Reminders',
        'Smart medication reminder system',
        _medicationReminders,
        (value) {
          setState(() => _medicationReminders = value);
        },
      ),
      _buildSwitchTile(
        theme,
        'Emergency Detection',
        'Detect emergency situations',
        _emergencyDetection,
        (value) {
          setState(() => _emergencyDetection = value);
        },
      ),
    ]);
  }

  Widget _buildAdvancedSection(ThemeData theme) {
    return _buildSection(theme, 'Advanced Settings', Icons.settings, [
      _buildSwitchTile(
        theme,
        'Context Memory',
        'Remember conversation context',
        _contextMemoryEnabled,
        (value) {
          setState(() => _contextMemoryEnabled = value);
        },
      ),
      _buildSwitchTile(
        theme,
        'Medical Context',
        'Use medical information in responses',
        _medicalContextEnabled,
        (value) {
          setState(() => _medicalContextEnabled = value);
        },
      ),
      _buildSliderTile(
        theme,
        'Creativity (Temperature)',
        'Response creativity level',
        _temperature,
        0.0,
        1.0,
        (value) {
          setState(() => _temperature = value);
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: _maxTokens.toString(),
        decoration: InputDecoration(
          labelText: 'Max Response Length',
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          helperText: 'Maximum number of tokens in responses',
          helperStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final intValue = int.tryParse(value);
          if (intValue != null && intValue > 0) {
            setState(() => _maxTokens = intValue);
          }
        },
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _language,
        decoration: InputDecoration(
          labelText: 'Language',
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'es', child: Text('Spanish')),
          DropdownMenuItem(value: 'fr', child: Text('French')),
          DropdownMenuItem(value: 'de', child: Text('German')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _language = value);
          }
        },
      ),
    ]);
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    ThemeData theme,
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.outline.withOpacity(0.3),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
