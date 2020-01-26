import 'dart:convert' as convert;
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:enough_coi/enough_coi.dart';
import 'package:enough_coi_cli/global.dart';

class DiscoverCommand extends Command {
  @override
  String get description =>
      'Discovers account settings.\nExample: coi discover --email you@domain.com';

  @override
  String get name => 'discover';

  DiscoverCommand() {
    argParser.addOption('email',
        abbr: 'e',
        help:
            'The email address for which the settings should be autodiscovered.',
        valueHelp: 'email-address');
    argParser.addOption('format',
        abbr: 'f',
        help: 'The output format.',
        allowed: ['json', 'text'],
        defaultsTo: 'text',
        valueHelp: 'format');
    argParser.addFlag('all', abbr: 'a', help: 'Show all discovered settings.');
    argParser.addFlag('pretty',
        help: 'When outputting JSON, use a pretty format.');
  }

  @override
  void run() async {
    String email = argResults['email'];
    if (email == null) {
      printUsage();
      return;
    }
    var discoverCfg = DiscoverConfig(argResults['all'],
        argResults['format'] == 'json', argResults['pretty']);
    await _discover(email, discoverCfg);
  }

  void _discover(String emailAddress, DiscoverConfig discoverCfg) async {
    if (discoverCfg.useText) {
      print('Discovering settings for $emailAddress...');
    }
    var config = await Global.client.discover(emailAddress);
    if (config?.isNotValid ?? true) {
      print('Unable to discover settings for $emailAddress');
      exit(1);
    } else if (discoverCfg.showAll) {
      if (discoverCfg.useJson) {
        if (discoverCfg.pretty) {
          var encoder = convert.JsonEncoder.withIndent('  ');
          var prettyprint = encoder.convert(config);
          print(prettyprint);
        } else {
          var json = convert.jsonEncode(config);
          print(json);
        }
      } else {
        print('Settings for $emailAddress:');
        for (var provider in config.emailProviders) {
          print('provider: ${provider.displayName}');
          print('provider-domains: ${provider.domains}');
          print('documentation-url: ${provider.documentationUrl}');
          print('Incoming:');
          for (var server in provider.incomingServers) {
            _printServerConfig(server, discoverCfg.useJson);
          }
          print('Outgoing:');
          for (var server in provider.outgoingServers) {
            _printServerConfig(server, discoverCfg.useJson);
          }
        }
      }
    } else {
      if (discoverCfg.useText) {
        print('Settings for $emailAddress:');
      } else {
        print('{');
      }
      if (config.preferredIncomingImapServer != null) {
        _printServerConfig(
            config.preferredIncomingImapServer, discoverCfg.useJson);
      } else {
        _printServerConfig(config.preferredIncomingServer, discoverCfg.useJson);
      }
      if (config.preferredOutgoingSmtpServer != null) {
        _printServerConfig(
            config.preferredOutgoingSmtpServer, discoverCfg.useJson, true);
      } else {
        _printServerConfig(
            config.preferredOutgoingServer, discoverCfg.useJson, true);
      }
      if (discoverCfg.useJson) {
        print('}');
      }
    }
    exit(0);
  }

  void _printServerConfig(ServerConfig server, bool useJson,
      [bool isLast = false]) {
    if (useJson) {
      print('  "${server.typeName}": {');
      print('    "host": "${server.hostname}",');
      print('    "port": ${server.port},');
      print('    "socket": "${server.socketTypeName}",');
      print('    "username": "${server.username}"');
      if (isLast) {
        print('  }');
      } else {
        print('  },');
      }
    } else {
      print('${server.typeName}:');
      print('  host: ${server.hostname}');
      print('  port: ${server.port}');
      print('  socket: ${server.socketTypeName}');
      print('  username: ${server.username}');
    }
  }
}

class DiscoverConfig {
  bool useJson;
  bool get useText => !useJson;
  bool pretty;
  bool showAll;

  DiscoverConfig(this.showAll, this.useJson, this.pretty);
}
