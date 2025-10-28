import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  final QuizProvider quizProvider;

  const QuizScreen({super.key, required this.quizProvider});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizProvider _quizProvider;

  @override
  void initState() {
    super.initState();
    _quizProvider = widget.quizProvider;
    _loadQuestions();
  }

  void _loadQuestions() async {
    await _quizProvider.loadQuestions();
    setState(() {});
  }

  void _refreshUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Викторина'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_quizProvider.isLoading) {
      return _buildLoadingScreen();
    }

    if (_quizProvider.error != null) {
      return _buildErrorScreen();
    }

    if (_quizProvider.questions.isEmpty) {
      return _buildEmptyScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Загружаем вопросы...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _quizProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadQuestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Попробовать снова', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // Принудительно используем локальные вопросы
                _quizProvider.setDifficulty(_quizProvider.currentDifficulty);
                _refreshUI();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Использовать локальные вопросы', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Вопросы не загружены',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Загрузить вопросы', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _quizProvider.currentQuestion;
    final screenHeight = MediaQuery.of(context).size.height;

    // Если это последний вопрос и ответ подтвержден, показываем результат
    if (_quizProvider.answerSubmitted && _quizProvider.isLastQuestion) {
      return _buildResultsScreen();
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Прогресс бар
          LinearProgressIndicator(
            value: _quizProvider.progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),

          // Счет и прогресс
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Счет: ${_quizProvider.score}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${_quizProvider.currentQuestionIndex + 1}/${_quizProvider.totalQuestions}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Индикатор источника вопросов
          if (_quizProvider.usingLocalQuestions)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Локальные вопросы',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Уровень сложности
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getDifficultyColor(_quizProvider.currentDifficulty).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDifficultyIcon(_quizProvider.currentDifficulty),
                  size: 12,
                  color: _getDifficultyColor(_quizProvider.currentDifficulty),
                ),
                const SizedBox(width: 4),
                Text(
                  'Уровень: ${_quizProvider.currentDifficulty}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDifficultyColor(_quizProvider.currentDifficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Категория
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Вопрос
          Container(
            height: screenHeight * 0.12,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Ответы
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final answer in _quizProvider.currentShuffledAnswers)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: _buildAnswerButton(answer),
                    ),
                ],
              ),
            ),
          ),

          // Кнопка действия
          const SizedBox(height: 8),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final correctAnswers = _quizProvider.score ~/ 10;
    final totalQuestions = _quizProvider.totalQuestions;
    final percentage = (correctAnswers / totalQuestions) * 100;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок результата
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 36,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  'Викторина завершена!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_quizProvider.usingLocalQuestions)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Использовались локальные вопросы',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Результаты
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Ваш результат:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_quizProvider.score}/${_quizProvider.totalQuestions * 10}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctAnswers из $totalQuestions правильных ответов',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}% правильных ответов',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getResultMessage(_quizProvider.score, _quizProvider.totalQuestions * 10),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Статистика
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Правильно', '$correctAnswers', Colors.green),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildStatItem('Неправильно', '${totalQuestions - correctAnswers}', Colors.red),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildStatItem('Процент', '${percentage.toStringAsFixed(0)}%', Colors.blue),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Кнопки действий
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _quizProvider.restartQuiz();
                  _refreshUI();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'Пройти еще раз',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text(
                  'В главное меню',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(String answer) {
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;
    String? label;

    bool isSelected = _quizProvider.isSelectedAnswer(answer);

    if (_quizProvider.answerSubmitted) {
      if (_quizProvider.isCorrectAnswer(answer)) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check;
        label = 'ПРАВИЛЬНО';
      } else if (_quizProvider.isWrongAnswer(answer)) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.close;
        label = 'НЕПРАВИЛЬНО';
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue[100];
      textColor = Colors.blue[900];
    }

    return Card(
      color: backgroundColor,
      elevation: isSelected ? 2 : 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 24,
        minVerticalPadding: 8,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: icon != null
            ? Icon(icon, color: textColor, size: 18)
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: textColor ?? Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () {
          if (!_quizProvider.answerSubmitted) {
            _quizProvider.selectAnswer(answer);
            _refreshUI();
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_quizProvider.answerSubmitted && !_quizProvider.isLastQuestion) {
      return ElevatedButton(
        onPressed: () {
          _quizProvider.nextQuestion();
          _refreshUI();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text(
          'Следующий вопрос',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    if (!_quizProvider.answerSubmitted) {
      return ElevatedButton(
        onPressed: _quizProvider.selectedAnswer != null ? () {
          _quizProvider.submitAnswer();
          _refreshUI();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _quizProvider.selectedAnswer != null ? Colors.blue : Colors.grey,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text(
          'Подтвердить ответ',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getResultMessage(int score, int maxScore) {
    final percentage = score / maxScore;
    if (percentage >= 0.8) return 'Отличный результат! 🎉\nВы настоящий эрудит!';
    if (percentage >= 0.6) return 'Хороший результат! 👍\nОтличные знания!';
    if (percentage >= 0.4) return 'Неплохой результат! 💪\nЕсть куда стремиться!';
    return 'Попробуйте еще раз! 🌟\nУ вас всё получится!';
  }

  Color _getDifficultyColor(String difficulty) {
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

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'легкий':
        return Icons.accessible_forward;
      case 'средний':
        return Icons.self_improvement;
      case 'сложный':
        return Icons.psychology;
      default:
        return Icons.help;
    }
  }
}
