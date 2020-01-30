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

        var chatMessages = await Global.client.fetchChatMessages(account);
        Global.console.stopProgress();
        Global.console.print('${chatMessages.length} chat messages:');
        Global.console.list(chatMessages.map((m) =>
            '${m.decodeHeaderValue('from')}: ${m.decodeHeaderValue('subject')}'));
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
    console.printRaw(welcome);
    console.addLineMark();
  }
}
