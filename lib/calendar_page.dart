import 'dart:async';
import 'dart:convert' show json;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart' as auth;
import 'package:url_launcher/url_launcher.dart';

const _scopes = [CalendarApi.calendarEventsReadonlyScope];

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/calendar.events.readonly',
  'https://www.googleapis.com/auth/calendar.calendarlist.readonly'
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  //clientId:'53503886363-pvqf9vofn4lr5a9ujp9c5bhemcrks35f.apps.googleusercontent.com',
  scopes: scopes,
);

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?

  final _credentials =  ClientId(
          "53503886363-pvqf9vofn4lr5a9ujp9c5bhemcrks35f.apps.googleusercontent.com",
          ""
  );

  void requestLastEvent() {
    try {
      clientViaUserConsent(_credentials, _scopes, prompt).then((AuthClient client){
        var calendar = CalendarApi(client);
        String calendarId = "primary";
        final now = DateTime.now().toUtc();
        calendar.events.list(calendarId, timeMin: now, singleEvents: true, orderBy: 'startTime').then((value) => {
          print("$value")
        });
      });
    }
    catch (e) {
      print('Error while fetching $e');
    }
  }

  Future<void> requestLastEvent2() async{
    final authClient = await _googleSignIn.authenticatedClient();
    final calendarApi = CalendarApi(authClient!);

    String calId = 'cc6oo5u9s4rhmmsahtuca9kl9f6fc5pg@import.calendar.google.com';
    Events events = await calendarApi.events.list(calId, timeMin: DateTime.now().toUtc(), singleEvents: true, maxResults: 10, orderBy: 'startTime');

    print(events.items![0].summary);
    print(events.items![0].start!.dateTime!.toLocal());
  }

  /* 
  clientViaUserConsent(_credentials, _scopes, prompt).then((AuthClient client){
        var calendar = CalendarApi(client);
        String calendarId = "primary";
        final now = DateTime.now().toUtc();
        calendar.events.list(calendarId, timeMin: now, singleEvents: true, orderBy: 'startTime').then((value) => {
          print("$value")
        });
      });
  */

  void prompt(String url) async {

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
// #docregion CanAccessScopes
      // In mobile, being authenticated means being authorized...
      bool isAuthorized = account != null;
      // However, on web...
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }
// #enddocregion CanAccessScopes

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      // Now that we know that the user can access the required scopes, the app
      // can call the REST API.
      if (isAuthorized) {
        print('initState');
        //unawaited(_handleGetEvent(account!));
      }
    });
    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    _googleSignIn.signInSilently();
  }

  Object getHttpClient() async {
    var httpClient = (await _googleSignIn.authenticatedClient())!;
    return httpClient;
  }


  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      print('############################################');
      if (e.code == GoogleSignIn.kNetworkError) {
          print("A network error (such as timeout, interrupted connection or unreachable host) has occurred.");
      } else {
          print(e.code);
          print(e.message);
      }
      print('############################################');
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    // #enddocregion RequestScopes
    setState(() {
      _isAuthorized = isAuthorized;
    });
    // #docregion RequestScopes
    if (isAuthorized) {
      print('_handleAuthorizeScopes');
     // unawaited(_handleGetContact(_currentUser!));
    }
    // #enddocregion RequestScopes
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount? user = _currentUser;
    if(user != null) {
        return Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: GoogleUserCircleAvatar(
                identity: user,
              ),
              title: Text(user.displayName ?? ''),
              subtitle: Text(user.email),
            ),
            const Text('Signed in successfully.'),
            if (_isAuthorized) ...<Widget>[
              // The user has Authorized all required scopes
              const Text('Everything is authorized !'),
            ],
            if (!_isAuthorized) ...<Widget>[
              // The user has NOT Authorized all required scopes.
              // (Mobile users may never see this button!)
              const Text('Additional permissions needed to read your contacts.'),
              ElevatedButton(
                onPressed: _handleAuthorizeScopes,
                child: const Text('REQUEST PERMISSIONS'),
              ),
            ],
            ElevatedButton(
              onPressed: _handleSignOut,
              child: const Text('SIGN OUT'),
            ),
            ElevatedButton(
              onPressed: requestLastEvent2,
              child: const Text('Get Last event'),
            ),
          ],
        ),
      );
    }
    else {
      return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            const Text('You are not signed in !'),
            MaterialButton(
              onPressed: _handleSignIn,
              child: const Text('Connect'),
            ),
          ],
        ),
      );
    }
  }
}
