import 'dart:convert' as convert;
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/enough_coi.dart';
import 'package:enough_coi_cli/global.dart';

class CheckCommand extends Command {
  @override
  String get description =>
      'Checks the COI compatibility of the specified account.\nExample: coi discover --email you@domain.com';

  @override
  String get name => 'check';

  CheckCommand() {
    argParser.addOption('email',
        abbr: 'e',
        help:
            'The email address for which the settings should be autodiscovered.',
        valueHelp: 'email-address');
    // argParser.addOption('format',
    //     abbr: 'f',
    //     help: 'The output format.',
    //     allowed: ['json', 'text'],
    //     defaultsTo: 'text',
    //     valueHelp: 'format');
    // argParser.addFlag('all', abbr: 'a', help: 'Show all discovered settings.');
    // argParser.addFlag('pretty',
    //     help: 'When outputting JSON, use a pretty format.');
  }

  @override
  void run() async {
    String email = argResults['email'];
    if (email == null) {
      printUsage();
      return;
    }
    // var discoverCfg = DiscoverConfig(argResults['all'],
    //     argResults['format'] == 'json', argResults['pretty']);
    await _check(email);
  }

  Future<void> _check(String emailAddress) async {
    print('Checking settings for $emailAddress...');
    var accounts = await Global.client.loadAccounts();
    if (accounts != null) {
      var lowerCaseEmail = emailAddress.toLowerCase();
      var matchingAccounts = accounts.where((a) =>
          a.email.toLowerCase().contains(lowerCaseEmail) ||
          a.name.toLowerCase().contains(lowerCaseEmail));
      if (matchingAccounts.isNotEmpty) {
        await _checkAccount(matchingAccounts.first);
        exit(0);
      }
    }
    var config = await Global.client.discover(emailAddress);
    if (config?.isNotValid ?? true) {
      print('Unable to check settings for $emailAddress');
      exit(1);
    }
    print('Currently a matching account needs to be configured first.');
    exit(0);
  }

  Future<void> _checkAccount(EmailAccount account) async {
    var config = await Global.client.getCoiServerConfiguration(account);
    if (config != null) {
      Global.console
          .writeln('- Server is COI compliant: ${config.isServerCoiCompliant}');
      Global.console.writeln(
          '- Server is WEBPUSH compliant: ${config.isServerWebPushCompliant}');
      Global.console
          .writeln('- COI is enabled for user: ${config.isCoiEnabledForUser}');
      Global.console.writeln('- Chat message filtering: ${config.filterRule}');
      Global.console.writeln('- COI root mailbox: ${config.mailboxRoot}');
      Global.console.writeln('- hierarchy separator: ${config.hierarchySeparator}');
      Global.console.writeln('- COI chats mailbox: ${config.mailboxChats}');
      Global.console
          .writeln('- COI contacts mailbox: ${config.mailboxContacts}');
    }
    if (config.isServerWebPushCompliant) {
      var key = await Global.client.getWebPushVapidKey(account);
      Global.console.writeln('- WEBPUSH server VAPID key: $key');
      var subscriptions = await Global.client.getWebPushSubscriptions(account);
      Global.console.writeln('- WEBPUSH subscriptions:');
      if (subscriptions == null || subscriptions.isEmpty) {
        Global.console.writeln('- [no subscriptions]');
      } else {
        for (var subscription in subscriptions) {
          Global.console.writeln('-> device: ${subscription.device}');
          Global.console.writeln('-> client: ${subscription.client}');
          Global.console.writeln('-> resource: ${subscription.resource}');
        }
      }
    }
  }
}
