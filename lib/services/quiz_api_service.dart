import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuizService {
  static const String _apiUrl = 'https://opentdb.com/api.php';

  // Метод для получения вопросов из API
  Future<List<Question>> getQuestionsFromApi({
    int amount = 10,
    String difficulty = 'easy'
  }) async {
    try {
      final uri = Uri.parse('$_apiUrl?amount=$amount&difficulty=$difficulty&type=multiple');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return _parseApiResponse(response.body);
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load questions from API: $e');
    }
  }

  // Парсинг ответа от API
  List<Question> _parseApiResponse(String responseBody) {
    final jsonData = json.decode(responseBody);
    final results = jsonData['results'] as List;

    return results.map((item) {
      return Question(
        category: _decodeHtml(item['category']),
        question: _decodeHtml(item['question']),
        correctAnswer: _decodeHtml(item['correct_answer']),
        incorrectAnswers: List<String>.from(item['incorrect_answers'])
            .map(_decodeHtml)
            .toList(),
        difficulty: _mapDifficulty(item['difficulty']),
      );
    }).toList();
  }

  // Декодирование HTML entities
  String _decodeHtml(String htmlString) {
    return htmlString
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&auml;', 'ä')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&ntilde;', 'ñ');
  }

  // Маппинг сложности на русский язык
  String _mapDifficulty(String apiDifficulty) {
    switch (apiDifficulty) {
      case 'easy': return 'легкий';
      case 'medium': return 'средний';
      case 'hard': return 'сложный';
      default: return 'легкий';
    }
  }

  // Локальные вопросы (ваш существующий код)
  List<Question> getLocalQuestions() {
    return [
      // Легкие вопросы
      Question(
        category: 'География',
        question: 'Какая страна является самой большой по площади в мире?',
        correctAnswer: 'Россия',
        incorrectAnswers: ['Канада', 'Китай', 'США'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Наука',
        question: 'Какая планета Солнечной системы самая большая?',
        correctAnswer: 'Юпитер',
        incorrectAnswers: ['Сатурн', 'Нептун', 'Земля'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Спорт',
        question: 'Сколько игроков в футбольной команде?',
        correctAnswer: '11',
        incorrectAnswers: ['10', '12', '9'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Музыка',
        question: 'Сколько клавиш у стандартного фортепиано?',
        correctAnswer: '88',
        incorrectAnswers: ['76', '92', '64'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Кино',
        question: 'Кто сыграл главную роль в фильме "Железный человек"?',
        correctAnswer: 'Роберт Дауни мл.',
        incorrectAnswers: ['Крис Эванс', 'Крис Хемсворт', 'Марк Руффало'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Общие знания',
        question: 'Сколько дней в високосном году?',
        correctAnswer: '366',
        incorrectAnswers: ['365', '367', '364'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Природа',
        question: 'Какое животное является самым быстрым на суше?',
        correctAnswer: 'Гепард',
        incorrectAnswers: ['Лев', 'Антилопа', 'Волк'],
        difficulty: 'легкий',
      ),
      Question(
        category: 'Кулинария',
        question: 'Какой суп считается традиционным русским блюдом?',
        correctAnswer: 'Щи',
        incorrectAnswers: ['Гаспачо', 'Минестроне', 'Том-ям'],
        difficulty: 'легкий',
      ),

      // Средние вопросы
      Question(
        category: 'История',
        question: 'В каком году произошла Октябрьская революция?',
        correctAnswer: '1917',
        incorrectAnswers: ['1905', '1914', '1922'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Литература',
        question: 'Кто написал роман "Война и мир"?',
        correctAnswer: 'Лев Толстой',
        incorrectAnswers: ['Фёдор Достоевский', 'Антон Чехов', 'Иван Тургенев'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Кино',
        question: 'Какой актер сыграл роль Джеймса Бонда в фильме "Казино Рояль"?',
        correctAnswer: 'Дэниел Крэйг',
        incorrectAnswers: ['Шон Коннери', 'Пирс Броснан', 'Тимоти Далтон'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Спорт',
        question: 'В каком году Москва принимала летние Олимпийские игры?',
        correctAnswer: '1980',
        incorrectAnswers: ['1972', '1988', '1996'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Искусство',
        question: 'Кто написал картину "Черный квадрат"?',
        correctAnswer: 'Казимир Малевич',
        incorrectAnswers: ['Василий Кандинский', 'Пабло Пикассо', 'Винсент Ван Гог'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Музыка',
        question: 'Какая группа исполнила песню "Брось"?',
        correctAnswer: 'Ленинград',
        incorrectAnswers: ['ДДТ', 'Кино', 'Алиса'],
        difficulty: 'средний',
      ),
      Question(
        category: 'Наука',
        question: 'Какой газ преобладает в атмосфере Земли?',
        correctAnswer: 'Азот',
        incorrectAnswers: ['Кислород', 'Углекислый газ', 'Аргон'],
        difficulty: 'средний',
      ),
      Question(
        category: 'География',
        question: 'Какая река самая длинная в мире?',
        correctAnswer: 'Нил',
        incorrectAnswers: ['Амазонка', 'Янцзы', 'Миссисипи'],
        difficulty: 'средний',
      ),

      // Сложные вопросы
      Question(
        category: 'История',
        question: 'Кто был первым императором Священной Римской империи?',
        correctAnswer: 'Оттон I',
        incorrectAnswers: ['Карл Великий', 'Фридрих I', 'Генрих IV'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Наука',
        question: 'Какой химический элемент имеет атомный номер 79?',
        correctAnswer: 'Золото',
        incorrectAnswers: ['Серебро', 'Платина', 'Ртуть'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Литература',
        question: 'Кто автор философского трактата "Так говорил Заратустра"?',
        correctAnswer: 'Фридрих Ницше',
        incorrectAnswers: ['Артур Шопенгауэр', 'Иммануил Кант', 'Сёрен Кьеркегор'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Музыка',
        question: 'Кто написал оперу "Кольцо Нибелунга"?',
        correctAnswer: 'Рихард Вагнер',
        incorrectAnswers: ['Людвиг ван Бетховен', 'Вольфганг Амадей Моцарт', 'Иоганн Себастьян Бах'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'География',
        question: 'Какая страна имеет самую длинную береговую линию в мире?',
        correctAnswer: 'Канада',
        incorrectAnswers: ['Россия', 'Индонезия', 'Гренландия'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Кулинария',
        question: 'Из какой страны происходит соевый соус?',
        correctAnswer: 'Китай',
        incorrectAnswers: ['Япония', 'Корея', 'Вьетнам'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Искусство',
        question: 'В каком веке жил Леонардо да Винчи?',
        correctAnswer: 'XV век',
        incorrectAnswers: ['XIV век', 'XVI век', 'XVII век'],
        difficulty: 'сложный',
      ),
      Question(
        category: 'Философия',
        question: 'Кто является автором "Государства"?',
        correctAnswer: 'Платон',
        incorrectAnswers: ['Аристотель', 'Сократ', 'Эпикур'],
        difficulty: 'сложный',
      ),
    ];
  }

  // Метод для получения вопросов по сложности из API с fallback
  Future<List<Question>> getQuestionsByDifficulty(String difficulty) async {
    try {
      // Маппинг сложности для API
      String apiDifficulty;
      switch (difficulty) {
        case 'легкий': apiDifficulty = 'easy'; break;
        case 'средний': apiDifficulty = 'medium'; break;
        case 'сложный': apiDifficulty = 'hard'; break;
        default: apiDifficulty = 'easy';
      }

      final apiQuestions = await getQuestionsFromApi(
        amount: 8,
        difficulty: apiDifficulty,
      );

      return apiQuestions;
    } catch (e) {
      // Fallback на локальные вопросы
      print('API недоступен, используем локальные вопросы: $e');
      return getLocalQuestions()
          .where((question) => question.difficulty == difficulty)
          .toList();
    }
  }
}
