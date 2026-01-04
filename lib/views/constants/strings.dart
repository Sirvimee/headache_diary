import 'package:flutter/foundation.dart';

@immutable
class Strings {
  // General app information
  static const appName = 'Peavalupäevik';
  static const welcomeToAppName = 'Welcome to ${Strings.appName}';

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


  // Private constructor to prevent instantiation
  const Strings._();
}