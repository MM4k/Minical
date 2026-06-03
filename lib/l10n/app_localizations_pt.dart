// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Minical';

  @override
  String get today => 'Hoje';

  @override
  String get settings => 'Configurações';

  @override
  String get viewMonth => 'Mês';

  @override
  String get viewWeek => 'Semana';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get hour24 => '24 horas';

  @override
  String get hour12 => '12 horas';

  @override
  String get newEvent => 'Novo evento';

  @override
  String get editEvent => 'Editar evento';

  @override
  String get addEvent => 'Adicionar evento';

  @override
  String get eventTitle => 'Título';

  @override
  String get titleRequired => 'Informe um título';

  @override
  String get category => 'Categoria';

  @override
  String get noCategory => 'Nenhuma';

  @override
  String get date => 'Data';

  @override
  String get startTime => 'Horário de início';

  @override
  String get duration => 'Duração';

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get repeat => 'Repetir';

  @override
  String get repeatNever => 'Não se repete';

  @override
  String get repeatDaily => 'Diariamente';

  @override
  String get repeatWeekly => 'Semanalmente';

  @override
  String get repeatMonthly => 'Mensalmente';

  @override
  String get repeatYearly => 'Anualmente';

  @override
  String get repeatUntil => 'Repetir até';

  @override
  String get repeatForever => 'Para sempre';

  @override
  String get clear => 'Limpar';

  @override
  String get reminder => 'Lembrete';

  @override
  String get reminderNone => 'Nenhum';

  @override
  String get reminderAtTime => 'Na hora do evento';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min antes';
  }

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteEventTitle => 'Excluir evento?';

  @override
  String get deleteEventMessage => 'Isso removerá o evento.';

  @override
  String get noEventsForDay => 'Sem eventos';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglês';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeColor => 'Cor do tema';

  @override
  String get custom => 'Personalizada';

  @override
  String get themeMode => 'Modo do tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get categories => 'Categorias';

  @override
  String get manageCategories => 'Gerenciar categorias';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get categoryName => 'Nome';

  @override
  String get color => 'Cor';

  @override
  String get nameRequired => 'Informe um nome';

  @override
  String get deleteCategoryTitle => 'Excluir categoria?';

  @override
  String get deleteCategoryMessage =>
      'Os eventos desta categoria ficarão sem categoria.';

  @override
  String get noCategories => 'Nenhuma categoria ainda';

  @override
  String get pickColor => 'Escolha uma cor';

  @override
  String get select => 'Selecionar';
}
