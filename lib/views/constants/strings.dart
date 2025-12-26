import 'package:flutter/foundation.dart';

@immutable
class Strings {
  // General app information
  static const appName = 'Instagram';
  static const welcomeToAppName = 'Welcome to ${Strings.appName}';

  // Messages related to posts
  static const youHaveNoPosts =
      'You have not made a post yet. Press either the video-upload or the photo-upload buttons at the top of the screen to upload your first post!';
  static const noPostsAvailable =
      "Nobody seems to have made any posts yet. Why don't you take the first step and upload your first post?!";

  // Search-related messages
  static const enterYourSearchTerm =
      'Enter your search term to get started. You can search in the description of all posts available in the system';

  // Third-party integration
  static const google = 'Google';
  static const googleSignupUrl = 'https://accounts.google.com/signup';

  // Login and account-related messages
  static const logIntoYourAccount = 'Log into your account.';
  static const dontHaveAnAccount = "Don't have an account?\n";
  static const signUp = 'Sign up';
  static const orCreateAnAccountOn = ' or create an account on ';

  // Post interaction strings
  static const comments = 'Comments';
  static const writeYourCommentHere = 'Write your comment here...';
  static const checkOutThisPost = 'Check out this post!';
  static const postDetails = 'Post Details';
  static const post = 'post';
  static const createNewPost = 'Create New Post';
  static const pleaseWriteYourMessageHere = 'Please write your message here';

  // Comments-related message
  static const noCommentsYet =
      'Nobody has commented on this post yet. You can change that though, and be the first person who comments!';

  // Search input hint
  static const enterYourSearchTermHere = 'Enter your search term here';

  // Private constructor to prevent instantiation
  const Strings._();
}