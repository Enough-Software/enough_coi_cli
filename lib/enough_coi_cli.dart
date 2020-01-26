import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/coi_client.dart';
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
    _welcome();
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
    ..addCommand(AccountCommand())
    ..argParser.addFlag('verbose',
        abbr: 'v', help: 'Show additional diagnostic info', defaultsTo: false);
  return runner;
}

void _welcome() {
  var console = Global.console;
  console.reset();
  var welcome = r'''

    _____ ____ _____     __  __                                              _____ _      _____ 
   / ____/ __ \_   _|   |  \/  |                                            / ____| |    |_   _|
  | |   | |  | || |     | \  / | ___  ___ ___  ___ _ __   __ _  ___ _ __   | |    | |      | |  
  | |   | |  | || |     | |\/| |/ _ \/ __/ __|/ _ \ '_ \ / _` |/ _ \ '__|  | |    | |      | |  
  | |___| |__| || |_    | |  | |  __/\__ \__ \  __/ | | | (_| |  __/ |     | |____| |____ _| |_ 
   \_____\____/_____|   |_|  |_|\___||___/___/\___|_| |_|\__, |\___|_|      \_____|______|_____|
                                                          __/ |                                 
                                                         |___/                                  
''';
  console.printRaw(welcome);
  console.addLineMark();
}
