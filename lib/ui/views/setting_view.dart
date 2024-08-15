/*import 'package:flutter/material.dart';
import 'package:statstrack/constants.dart';
import 'package:statstrack/core/services/database_helper.dart';
import 'package:statstrack/core/viewmodels/setting_model.dart';
import 'package:statstrack/core/enums/viewstate.dart';
import 'package:statstrack/ui/views/base_view.dart';
import 'package:statstrack/core/services/storage.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:statstrack/ui/shared/display_dialog.dart';
import 'package:statstrack/core/util/utility.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';

import '../../core/models/sports.dart';

class SettingView extends StatelessWidget {

  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {

    Storage storage = Storage();
    String? emailForBackup = '';

    void onCancelPressed() {
      Navigator.of(context).pop();
    }

    void onContinuePressed() async {
      File dbFile = File(DatabaseHelper.dbPath);
      final dbData = dbFile.readAsBytesSync();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      var filePath = '$tempPath/statstrack.bak';
      File backupFile = File(filePath);
      log('Temporary data backup file: $filePath');
      if (backupFile.existsSync()) {
        backupFile.deleteSync();
        log('Previous bak file deleted.');
      }
      backupFile.writeAsBytesSync(dbData);

      Utility.sendEMail(emailForBackup, 'Stats Track data email backup',
          'The backup file is attached.', filePath);

      if (context.mounted) {
        Navigator.of(context).pop();
      }
      // displayDialog(context, "Email has been sent with backup file.",
      //   "Back to settings.");
    }

    Future<void> onDeleteButtonPressed() async {
      DatabaseHelper dbClient = DatabaseHelper();
      await dbClient.resetDatabase();
      if (context.mounted) {
        Navigator.of(context).pop();
        displayDialog(context, "Data reset", "Back to settings.");
      }
    }

    Future<void> onContinueDataRestorePressed(result) async {
      File source = File(result.files.single.path!);
      await source.copy(DatabaseHelper.dbPath).whenComplete(() {
        Navigator.of(context).pop();
        displayDialog(context, "Data restored", "Back to settings.");
      }).onError((error, stackTrace) {
        Navigator.of(context).pop();
        displayDialog(context, "Error in restoring data", error.toString());
        return File(DatabaseHelper.dbPath);
      });
    }

    Future<void> onContinueButtonPressed() async {
      await storage.deleteAll();
      if (context.mounted) {
        Navigator.of(context).pop();
        displayDialog(context, "Cache cleared", "Back to settings.");
      }
    }

    Future<String?> showEnterEmailDialog(BuildContext context, model) async {
      AlertDialog enterEmailDialog = AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          final formKey = GlobalKey<FormState>();
          TextEditingController emailController = TextEditingController();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 30, right: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email Address:",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              TextFormField(
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLength: 30,
                                autofocus: false,
                                controller: emailController..text = email??'',
                                //controller: teamNameController,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "Please enter email address"
                                        : null,
                                onSaved: (value) async {
                                  if (value!.isNotEmpty) {
                                    await storage.saveEmailForBackup(value);
                                  }
                                  setState(() {
                                    email = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        final form = formKey.currentState;
                        if (form != null && form.validate()) {
                          form.save();
                          Navigator.pop(context, email);
                        }
                      },
                      child: const Text('Save'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      //color: Colors.red,
                      onPressed: () {
                        Navigator.pop(context,'');
                      },
                      child: const Text('Cancel'),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      );
      if(context.mounted) {
        email = await showDialog(
            context: context,
            builder: (BuildContext context) => enterEmailDialog);
      }
      return email;
    }

    return BaseView<SettingModel>(
        onModelReady: (model) => model.getDefaultValues(),
        builder: (context, model, child) => model.state == ViewState.Busy
            ? const Center(child: CircularProgressIndicator())
            : SettingsList(sections: [
                SettingsSection(
                  title: const Text('Current Sport'),
                  tiles: [
                    SettingsTile(
                      title: (model.defaultSports == null
                          ? const Text('N/A')
                          : Text(model.defaultSports!.name)),
                      leading: Icon(Sports.getSportIcon(model.defaultSports!.image),
                          color:Colors.green),
                      trailing: const Icon(Icons.edit, color:Colors.green),
                      //leading: Icon(Icons.score),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "sportslist");
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Edit'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Sports'),
                      leading: const Icon(Icons.sports_soccer, color:Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "sportslist");
                      },
                    ),
                    SettingsTile(
                      title: const Text('Teams'),
                      leading: const Icon(Icons.people, color: Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "teamlist");
                      },
                    ),
                    SettingsTile(
                      title: const Text('Players'),
                      leading: const Icon(Icons.emoji_people, color: Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "teamSelect",
                            arguments: {'route': ROUTE_PLAYER});
                      },
                    ),
                    SettingsTile(
                      title: const Text('Game Types'),
                      leading: const Icon(Icons.sports_martial_arts, color: Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "gameTypelist");
                      },
                    ),
                    SettingsTile(
                      title: const Text('Games'),
                      leading: const Icon(Icons.games, color: Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "teamSelect",
                            arguments: {'route': ROUTE_GAME});
                      },
                    ),
                    SettingsTile(
                      title: const Text('Stats'),
                      leading: const Icon(Icons.analytics, color: Colors.green),
                      onPressed: (BuildContext context) {
                        Navigator.pushNamed(context, "statsItemList");
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Backup & Restore'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Backup to email'),
                      leading: const Icon(Icons.email, color: Colors.green),
                      onPressed: (BuildContext context) async {
                        emailForBackup = await storage.getEmailForBackup();
                        if (emailForBackup == null || emailForBackup!.isEmpty) {
                          if (context.mounted) {
                            await showEnterEmailDialog(context, model);
                          }
                          emailForBackup = await storage.getEmailForBackup();
                        }
                        if(context.mounted && emailForBackup != null
                            && emailForBackup!.isNotEmpty) {
                          showConfirmationDialog(
                              context,
                              "Email Backup",
                              "The Mail app will be launched with a backup of your app data file attached to a new message. "
                                  "You will be able to change the email address that you would like to send the backup to. ",
                              onCancelPressed,
                              onContinuePressed);
                        }
                      },
                    ),
                    SettingsTile(
                      title: const Text('Restore from backup file'),
                      leading: const Icon(Icons.approval, color: Colors.green),
                      onPressed: (BuildContext context) async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null && context.mounted) {
                          showConfirmationDialog(
                              context,
                              "Restore data backup",
                              "All the data including the Stats, Teams, Players and Games information you have entered "
                                  "and stored in this app will be replaced "
                                  "with the data in this backup file. This cannot be undone. Do you want to continue?",
                              onCancelPressed,
                              onContinueDataRestorePressed,
                              paraContinue: result);
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
                leading: const Icon(Icons.stop_screen_share, color: Colors.green),
                onToggle: (bool value) {
                  storage.saveSkipIntroduction(value);
                  model.onSkipIntroductionClicked(value);
                },
                initialValue: model.skipIntroduction,
                activeSwitchColor: Colors.green,
              ),
              SettingsTile(
                title: const Text('Set up email for backup'),
                leading: const Icon(Icons.email, color: Colors.green),
                onPressed: (BuildContext context) async{
                  emailForBackup = await showEnterEmailDialog(context, model);
                  if(context.mounted && emailForBackup!.isNotEmpty) {
                    storage.saveEmailForBackup(emailForBackup!);
                  }
                },
              ),
            ],
          ),
                SettingsSection(
                  title: const Text('App Data Reset'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Reset all the settings to default'),
                      leading: const Icon(Icons.reset_tv, color: Colors.green),
                      onPressed: (BuildContext context) {
                        showConfirmationDialog(
                            context,
                            "Data Reset",
                            "All the data you have entered or collected in this app will be deleted, and the app will be restored to initial setup. Are you sure you want to reset the data to its initial setup?",
                            onCancelPressed,
                            onDeleteButtonPressed);
                      },
                    ),
                    SettingsTile(
                      title: const Text('Clear all the cache'),
                      leading: const Icon(Icons.clear_all, color: Colors.green),
                      onPressed: (BuildContext context) {
                        showConfirmationDialog(
                            context,
                            "Clear Cache",
                            "All the cache that stores your previous selections in this app will be deleted, "
                                "but all the Stats, Teams, Players and Games information you have entered will NOT be changed. "
                                "Do you want to continue?",
                            onCancelPressed,
                            onContinueButtonPressed);
                      },
                    ),
                  ],
                ),
              ])

        // ],
        // )
        );
  }
}*/
