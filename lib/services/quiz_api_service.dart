import '../models/question.dart';

class QuizService {
  List<Question> getQuestions() {
    return [
      Question(
        category: 'География',
        question: 'Какая страна является самой большой по площади в мире?',
        correctAnswer: 'Россия',
        incorrectAnswers: ['Канада', 'Китай', 'США'],
      ),
      Question(
        category: 'История',
        question: 'В каком году произошла Октябрьская революция?',
        correctAnswer: '1917',
        incorrectAnswers: ['1905', '1914', '1922'],
      ),
      Question(
        category: 'Литература',
        question: 'Кто написал роман "Война и мир"?',
        correctAnswer: 'Лев Толстой',
        incorrectAnswers: ['Фёдор Достоевский', 'Антон Чехов', 'Иван Тургенев'],
      ),
      Question(
        category: 'Наука',
        question: 'Какая планета Солнечной системы самая большая?',
        correctAnswer: 'Юпитер',
        incorrectAnswers: ['Сатурн', 'Нептун', 'Земля'],
      ),
      Question(
        category: 'Кино',
        question: 'Какой актер сыграл роль Джеймса Бонда в фильме "Казино Рояль"?',
        correctAnswer: 'Дэниел Крэйг',
        incorrectAnswers: ['Шон Коннери', 'Пирс Броснан', 'Тимоти Далтон'],
      ),
      Question(
        category: 'Спорт',
        question: 'В каком году Москва принимала летние Олимпийские игры?',
        correctAnswer: '1980',
        incorrectAnswers: ['1972', '1988', '1996'],
      ),
      Question(
        category: 'Музыка',
        question: 'Какая группа исполнила песню "Брось"?',
        correctAnswer: 'Ленинград',
        incorrectAnswers: ['ДДТ', 'Кино', 'Алиса'],
      ),
      Question(
        category: 'Кулинария',
        question: 'Какой суп считается традиционным русским блюдом?',
        correctAnswer: 'Щи',
        incorrectAnswers: ['Гаспачо', 'Минестроне', 'Том-ям'],
      ),
      Question(
        category: 'Искусство',
        question: 'Кто написал картину "Черный квадрат"?',
        correctAnswer: 'Казимир Малевич',
        incorrectAnswers: ['Василий Кандинский', 'Пабло Пикассо', 'Винсент Ван Гог'],
      ),
      Question(
        category: 'Природа',
        question: 'Какое животное является самым быстрым на суше?',
        correctAnswer: 'Гепард',
        incorrectAnswers: ['Лев', 'Антилопа', 'Волк'],
      ),
    ];
  }
}