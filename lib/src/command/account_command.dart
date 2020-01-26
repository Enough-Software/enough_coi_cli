import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/global.dart';
import 'package:enough_coi_cli/src/flow/account_add_flow.dart';

class AccountCommand extends Command {
  @override
  String get description => 'Manages accounts.';

  @override
  String get name => 'account';

  AccountCommand() {
    argParser.addFlag('list', abbr: 'l', help: 'List configured accounts.');
    argParser.addFlag('add', abbr: 'a', help: 'Add a new account.');
    argParser.addOption('email',
        abbr: 'e',
        help: 'The email for the interaction.',
        valueHelp: 'email',
        defaultsTo: null);
  }

  @override
  void run() async {
    if (argResults['list']) {
      var accounts = await Global.client.loadAccounts();
      if (accounts == null || accounts.isEmpty) {
        Global.console.print('You do not have any accounts configured. Call "coi account --add" to create one.');
        return;
      }
      Global.console.print('Your accounts:');
      for (var account in accounts) {
        _printAccount(account);
      }
    } 
    if (argResults['add']) {
      Global.console.print('Adding account...');
      var email = argResults['email'];
      var flow = AddAccountFlow(email);
      var account = await flow.run();
      if (account != null) {
        await Global.client.addAccount(account);
        Global.console.success('Added account ${account.name} successfully.');
      }
    }
    exit(0);
  }

  void _printAccount(EmailAccount account) {
    Global.console.writeBold(' ${account.name}');
    Global.console.writeln(': ${account.email} on provider ${account.providerName}');
  }
}
