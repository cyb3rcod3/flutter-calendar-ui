import 'package:calendar_view/entities/event.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  final String eventsKey = "events";

  Database db;
  Future<AppDatabase> init() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    var dbPath = join(dir.path, 'calendar.db');
    db = await databaseFactoryIo.openDatabase(dbPath);

    return this;
  }

  addEvent(Event event) async {
    var store = intMapStoreFactory.store(eventsKey);
    return await store.add(db, event.toJson());
  }

  updateEvent(Event event) async {
    var store = intMapStoreFactory.store(eventsKey);
    return await store.record(event.id).put(db, event.toJson());
  }

  deleteEvent(Event event) async {
    var store = intMapStoreFactory.store(eventsKey);
    return await store.record(event.id).delete(db);
  }

  Future<List<Event>> getEvents() async {
    var store = intMapStoreFactory.store(eventsKey);
    List<RecordSnapshot<int, Map>> list = await store.find(db);

    return list.map((e) => Event.fromJson(e.value)..id = e.key).toList();
  }
}
