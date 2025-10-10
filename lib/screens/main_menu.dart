import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class MainMenuScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MainMenuScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final QuizProvider _quizProvider = QuizProvider();
  String _selectedDifficulty = 'легкий';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    await _quizProvider.initializeQuestions();
  }

  void _startQuiz() {
    _quizProvider.setDifficulty(_selectedDifficulty);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quizProvider: _quizProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок и переключатель темы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Викторина',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Кружок переключения темы
                  GestureDetector(
                    onTap: () {
                      widget.onThemeToggle();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: widget.isDarkMode ? Colors.black : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Выбор сложности
              const Text(
                'Уровень сложности:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Кнопки выбора сложности
              _buildDifficultyButton('легкий'),
              const SizedBox(height: 12),
              _buildDifficultyButton('средний'),
              const SizedBox(height: 12),
              _buildDifficultyButton('сложный'),
              const SizedBox(height: 40),

              // Кнопка начала игры
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Начать викторину',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String difficulty) {
    bool isSelected = _selectedDifficulty == difficulty;

    Color getButtonColor() {
      switch (difficulty) {
        case 'легкий':
          return Colors.green;
        case 'средний':
          return Colors.orange;
        case 'сложный':
          return Colors.red;
        default:
          return Colors.blue;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? getButtonColor().withOpacity(0.2) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? getButtonColor() : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: getButtonColor(),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              difficulty.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: getButtonColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}