import 'package:args/command_runner.dart';

class SendCommand extends Command {
  @override
  String get description => 'Send a message.\nExample: coi send --chat --message "hello world" --recipient "you@domain.com"';

  @override
  String get name => 'send';

  SendCommand() {
    argParser.addFlag('chat',
        abbr: 'c',
        help: 'If the message should be a COI chat message.',
        defaultsTo: true);
    argParser.addOption('account',
        abbr: 'a',
        help:
            'The account to be used for sending, defaults to the first account.',
        valueHelp: 'account');
    argParser.addMultiOption('recipient',
        abbr: 'r',
        help: 'The recipient(s) of the message.',
        valueHelp: 'recipient');
    argParser.addOption('message',
        abbr: 'm', help: 'The message to be sent.', valueHelp: 'message');
    argParser.addOption('subject',
        abbr: 's',
        help: 'The optional subject of the message.',
        valueHelp: 'subject',
        defaultsTo: null);
  }

  @override
  void run() {
    bool isChatMessage = argResults['chat'];
    String message = argResults['message'];
    String subject = argResults['subject'];
    List<String> recipients = argResults['recipient'];
    String accountName = argResults['account'];
    print(
        'Sending ${isChatMessage ? 'chat' : ''} ${subject != null ? '"' + subject + '":' : ''} "$message" to $recipients via $accountName');
  }
}
