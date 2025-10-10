import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizProvider _quizProvider = QuizProvider();

  @override
  void initState() {
    super.initState();
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
        title: const Text('Русская Викторина'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: _buildBody(),
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
          SizedBox(height: 20),
          Text(
            'Загружаем вопросы...',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _quizProvider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _loadQuestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Вопросы не загружены',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadQuestions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: const Text('Загрузить вопросы'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen() {
    final question = _quizProvider.currentQuestion;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Прогресс бар
          LinearProgressIndicator(
            value: _quizProvider.progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),

          // Счет и прогресс
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Счет: ${_quizProvider.score}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                'Вопрос ${_quizProvider.currentQuestionIndex + 1}/${_quizProvider.totalQuestions}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Категория
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Вопрос
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ответы
          Expanded(
            child: ListView.builder(
              itemCount: _quizProvider.currentShuffledAnswers.length,
              itemBuilder: (context, index) {
                final answer = _quizProvider.currentShuffledAnswers[index];
                return _buildAnswerButton(answer);
              },
            ),
          ),

          // Кнопка действия
          const SizedBox(height: 16),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String answer) {
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;
    String? label;

    // Подсветка выбранного ответа (даже если еще не подтвержден)
    bool isSelected = _quizProvider.isSelectedAnswer(answer);

    if (_quizProvider.answerSubmitted) {
      if (_quizProvider.isCorrectAnswer(answer)) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check;
        label = 'ПРАВИЛЬНЫЙ ОТВЕТ';
      } else if (_quizProvider.isWrongAnswer(answer)) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.close;
        label = 'НЕПРАВИЛЬНЫЙ ОТВЕТ';
      }
    } else if (isSelected) {
      // Подсветка выбранного (но еще не подтвержденного) ответа
      backgroundColor = Colors.blue[100];
      textColor = Colors.blue[900];
    }

    return Card(
      color: backgroundColor,
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: textColor) : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
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
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_quizProvider.answerSubmitted && _quizProvider.isLastQuestion) {
      return Column(
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.celebration, size: 48, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Викторина завершена!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ваш результат: ${_quizProvider.score}/${_quizProvider.totalQuestions * 10}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getResultMessage(_quizProvider.score, _quizProvider.totalQuestions * 10),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _quizProvider.restartQuiz();
              _refreshUI();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Начать новую викторину',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    if (_quizProvider.answerSubmitted && !_quizProvider.isLastQuestion) {
      return ElevatedButton(
        onPressed: () {
          _quizProvider.nextQuestion();
          _refreshUI();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Следующий вопрос',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _quizProvider.selectedAnswer != null ? () {
        _quizProvider.submitAnswer();
        _refreshUI();
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _quizProvider.selectedAnswer != null ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'Подтвердить ответ',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  String _getResultMessage(int score, int maxScore) {
    final percentage = score / maxScore;
    if (percentage >= 0.8) return 'Отличный результат! Вы настоящий эрудит!';
    if (percentage >= 0.6) return 'Хороший результат! Вы хорошо разбираетесь во многих темах!';
    if (percentage >= 0.4) return 'Неплохой результат! Есть куда стремиться!';
    return 'Попробуйте еще раз! У вас все получится!';
  }
}