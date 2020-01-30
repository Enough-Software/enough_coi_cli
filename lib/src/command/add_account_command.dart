import 'package:args/command_runner.dart';
import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/src/flow/account_add_flow.dart';

class AddAccountCommand extends Command {
  @override
  String get description => 'Add a new account.';

  @override
  String get name => 'add';

  //Function<String> _addFunction;

  AddAccountCommand() {
    argParser.addOption('email', abbr: 'e', help: 'The email address of the new account', valueHelp: 'email-address');
  }

  @override
  Future<EmailAccount> run() {
   var flow = AddAccountFlow(argResults['email']);
   return flow.run();
  }

}