import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/global.dart';
import 'package:enough_coi_cli/src/flow/account_add_flow.dart';
import 'package:enough_coi_cli/src/flow/account_remove_flow.dart';

class AccountCommand extends Command {
  @override
  String get description => 'Manages accounts.';

  @override
  String get name => 'account';

  AccountCommand() {
    addSubcommand(AddAccountCommand());
    addSubcommand(RemoveAccountCommand());
    addSubcommand(ListAccountsCommand());
  }
}

class AddAccountCommand extends Command {
  @override
  String get description => 'Add a new account.';

  @override
  String get name => 'add';

  //Function<String> _addFunction;

  AddAccountCommand() {
    argParser.addOption('email',
        abbr: 'e',
        help: 'The email address of the new account',
        valueHelp: 'email-address');
    argParser.addFlag('force-ssl',
        abbr: 's',
        help:
            'Forces using SSL connections, even when auto-discovery detects STARTTLS or PLAIN servers.',
        defaultsTo: false,
        negatable: false);
  }

  @override
  void run() async {
    var account =
        await AddAccountFlow(argResults['email'], argResults['force-ssl'])
            .run();
    if (account != null) {
      await Global.client.addAccount(account);
      Global.console.success('Added account ${account.name} successfully.');
      Global.console.writeln();
    }
    exit(0);
  }
}

class ListAccountsCommand extends Command {
  @override
  String get description => 'List all accounts.';

  @override
  String get name => 'list';

  //Function<String> _addFunction;

  ListAccountsCommand() {
    argParser.addOption('name',
        abbr: 'n', help: 'The name of the account', valueHelp: 'account');
  }

  @override
  void run() async {
    var accounts = await Global.client.loadAccounts();
    if (accounts == null || accounts.isEmpty) {
      Global.console.print(
          'You do not have any accounts configured. Call "coi account add" to create one.');
      exit(0);
    }
    var name = argResults['name'];
    if (name is String && name != null && name.isNotEmpty) {
      name = name.toLowerCase();
      var matches = accounts.where((a) =>
          (a.name.toLowerCase().contains(name) ||
              a.email.toLowerCase().contains(name)));
      if (matches.isEmpty) {
        Global.console.print('No account  matches $name:');
      } else {
        Global.console.print('Your accounts matching $name:');
        for (var account in matches) {
          _printAccount(account);
        }
      }
    } else {
      Global.console.print('Your accounts:');
      for (var account in accounts) {
        _printAccount(account);
      }
    }
    exit(0);
  }

  void _printAccount(EmailAccount account) {
    Global.console.writeBold(' ${account.name}');
    Global.console
        .writeln(': ${account.email} on provider ${account.providerName}');
  }
}

class RemoveAccountCommand extends Command {
  @override
  String get description => 'Removes an account.';

  @override
  String get name => 'remove';

  //Function<String> _addFunction;

  RemoveAccountCommand() {
    argParser.addOption('name',
        abbr: 'n', help: 'The name of the account', valueHelp: 'account');
  }

  @override
  void run() async {
    var accounts = await Global.client.loadAccounts();
    if (accounts == null || accounts.isEmpty) {
      Global.console.print(
          'You do not have any accounts configured. Call "coi account add" to create one.');
      exit(0);
    }
    var name = argResults['name'];
    if (name is String && name != null && name.isNotEmpty) {
      name = name.toLowerCase();
      var matches = accounts.where((a) =>
          (a.name.toLowerCase().contains(name) ||
              a.email.toLowerCase().contains(name)));
      if (matches.isEmpty) {
        Global.console.print('No account matches $name:');
      } else {
        await RemoveAccountFlow(matches.toList()).run();
      }
    } else {
      await RemoveAccountFlow(accounts).run();
    }
    exit(0);
  }
}
