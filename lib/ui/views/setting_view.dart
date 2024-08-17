import 'package:cookingapp/services/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  bool isOnboardingComplete = false;

  void onCancelPressed() {
    Navigator.of(context).pop();
  }

  void onContinuePressed() async {
    File dbFile = File(DbHelper.dbPath);
    final dbData = dbFile.readAsBytesSync();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/whatscooking.bak';
    File backupFile = File(filePath);
    log('Temporary data backup file: $filePath');
    if (backupFile.existsSync()) {
      backupFile.deleteSync();
      log('Previous bak file deleted.');
    }
    backupFile.writeAsBytesSync(dbData);

    final Email email = Email(
      body: 'Please find the attached database backup.',
      subject: "Database Backup - What's Cooking?",
      recipients: [''],
      attachmentPaths: [filePath],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      log('Error sending email: $error');
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
    // displayDialog(context, "Email has been sent with backup file.",
    //   "Back to settings.");
  }

  /*Future<void> onDeleteButtonPressed() async {
      DbHelper dbClient = DbHelper();
      await dbClient.resetDatabase();
      if (context.mounted) {
        Navigator.of(context).pop();
        displayDialog(context, "Data reset", "Back to settings.");
      }
    }*/

  Future<void> onContinueDataRestorePressed(result) async {
    File source = File(result.files.single.path!);
    await source.copy(DbHelper.dbPath).whenComplete(() {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(content: Text("Data restored"));
          });
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text("Error in restoring data - ${error.toString()}"));
          });
      return File(DbHelper.dbPath);
    });
  }

  /*Future<void> onContinueButtonPressed() async {
      await storage.deleteAll();
      if (context.mounted) {
        Navigator.of(context).pop();
        displayDialog(context, "Cache cleared", "Back to settings.");
      }
    }*/

  Future<void> getData() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedBoolValue = prefs.getBool('isOnboardingComplete');
    isOnboardingComplete = savedBoolValue ?? false;
  }

  Widget settingsWidget() {
    return FutureBuilder(
        future: getData(),
        builder: (context, onBoardSnap) {
          return SettingsList(sections: [
            SettingsSection(
              title: const Text('Backup & Restore'),
              tiles: [
                SettingsTile(
                  title: const Text('Backup to email'),
                  leading: const Icon(Icons.email, color: Colors.green),
                  onPressed: (BuildContext context) async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            scrollable: true,
                            title: Text('Backup to Email'),
                            content: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Form(
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                            height: 100,
                                            child: Text(
                                              "The Mail app will be launched with a backup of your app data file attached to a new message. "
                                              "You will have the option to choose which email you want to send your data to.",
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                  ElevatedButton(
                                      child: Text("Backup"),
                                      onPressed: () {
                                        setState(() {
                                          onContinuePressed();
                                        });
                                      }),
                                ],
                              )
                            ],
                          );
                        });
                  },
                ),
                SettingsTile(
                  title: const Text('Restore from backup file'),
                  leading: const Icon(Icons.approval, color: Colors.green),
                  onPressed: (BuildContext context) async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null && context.mounted) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text('Restore Data'),
                              content: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Form(
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                              height: 100,
                                              child: Text(
                                                "All data (like recipe information) you have entered"
                                                "and stored in this app will be replaced "
                                                "with the data in this backup file. This cannot be undone. Do you want to continue?",
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                        child: Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                    ElevatedButton(
                                        child: Text("Restore"),
                                        onPressed: () {
                                          setState(() {
                                            onContinueDataRestorePressed(
                                                result);
                                          });
                                        }),
                                  ],
                                )
                              ],
                            );
                          });
                    } else {
                      // User canceled the picker
                    }
                  },
                ),
              ],
            ),
            SettingsSection(
              title: const Text('General'),
              tiles: [
                SettingsTile.switchTile(
                  title: const Text('Skip introduction at launch'),
                  leading:
                      const Icon(Icons.stop_screen_share, color: Colors.green),
                  onToggle: (bool value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isOnboardingComplete', value);
                    setState(() {});
                  },
                  initialValue: isOnboardingComplete == false ? false : true,
                  activeSwitchColor: Colors.green,
                )
              ],
            ),
            SettingsSection(
              title: const Text('App Data Reset'),
              tiles: [
                SettingsTile(
                  title: const Text('Reset all the settings to default'),
                  leading: const Icon(Icons.reset_tv, color: Colors.green),
                  onPressed: (BuildContext context) {
                    /*showConfirmationDialog(
                                context,
                                "Data Reset",
                                "All the data you have entered or collected in this app will be deleted, and the app will be restored to initial setup. Are you sure you want to reset the data to its initial setup?",
                                onCancelPressed,
                                onDeleteButtonPressed);*/
                  },
                ),
                SettingsTile(
                  title: const Text('Clear all the cache'),
                  leading: const Icon(Icons.clear_all, color: Colors.green),
                  onPressed: (BuildContext context) {
                    /*showConfirmationDialog(
                                context,
                                "Clear Cache",
                                "All the cache that stores your previous selections in this app will be deleted, "
                                    "but all the Stats, Teams, Players and Games information you have entered will NOT be changed. "
                                    "Do you want to continue?",
                                onCancelPressed,
                                onContinueButtonPressed);*/
                  },
                ),
              ],
            ),
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Settings"),
          leading: IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, "home");
            },
          )),
      body: settingsWidget(),
    );

    // ],
    // )
  }
}
