import '../application/answer_question.dart';
import '../application/finish_quiz_session.dart';
import '../application/load_level_map.dart';
import '../application/manage_score.dart';
import '../application/ports/clock.dart';
import '../application/ports/logger.dart';
import '../application/ports/question_repository.dart';
import '../application/ports/random_source.dart';
import '../application/reset_level_progress.dart';
import '../application/start_quiz_session.dart';
import '../infrastructure/content/asset_question_repository.dart';
import '../infrastructure/content/asset_reader.dart';
import '../infrastructure/logging/debug_logger.dart';
import '../infrastructure/random/seeded_random_source.dart';
import '../infrastructure/storage/key_value_store.dart';
import '../infrastructure/storage/prefs_state_repository.dart';
import '../infrastructure/time/system_clock.dart';

/// Racine de composition : **seul** endroit qui connaît les implémentations
/// (ADR-01). Le reste du code ne dépend que d'abstractions.
final class AppDependencies {
  const AppDependencies({
    required this.loadLevelMap,
    required this.startQuizSession,
    required this.answerQuestion,
    required this.finishQuizSession,
    required this.resetLevelProgress,
    required this.readTotalScore,
    required this.resetTotalScore,
    required this.questionRepository,
    required this.clock,
  });

  /// Construit les dépendances de production.
  static Future<AppDependencies> production({
    Logger logger = const DebugLogger(),
  }) async {
    final store = await SharedPreferencesStore.open();
    return create(
      store: store,
      reader: const FlutterAssetReader(),
      clock: SystemClock(),
      random: SeededRandomSource(),
      logger: logger,
    );
  }

  /// Construit les dépendances à partir d'implémentations fournies
  /// (utilisé par les tests d'intégration et d'ensemble).
  static AppDependencies create({
    required KeyValueStore store,
    required AssetReader reader,
    required Clock clock,
    required RandomSource random,
    required Logger logger,
    Duration perQuestion = const Duration(seconds: 10),
  }) {
    final state = PrefsStateRepository(store: store, logger: logger);
    final questions = AssetQuestionRepository(reader: reader);
    return AppDependencies(
      loadLevelMap: LoadLevelMap(questions: questions, state: state),
      startQuizSession: StartQuizSession(
        questions: questions,
        random: random,
        clock: clock,
        perQuestion: perQuestion,
      ),
      answerQuestion: AnswerQuestion(clock: clock),
      finishQuizSession: FinishQuizSession(state: state, logger: logger),
      resetLevelProgress: ResetLevelProgress(state: state),
      readTotalScore: ReadTotalScore(state: state),
      resetTotalScore: ResetTotalScore(state: state),
      questionRepository: questions,
      clock: clock,
    );
  }

  final LoadLevelMap loadLevelMap;
  final StartQuizSession startQuizSession;
  final AnswerQuestion answerQuestion;
  final FinishQuizSession finishQuizSession;
  final ResetLevelProgress resetLevelProgress;
  final ReadTotalScore readTotalScore;
  final ResetTotalScore resetTotalScore;
  final QuestionRepository questionRepository;

  /// Horloge partagée par l'interface et les cas d'usage (IF-07).
  final Clock clock;
}
