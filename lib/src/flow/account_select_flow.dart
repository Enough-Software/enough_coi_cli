import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/src/command/account_commands.dart';
import 'package:enough_coi_cli/src/flow.dart';

import '../../global.dart';

class SelectAccountFlow extends Flow<EmailAccount> {
  List<EmailAccount> accounts;
  bool allowCommands;
  CommandRunner runner;

  SelectAccountFlow(this.accounts, {this.allowCommands = true}) {
    if (allowCommands) {
      runner = CommandRunner('', '')..addCommand(AddAccountCommand());
    }
  }

  @override
  Future<EmailAccount> run() {
    _listAccounts();
    return _chooseAccount();
  }

  void _listAccounts() {
    Global.console.addLineMark();
    Global.console.print('Your accounts:');
    Global.console.list(accounts.map((a) => a.name));
  }

  Future<EmailAccount> _chooseAccount() async {
    var result = await Global.console.readInput('Select account: ');
    var account = Global.console.parseListChoice(result, accounts);
    if (account == null) {
      return _chooseAccount();
    } else {
      return account;
    }
  }

  Future<EmailAccount> _chooseAccountWithOptions() async {
    var message = 'Select account: ';
    if (allowCommands) {
      message = 'Select account [or help]: ';
    }
    var result = await Global.console.readInput(message);
    if (allowCommands) {
      await runner.run(result.split(' '));
    }
    if (result == 'h' || result == 'help') {
      Global.console.addLineMark();
      Global.console.print('');
      Global.console.print('h or help:            shows this help');
      Global.console.print('q or quit:            quit CLI');
      Global.console.print('+ or add:             add an account');
      Global.console
          .print('- or delete [number]: remove the specified account');
      result = await Global.console.readInput('[return to continue]');
      Global.console.returnToLineMark();
      return _chooseAccount();
    } else if (result == 'q' || result == 'quit') {
      exit(0);
    } else if (result == '+' || result == 'add') {
      //accounts = await addAccount(accounts);
      return _chooseAccount();
    } else if (result.startsWith('- ') || result.startsWith('delete ')) {
      if (result.startsWith('- ')) {
        result = result.substring('- '.length);
      } else {
        result = result.substring('delete '.length);
      }
      var account = Global.console.parseListChoice(result, accounts);
      if (account == null) {
        return _chooseAccount();
      } else {
        //var remainingAccounts = await removeAccount(account, accounts);
        Global.console.returnToLineMark();
        // if (remainingAccounts.isEmpty) {
        //   await addAccount(accounts);
        // } else {
        //   await chooseAccount(accounts);
        // }
        return null;
      }
    } else {
      var account = Global.console.parseListChoice(result, accounts);
      if (account == null) {
        return _chooseAccount();
      } else {
        return account;
      }
    }
  }
}
