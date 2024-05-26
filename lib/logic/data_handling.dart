import 'package:agents_flutter_app/logic/logic.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'gorgias_api.dart';

/// Manages the JSON data
class DataHandler {

  Future<File> save(ModuleManager manager) {
    var jsonFile = jsonDecode('''{}''');
    jsonFile["save"] = manager.serialize();
    return saveToDatabase(jsonFile);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFileJson async {
    final path = await _localPath;
    return File('$path/database.json');
  }

  Future<File> get _localFileProlog async {
    final path = await _localPath;
    print('FILE PROLOG : $path/rules.pl');
    return File('$path/rules.pl');
  }

  Future<File> saveToDatabase(dynamic jsonFile) async {
    final file = await _localFileJson;

    // Write the file
    return file.writeAsString(json.encode(jsonFile));
  }

  Future<File> saveToProlog(dynamic prologFile) async {
    final file = await _localFileProlog;

    // Write the file
    return file.writeAsString(prologFile);
  }

  Future<ModuleManager> loadFromDatabase() async {
    final file = await _localFileJson;
    if(await file.exists()) {
      final contents = await file.readAsString();
      var jsonFile = jsonDecode(contents);
      ModuleManager res = ModuleManager.fromJson(jsonFile["save"]);
      return res;
    }
    else {
      return ModuleManager();
    }
  }

  Future<bool> isDatabaseCreated() async {
    final file = await _localFileJson;
    return await file.exists();
  }
}

/// Manages the Prolog/Gorgias code data
class PrologHandler {

  Future<Map<String, LogicRule>> getRules(ModuleManager m) async {
    Map<String, LogicRule> rules = {};
    if (m.resolveAll().isNotEmpty) {
      GorgiasAPI gorgias = GorgiasAPI();
      String returnedRules = await gorgias.getFile("rules.pl");
      List<String> split = returnedRules.split('\n');
      List<int> toRemove = [];
      split.removeAt(0);
      for (int i = 0; i < split.length; i++) {
        String line = split[i];
        if (!line.contains("prefer") && !line.contains("complement") && line != "") {
          LogicRule rule = LogicRule.fromString(line, m);
          rules[rule.identifier] = rule;
          toRemove.add(i);
        }
      }
      for (int i = 0; i < toRemove.length; i++) {
        split.removeAt(toRemove[i]-i);
      }
      m.rules = rules;
      for (int i = 0; i < split.length; i++) {
        String line = split[i];
        if (!line.contains("complement") && line != "") {
          LogicRule rule = LogicRule.fromStringPref(line, m);
          rules[rule.identifier] = rule;
        }
      }
    }
    
    return rules;
  }

  Future<bool> saveRules(ModuleManager m) async {
    Map<String, LogicRule> rules = m.rules;
    List<Fact> facts = m.resolveAll();
    GorgiasAPI gorgias = GorgiasAPI();

    final dynamics = ":- dynamic ${[for (Fact f in facts) '${f.name}/0'].join(',')}.";
    List<String> fileString = [dynamics];
    for (LogicRule r in rules.values) {
      fileString.add(r.toString());
    }
    fileString.add("complement(deny, allow).");
    fileString.add("complement(allow, deny).");

    DataHandler db = DataHandler();
    
    return db.saveToProlog(fileString.join('\n')).then(
      (value) {
        //db._localPath.then((path) {
        //  gorgias.addFile2('$path/rules.pl').then((value) => print(value));
        //});
        return true;
      }
    );
  }
}

