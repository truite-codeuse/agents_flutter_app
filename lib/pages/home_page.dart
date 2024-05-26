import 'dart:io';
import 'package:agents_flutter_app/logic/data_handling.dart';
import 'package:agents_flutter_app/logic/logic.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import "package:agents_flutter_app/logic/gorgias_api.dart";
import 'dart:async';
import 'package:flutter_sms/flutter_sms.dart';

/*
TEST PAGE USED TO SEE IF THE APP WORKS, ITS PURPOSE IS TO BE DELETED AND REPLACED BY SMTH ELSE
*/
class HomePage extends StatefulWidget {
  final ModuleManager manager;
  
  const HomePage({super.key, required this.manager});
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PhoneState status = PhoneState.nothing(); // Status of the phone (incoming call, no call, ...)
  bool granted = false;

  /// Requests phone and SMS permissions to the smartphone API
  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();
    var sms = await Permission.sms.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) setStream();
  }

  /// Sends SMS to a list of phone numbers
  /// String message : the content of the SMS
  /// List<String> recipents : the list of phone numbers
  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents, sendDirect: true)
          .catchError((onError) {
        print(onError);
      });
    print(_result);
  }

  /// Check if there is an incoming call and send SMS if GorgiasAPI return true
  void setStream() {
    PhoneState.stream.listen((event) {
      setState(() {
          status = event;
          if (status.status == PhoneStateStatus.CALL_INCOMING) {
            var facts = widget.manager.resolveAll();
            for (Fact f in facts) {
              print(f);
            }
            GorgiasAPI().queryGorgias(facts, "").then((value) {
              if (value == true) {
                print("Deny");
                String message = "Hi, I am Intellagent the bot that helps managing incomming calls. Your call has been rejected for some reasons. Please try again later. This message has been generated automatically.";
                List<String> recipents = [status.number!];
                _sendSMS(message, recipents);
              }
            });
          }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            if (Platform.isAndroid)
              // Ask for phone and SMS permissions
              MaterialButton(
                onPressed: !granted
                    ? () async {
                        bool temp = await requestPermission();
                        setState(() {
                          granted = temp;
                          if (granted) {
                            setStream();
                          }
                        });
                      }
                    : null,
                child: const Text("Request permission of Phone"),
              ),
            const Text(
              "Status of call",
              style: TextStyle(fontSize: 24),
            ),
            Icon(
              getIcons(),
              color: getColor(),
              size: 80,
            ),

            MaterialButton(onPressed: () => PrologHandler().saveRules(widget.manager), child:const Text('Prolog')),
        ],
      ),
    );
  }

  IconData getIcons() {
    switch (status.status) {
      case PhoneStateStatus.NOTHING:
        return Icons.clear;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  Color getColor() {
    switch (status.status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}
