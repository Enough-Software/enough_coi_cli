import 'package:enough_coi/email_account.dart';
import 'package:enough_coi/enough_coi.dart';
import 'package:enough_coi_cli/global.dart';
import 'package:enough_coi_cli/src/flow.dart';

class AddAccountFlow extends Flow<EmailAccount> {
  String _emailAddress;
  final bool _forceSslConnection;

  AddAccountFlow([this._emailAddress, this._forceSslConnection = false]);

  @override
  Future<EmailAccount> run() async {
    var console = Global.console;
    _emailAddress ??= await console.readInput('Your email: ');
    if (_emailAddress == null) {
      return null;
    }
    console.write('Discovering settings for ');
    console.writeBold(_emailAddress + ' ');
    console.startProgress();
    var config = await Global.client.discover(_emailAddress, forceSslConnection: _forceSslConnection);
    console.stopProgress();
    console.overwriteLine('Discovering settings for $_emailAddress');
    console.writeln();
    if (config == null) {
      console.error('Unable to discover settings for [$_emailAddress].');
      console.writeln('Please proceed by adding your setting manually.');
      return await AddAccountManuallyFlow(_emailAddress).run();;
    }
    console.write('Your provider is ');
    console.writeBold(config.displayName);
    console.writeln('.');
    String confirmation;
    while (!(confirmation == '' || (confirmation?.startsWith('y') ?? false))) {
      confirmation = await console.readInput('Is this correct [Y/n/check]: ');
      if (confirmation == null) {
        return null;
      }
      confirmation = confirmation.toLowerCase();
      if (confirmation == 'n') {
        return await AddAccountManuallyFlow(_emailAddress, config).run();
      }
      if (confirmation.startsWith('c')) {
        _printSettings(_emailAddress, config);
      }
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

  void _printSettings(String emailAddress, ClientConfig config) {
    print('Settings for $emailAddress:');
    var provider = config.emailProviders.first;
    print('provider: ${provider.displayName}');
    print('provider-domains: ${provider.domains}');
    print('documentation-url: ${provider.documentationUrl}');
    _printServerConfig(config.preferredIncomingServer);
    _printServerConfig(config.preferredOutgoingServer);
  }

  void _printServerConfig(ServerConfig server) {
    print('${server.typeName}:');
    print('  host: ${server.hostname}');
    print('  port: ${server.port}');
    print('  socket: ${server.socketTypeName}');
    print('  username: ${server.username}');
  }
}

class AddAccountManuallyFlow extends Flow<EmailAccount> {
  String _emailAddress;
  ClientConfig _config;

  AddAccountManuallyFlow(this._emailAddress, [this._config]);

  @override
  Future<EmailAccount> run() async {
    var console = Global.console;
    _emailAddress ??= await console.readInput('Your email: ');
    var imapHost = await console.readInput('IMAP host: ');
    var smtpHost = await console.readInput('SMTP host: ');
    return null;
  }
}
