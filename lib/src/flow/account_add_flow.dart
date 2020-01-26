import 'package:enough_coi/email_account.dart';
import 'package:enough_coi/enough_coi.dart';
import 'package:enough_coi_cli/global.dart';
import 'package:enough_coi_cli/src/flow.dart';

class AddAccountFlow extends Flow<EmailAccount> {
  String _emailAddress;

  AddAccountFlow([this._emailAddress]);

  @override
  Future<EmailAccount> run() async {
    var console = Global.console;
    _emailAddress ??= await console.readInput('Your email: ');
    console.write('Discovering settings for ');
    console.writeBold(_emailAddress + ' ');
    console.startProgress();
    var config = await Global.client.discover(_emailAddress);
    console.stopProgress();
    console.writeln();
    if (config == null) {
      console.error('Unable to discover settings for [$_emailAddress].');
      //TODO re-check password or allow manual settings
      return null;
    }
    var password = await console.readInput('Your password: ', isSecret: true);
    if (password == null || password.isEmpty) {
      return null;
    }
    console.writeln();
    console.write('Signing you in...');
    console.startProgress();
    var account =
        await Global.client.tryLogin(_emailAddress, config, password: password);
    console.stopProgress();
    console.writeln();
    if (account == null) {
      console.error('Unable to login [$_emailAddress].');
      return null;
      //TODO re-check password or allow manual settings
    }
    var domain = MailHelper.getDomainFromEmail(_emailAddress);
    var name = await console.readInput('Account name ($domain): ');
    if (name == null) {
      return null;
    }
    if (name.isEmpty) {
      name = domain;
    }
    account.name = name;
    return account;
  }
}
