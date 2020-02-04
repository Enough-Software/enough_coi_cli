import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/global.dart';
import 'package:enough_coi_cli/src/flow.dart';
import 'package:enough_coi_cli/src/flow/account_select_flow.dart';

class RemoveAccountFlow extends Flow<EmailAccount> {
  final List<EmailAccount> _accounts;

  RemoveAccountFlow(this._accounts);

  @override
  Future<EmailAccount> run() async {
    EmailAccount selectedAccount;
    if (_accounts.length > 1) {
      Global.console
          .writeln('Please select your account that you want to remove:');
      selectedAccount =
          await SelectAccountFlow(_accounts, allowCommands: false).run();
    } else {
      selectedAccount = _accounts.first;
    }
    var confirmation = await Global.console
        .readInput('Really remove account ${selectedAccount.name} [y/N]? ');
    if (confirmation == null) {
      return null;
    }
    if (!confirmation.toLowerCase().startsWith('y')) {
      Global.console.writeln('No account removed.');
      return null;
    }
    var success = await Global.client.removeAccount(selectedAccount);
    if (success) {
      Global.console.success('Removed account ${selectedAccount.name}.');
    } else {
      Global.console.error('Unable to remove account ${selectedAccount.name}.');
    }
    Global.console.writeln();
    return selectedAccount;
  }
}
