import '../models/question.dart';

class QuizService {
  List<Question> getQuestions() {
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
    ];
  }

  // Метод для получения вопросов по сложности
  List<Question> getQuestionsByDifficulty(String difficulty) {
    return getQuestions().where((question) => question.difficulty == difficulty).toList();
  }

  // Метод для получения случайных вопросов
  List<Question> getRandomQuestions(int count, {String? difficulty}) {
    List<Question> allQuestions = getQuestions();

    if (difficulty != null) {
      allQuestions = allQuestions.where((q) => q.difficulty == difficulty).toList();
    }

    allQuestions.shuffle();
    return allQuestions.length <= count ? allQuestions : allQuestions.sublist(0, count);
  }
}