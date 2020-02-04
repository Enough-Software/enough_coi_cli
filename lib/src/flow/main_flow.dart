import 'dart:io';

import 'package:enough_coi/email_account.dart';
import 'package:enough_coi_cli/src/flow/account_add_flow.dart';
import 'package:enough_coi_cli/src/flow/all_flows.dart';

import '../../global.dart';
import '../flow.dart';

class MainFlow extends Flow<void> {
  @override
  Future<void> run() async {
    _welcome();
    while (true) {
      var accounts = await Global.client.loadAccounts();
      Flow<EmailAccount> accountFlow;
      if (accounts == null || accounts.isEmpty) {
        Global.console.print(
            'You have not configured any account yet. Please start by entering your email address:');
        accountFlow = AddAccountFlow();
      } else {
        accountFlow = SelectAccountFlow(accounts);
      }
      var account = await accountFlow.run();
      if (account == null) {
        exit(0);
      } else {
        Global.console.returnToLineMark();
        Global.console.addLineMark();
        Global.console.write('Account: ');
        Global.console.writeBold(account.name);
        Global.console.write(' ');
        Global.console.startProgress();

        var conversations = await Global.client.fetchConversations(account);
        Global.console.stopProgress();
        Global.console.list(
            conversations.map((c) => '${c.name}: ${c.lastMessage.subject}'));
        // Global.console.list(
        //     conversations.map((c) => '${c.name}: ${c.threadReference}'));

        var conversationNumber = await Global.console.readInput('Number: ');
        if (conversationNumber == null || conversationNumber.startsWith('q')) {
          exit(0);
        }
        var selectedConversation =
            Global.console.parseListChoice(conversationNumber, conversations);
        if (selectedConversation != null) {
          Global.console.returnToLineMark();
          Global.console.addLineMark();
          Global.console.write(account.name + ' / ');
          Global.console.writeBold(selectedConversation.name);
          Global.console.writeln();
          for (var message in selectedConversation.messages) {
            Global.console.writeBold(message.from?.name ?? message.from?.email);
            Global.console.write(': ${message.subject}');
            Global.console.writeln();
          }
        }

        // var chatMessages = await Global.client.fetchChatMessages(account);
        // Global.console.stopProgress();
        // if (chatMessages == null) {
        //   print('Error: Unable to load messages.');
        //   exit(0);
        // }
        // Global.console.print('${chatMessages?.length} chat messages:');
        // Global.console.list(chatMessages.map((m) =>
        //     '${m.decodeHeaderValue('from')}: ${m.decodeHeaderValue('subject')}'));
        exit(0);
        //TODO switch to conversation flow
        // var conversation = await SelectConversationFlow(account).run();

      }
    }
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
    var welcomeLogo = '''
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXK0OOkkkkkkO0KXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMNKkdc;'...          ..';cox0XWMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMN0xc,.                         ..;oOXWMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMN0o,.                                  .ckXMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWXx;.                                        'l0WMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMWKo.                                             .:OWMMMMMMMMMMMMMMM
MMMMMMMMMMMXd.                                                 .c0WMMMMMMMMMMMMM
MMMMMMMMMWO;       .:x0Oxoc,.                                    .dNMMMMMMMMMMMM
MMMMMMMMNd.     .cd0WMMMMMMNKOdc,.                                 :KMMMMMMMMMMM
MMMMMMMXl.    ;xXWMMMMMMMMMWNKOxl:;;;;;;;;;;;,,,''...               ,OWMMMMMMMMM
MMMMMMNl    .oXMMMMMMMMMMMW0dc::::::::::::::::::::::;ldl,.           ,OMMMMMMMMM
MMMMMNo.    .:kNMMMMMMMMMWKo:::::::::::::::::::::::cxXWMN0o,.         ;KMMMMMMMM
MMMMMk.    .cONMMMMMMMMMMMXd:::::::::::::::::::::lxKWMMMMMMNOc.        lNMMMMMMM
MMMMX:   .c0WMMMMMMMMMMMMMWXkollloodddxdddoolodx0XWMMMMMMMMMMW0l.      .kMMMMMMM
MMMMk.  ,OWMMMMMMMMMMMMMMMMMWNXXNNWWWWWWWWWNNNWWMMMMMMMMMMMMMMMWKd;.    cNMMMMMM
MMMWl .lXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWk.   ,0MMMMMM
MMMX:.xWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK,   .OMMMMMM
MMMXdkWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKOXWMMMMMMMMMMMWd.   .kMMMMMM
MMMWNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWx. ,OMMMMMMMMMMNx.    .kMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWo  .kMMMMMMMMWKc.     .OMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXxoOWMMMMMMW0l.       ;XMMMMMM
MMMMMMMMWN0kkkkO000000XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWOc.        .dWMMMMMM
MMMMMMMNOo::::::::::::lxXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWMWO:.          ,KMMMMMMM
MMMMMMWOc:::::::::::;,'':d0WMMMMMMMMMMMNK0O000KK00Okxoo0Xo.           .xWMMMMMMM
MMMMMMNx::::::::;,'..  .:kNMMMMMMMMMMMNl..  .....    .dO:            .oNMMMMMMMM
MMMMMMWKo:::::;'.     ;0WMMMMMMMMMMMMXl             'dd'            .lNMMMMMMMMM
MMMMMMMWKd::;..       oWMMMMMMMMMMMM0:            .:l;             .dNMMMMMMMMMM
MMMMMMMMMXx;.         '0MMMMMMMMMMNx'            .,'              'kWMMMMMMMMMMM
MMMMMMMMMMNk'         .kMMMMMMMMWKc.                            .lKMMMMMMMMMMMMM
MMMMMMMMMMMMXo.        'dKWMMMMXd.                            .:OWMMMMMMMMMMMMMM
MMMMMMMMMMMMMWKd'        .:kNNx,                            .cOWMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMNkc.       .''                           .,dKWMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWXkc'.                              .:d0WMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMN0xl;..                    .,cdOXWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMWNKOxolc:;;;,;;;:clodk0XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWWWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
''';
    console.printRaw(welcome);
    console.addLineMark();
  }
}
