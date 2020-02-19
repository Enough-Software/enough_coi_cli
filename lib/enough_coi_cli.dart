import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/coi_client.dart';
import 'package:enough_coi_cli/src/flow/main_flow.dart';
import 'package:enough_console/enough_console.dart';
import 'package:enough_coi_cli/src/command/all_commands.dart';

import 'global.dart';


void run(List<String> args) async {
  var runner = defineCommands();
  var argResults = runner.parse(args);
  var isVerbose = argResults['verbose'];
  Global.isVerbose = isVerbose;
  Global.client = await CoiClient.init('enough.de', isLogEnabled: isVerbose);
  if (argResults.command == null && argResults['help'] == false ) {
    Global.console  = Console(reset: true);
    await MainFlow().run();
  } else {
    Global.console  = Console(reset: false);
    await runner.runCommand(argResults).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
  }
}

CommandRunner defineCommands() {
  var runner = CommandRunner('coi', 'Chat via your commandline.')
    ..addCommand(SendCommand())
    ..addCommand(DiscoverCommand())
    ..addCommand(CheckCommand())
    ..addCommand(AccountCommand())
    ..argParser.addFlag('verbose',
        abbr: 'v', help: 'Show additional diagnostic info', defaultsTo: false);
  return runner;
}
