import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/humor_profile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

// --- Provider ---
class HumorTestProvider extends ChangeNotifier {
  int currentStep = 1;
  final List<String> responses = [];

  void selectOption(String humorType) {
    responses.add(humorType);
    currentStep++;
    notifyListeners();
  }

  void reset() {
    currentStep = 1;
    responses.clear();
    notifyListeners();
  }
}

// --- Main UI ---
class HumorTestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'How would you react to a comedian slipping on a banana peel?',
      'options': [
        {'text': 'Laugh out loud', 'type': 'Physical'},
        {'text': 'Appreciate the timing', 'type': 'Situational'},
        {'text': 'Think of a witty remark', 'type': 'Linguistic'},
        {'text': 'Critique the cliché', 'type': 'Critical'},
      ],
    },
    {
      'question': 'What’s your favorite type of joke?',
      'options': [
        {'text': 'Puns and wordplay', 'type': 'Linguistic'},
        {'text': 'Slapstick and physical gags', 'type': 'Physical'},
        {'text': 'Stories about awkward situations', 'type': 'Situational'},
        {'text': 'Satirical takes on current events', 'type': 'Critical'},
      ],
    },
    {
      'question': 'What makes you laugh most?',
      'options': [
        {'text': 'A clever play on words', 'type': 'Linguistic'},
        {'text': 'Someone tripping over nothing', 'type': 'Physical'},
        {'text': 'An unexpected twist in a story', 'type': 'Situational'},
        {'text': 'A sharp jab at a politician', 'type': 'Critical'},
      ],
    },
    {
      'question': 'How do you handle a bad day?',
      'options': [
        {'text': 'Watch a goofy pratfall video', 'type': 'Physical'},
        {'text': 'Read a sarcastic commentary', 'type': 'Critical'},
        {'text': 'Enjoy a funny life anecdote', 'type': 'Situational'},
        {'text': 'Make a pun about it', 'type': 'Linguistic'},
      ],
    },
    {
      'question': 'What’s funniest in a movie?',
      'options': [
        {'text': 'Over-the-top fight scenes', 'type': 'Physical'},
        {'text': 'Witty one-liners', 'type': 'Linguistic'},
        {'text': 'Ridiculous plot twists', 'type': 'Situational'},
        {'text': 'Mocking clichés', 'type': 'Critical'},
      ],
    },
  ];

  final shadcn.StepperController controller = shadcn.StepperController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HumorTestProvider(),
      child: Consumer<HumorTestProvider>(
        builder: (context, provider, _) {
          if (provider.currentStep == 1) {
            return _WelcomeScreen();
          } else if (provider.currentStep <= questions.length + 1) {
            return _QuestionScreen(
              controller: controller,
              question: questions[provider.currentStep - 2]['question'],
              options: questions[provider.currentStep - 2]['options'],
              step: provider.currentStep,
              total: questions.length,
            );
          } else {
            // final humorProfileInstance = HumorProfile(userId: FirebaseAuth.instance.currentUser!.uid);
            Future.microtask(() => _handleTestCompletion(context, provider));
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// --- Welcome Screen ---
class _WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return shadcn.Center(
      child: shadcn.Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer, size: 100, color: Colors.amber[400]),
          const SizedBox(height: 10),
          shadcn.Text(
            'Let\'s find Out What Makes You Laugh',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'A few questions to create your humor profile.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 20),
          shadcn.PrimaryButton(
            onPressed: () => context.read<HumorTestProvider>().selectOption(''),
            child: const Text(
              'Start',
              style: TextStyle(decoration: TextDecoration.none),
            ),
          ),
          //add a bit more description in smaller and neutral font
        ],
      ),
    );
  }
}

// --- Question Screen ---
class _QuestionScreen extends StatelessWidget {
  final String question;
  final List options;
  final int step;
  final int total;
  final dynamic controller;

  const _QuestionScreen({
    required this.question,
    required this.options,
    required this.step,
    required this.total,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // final shadcn.StepperController controller = shadcn.StepperController();

    return Scaffold(
      appBar: AppBar(title: Text('Humor Test')),
      body: shadcn.Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: shadcn.Stepper(
              variant: shadcn.StepVariant.line,
              controller: controller,
              direction: Axis.horizontal,
              steps: [
                for (int step = 1; step <= total; step++)
                  shadcn.Step(
                    title: Text('step $step'),
                    icon: shadcn.StepNumber(
                      onPressed: () {
                        controller.jumpToStep(step);
                      },
                    ),
                    contentBuilder: (context) {
                      return shadcn.StepContainer(
                        actions: [],
                        // child: Container(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          // height: 200,
                          // color: Colors.grey[200],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.question_answer,

                                      size: 80,
                                      color: Colors.amber[400],
                                    ),

                                    Container(
                                      alignment: Alignment.center,
                                      child: shadcn.Text(
                                        question,
                                        style: TextStyle(fontSize: 24),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    ...options.map(
                                      (opt) => Column(
                                        children: [
                                          shadcn.PrimaryButton(
                                            onPressed: () {
                                              controller.nextStep();
                                              context
                                                  .read<HumorTestProvider>()
                                                  .selectOption(opt['type']);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              // decoration: BoxDecoration(
                                              //   color: Colors.grey[300],
                                              //   borderRadius: BorderRadius.circular(
                                              //     12.0,
                                              //   ),
                                              // ),
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  shadcn.Text(opt['text']),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 'Step $step',
                        // style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      );
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

void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: shadcn.AlertDialog(
              title: shadcn.Text(
                'Success',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              content: const Text(
                'Your humor profile has been saved!',
                style: TextStyle(decoration: TextDecoration.none),
              ),
              actions: [
                // TextButton(
                //   onPressed: () => Navigator.pop(context),
                //   child: const Text('OK'),
                // ),
                shadcn.PrimaryButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context); // Close the spinner
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text(
                    "Get Started",
                    style: TextStyle(decoration: TextDecoration.none),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

void _showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: shadcn.AlertDialog(
              title: shadcn.Text(
                'Error',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Failed to save your humor profile.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
  );
}

void _handleTestCompletion(
  BuildContext context,
  HumorTestProvider provider,
) async {
  // Show loading spinner
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final profile = await HumorProfile.setPreferencesFromTest(
      provider.responses,
    );
    await profile.saveToFirebase();
    Navigator.of(context).pop(); // Close spinner
    _showSuccessDialog(context); // Show success dialog
    provider.reset(); // Reset provider
  } catch (e) {
    Navigator.of(context).pop(); // Close spinner
    _showErrorDialog(context); // Show error dialog
  }
}
