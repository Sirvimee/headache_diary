import 'package:flutter/foundation.dart';

@immutable
class Strings {
  // General app information
  static const appName = 'Peavalupäevik';
  static const welcomeToAppName = 'Welcome to ${Strings.appName}';
  static const channelId = 'systal_channel';
  static const channelName = 'Süstimise meeldetuletused';

  // Third-party integration
  static const google = 'Google';
  static const googleSignupUrl = 'https://accounts.google.com/signup';
  static const signInWithGoogle = 'Logi sisse Googlega';

  // Login and account-related messages
  static const logIn = 'Sisselogimine';
  static const username = 'Nimi';
  static const enterYourName = 'Palun sisesta oma nimi';
  static const changeUsername = 'Muuda nime';
  static const newUsername = 'Uus nimi';
  static const emailAddress = 'E-posti aadress';
  static const enterYourEmailAddress = 'Palun sisesta oma e-posti aadress';
  static const repeatEmailAddress = 'Korda e-posti aadressi';
  static const enterCorrectEmailAddress = 'Palun sisesta korrektne e-posti aadress';
  static const changeEmailAddress = 'Muuda e-posti aadressi';
  static const newEmailAddress = 'Uus e-posti aadress';
  static const wrongEmailAddress = 'E-posti aadress on vale';
  static const emailAddressesDoNotMatch = 'E-posti aadressid ei ühti';
  static const password = 'Parool';
  static const enterYourPassword = 'Palun sisesta oma parool';
  static const repeatPassword = 'Korda parooli';
  static const passwordsDoNotMatch = 'Paroolid ei ühti';
  static const shortPassword = 'Parool peab olema vähemalt 5 tähemärki pikk';
  static const changePassword = 'Muuda parooli';
  static const passwordMustContainUppercase = 'Parool peab sisaldama vähemalt ühte suurtähte';
  static const logIntoYourAccount = 'Logi sisse';
  static const signUp = 'Registreeru';
  static const forgotPassword = 'Unustasid parooli?';
  static const userEmailAlreadyInUse = 'Kasutaja e-posti aadress on juba kasutusel';
  static const invalidEmailOrPassword = 'Vale e-posti aadress või parool';
  static const userRegistrationFailed = 'Registreerimine ebaõnnestus';
  static const loginFailed = 'Sisselogimine ebaõnnestus: ';
  static const formNotAvailable = 'Vorm pole saadaval';
  static const resetPasswordInstruction = 'Sisesta oma e-posti aadress ja me saadame uue parooli e-postile';
  static const send = 'Saada';
  static const change = 'Muuda';
  static const resetEmailSent = 'Saatsime juhised parooli taastamiseks e-postile';
  static const userNotFound = 'Kasutajat ei leitud';
  static const userDataIsChanged = 'Kasutaja andmed on muudetud';

  // Interaction strings
  static const or = 'või';
  static const back = 'Tagasi';
  static const errorMessage = 'Tekkis viga';
  static const toFrontPage = 'Esilehele';

  // Dialogs
  static const logOut = 'Logi välja';
  static const areYouSureYouWantToLogOut = 'Kas oled kindel, et soovid välja logida?';
  static const cancel = 'Tühista';
  static const save = 'Salvesta';

  // Navigation
  static const home = 'Avalehele';
  static const notes = 'Lisa märkmeid';
  static const statistics = 'Kokkuvõte';
  static const profile = 'Profiil';

  // Calendar
  static const january = 'jaanuar';
  static const february = 'veebruar';
  static const march = 'märts';
  static const april = 'aprill';
  static const may = 'mai';
  static const june = 'juuni';
  static const july = 'juuli';
  static const august = 'august';
  static const september = 'september';
  static const october = 'oktoober';
  static const november = 'november';
  static const december = 'detsember';

  static const mo = 'E';
  static const tu = 'T';
  static const we = 'K';
  static const thu = 'N';
  static const fri = 'R';
  static const sat = 'L';
  static const sun = 'P';

  static const monday = 'Esmaspäev';
  static const tuesday = 'Teisipäev';
  static const wednesday = 'Kolmapäev';
  static const thursday = 'Neljapäev';
  static const friday = 'Reede';
  static const saturday = 'Laupäev';
  static const sunday = 'Pühapäev';

  static const today = 'Täna';

  // Notes
  static const headacheLeftSide = 'Vasakpoolne peavalu';
  static const headacheRightSide = 'Parempoolne peavalu';
  static const headacheFull = 'Üle pea peavalu';
  static const addPill = 'Lisa tablett';
  static const subtractPill = 'Eemalda tablett';
  static const injection = 'Süst';
  static const cardioExercise = 'Kardiotrenn';
  static const gymWorkout = 'Jõutrenn';
  static const intercourse = 'Vahekord';
  static const menstruation = 'Menstruatsioon';
  static const alcoholConsumption = 'Alkohol';
  static const additionalNotes = 'Märkmed';
  static const enterAdditionalNotes = 'Kirjuta siia...';

  static const canAddOnlyToValidDates = 'Märkmeid saab lisada ainult tänasele või varasematele kuupäevadele';

  // Statistics
  static const headacheDays = 'Peavalu päevi:';
  static const rightSideHeadaches = 'Neist parempoolseid:';
  static const leftSideHeadaches = 'Neist vasakpoolseid:';
  static const overheadHeadaches = 'Neist üle pea:';
  static const pillsTaken = 'Tablette võetud, tk:';
  static const injectionsMade = 'Süste tehtud, tk:';
  static const cardioDays = 'Kardiotrenne, päevi:';
  static const strengthDays = 'Jõutrenne, päevi:';
  static const intercourseDays = 'Vahekordi, päevi:';
  static const alcoholDays = 'Alkoholi tarvitatud, päevi:';
  static const menstruationDays = 'Menstruatsioon, päevi:';
  static const pickCorrectDateRange = 'Palun vali korrektne ajavahemik';
  static const pickPeriod = 'Vali periood';
  static const byMonth = 'Kuude kaupa';
  static const byPeriod = 'Perioodi kaupa';
  static const from = 'Alates';
  static const to = 'Kuni';
  static const pickDate = 'Vali kuupäev';
  static const confirm = 'Kinnita';
  static const dataNotFound = 'Andmeid ei leitud';

  // Notification texts
  static const String notificationTitle = 'Meeldetuletus';
  static const String notificationBody = 'Aeg teha süsti';

  // SnackBar sentences
  static const String permissionDeniedSnackBar = 'Teavituste õigus on keelatud. Palun luba seadetest';
  static const String reminderAddedSnackBar = 'Meeldetuletus lisatud';
  static const String reminderRemovedSnackBar = 'Meeldetuletus eemaldatud';
  static const String failedToScheduleReminderSnackBar = 'Meeldetuletuse lisamine ebaõnnestus, kuna märguannete luba puudub. Palun lubage märguanded seadetes';
  static const String reminderDeletedSnackBar = 'Süstal eemaldatud, meeldetuletus tühistatud';

  // Commons
  static const error = 'Viga';

  // Private constructor to prevent instantiation
  const Strings._();
}