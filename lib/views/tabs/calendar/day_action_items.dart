import '../../constants/strings.dart';

class ActionItem {
  final String key;
  final String asset;
  final String label;
  final bool flip;
  const ActionItem(this.key, this.asset, this.label, {this.flip = false});
}

const List<ActionItem> actionItems = [
  ActionItem(
    'peavalu_left',
    'assets/icons/peavalu-pool.svg',
    Strings.headacheLeftSide,
  ),
  ActionItem(
    'peavalu_full',
    'assets/icons/peavalu-terve.svg',
    Strings.headacheFull,
  ),
  ActionItem(
    'peavalu_right',
    'assets/icons/peavalu-pool.svg',
    Strings.headacheRightSide,
    flip: true,
  ),
  ActionItem('pill_plus', 'assets/icons/tablett-pluss.svg', Strings.addPill),
  ActionItem(
    'pill_minus',
    'assets/icons/tablett-miinus.svg',
    Strings.subtractPill,
  ),
  ActionItem('systal', 'assets/icons/systal.svg', Strings.injection),
  ActionItem('run', 'assets/icons/jooksmine.svg', Strings.cardioExercise),
  ActionItem('gym', 'assets/icons/gym.svg', Strings.gymWorkout),
  ActionItem('sex', 'assets/icons/heart.svg', Strings.intercourse),
  ActionItem('blood', 'assets/icons/blood.svg', Strings.menstruation),
  ActionItem('wine', 'assets/icons/wine.svg', Strings.alcoholConsumption),
  ActionItem('chocolate', 'assets/icons/chocolate.svg', Strings.chocolate),
  ActionItem('doctor', 'assets/icons/doctor.svg', Strings.doctor),
  ActionItem('eye_pain', 'assets/icons/eye-pain.svg', Strings.eyePain),
  ActionItem('vomit', 'assets/icons/vomit.svg', Strings.vomit),
  ActionItem(
    'preventive_pill',
    'assets/icons/pill.svg',
    Strings.preventivePill,
  ),
  ActionItem('notes', 'assets/icons/notes.svg', Strings.additionalNotes),
];
