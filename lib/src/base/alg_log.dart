// @copyright 2017-2018 adalberto.lacruz@gmail.com

import 'dart:html';
import 'dart:indexed_db' as idb;

///
/// Log Manager
///
class AlgLog {
  /// db store
  static const String _LOG_STORE = 'logStore';
  /// db index
  static const String _LOG_INDEX = 'logIndex';

  /// db
  static idb.Database _db;

  /// enable/disable log recording
  static bool disabled = true;

  /// True, we are busy, add row to queue and exit
  static bool _isProcessingQueue = false;

  /// row logs pending to store in db
  static List<String> _queue = <String>[];

  /// For Blob write
  static String _writeUrl;

  ///
  /// add a log row
  ///
  static void log(String source, dynamic message) {
    if (disabled)
      return;

    // ms from start
    final int now = window.performance.now().ceil();
    _queue.add('$now $source $message');
    _processQueue();
  }

  ///
  /// Store pending rows to db
  ///
  static void _processQueue() {
    if (_isProcessingQueue)
        return;
    _isProcessingQueue = true;

    if (_db == null) {
      _openDb();
    } else {
      _emptyQueue();
    }

  }

  ///
  /// Open db and save pending rows
  ///
  static void _openDb() {
    window.indexedDB.open('log',
      version: 1,
      onUpgradeNeeded: _initializeDb)
    .then((idb.Database db) {
      AlgLog._db = db;

      final idb.Transaction transaction = db.transaction(_LOG_STORE, 'readwrite');
      return transaction.objectStore(_LOG_STORE).clear();
    })
    .then((_) {
      _emptyQueue();
    });
  }

  ///
  /// First time db creation or upgrade
  ///
  static void _initializeDb(dynamic e) { // idb.VersionChangeEvent e
    _db = (e.target as idb.Request).result;
    _db.createObjectStore(_LOG_STORE, autoIncrement: true)
      ..createIndex(_LOG_INDEX, 'logID', unique: true);
  }

  ///
  /// Save rows to db
  ///
  static void _emptyQueue() {
    if (_queue.isNotEmpty) {
      final idb.Transaction transaction = _db.transaction(_LOG_STORE, 'readwrite');
      final idb.ObjectStore objectStore = transaction.objectStore(_LOG_STORE);

      while (_queue.isNotEmpty) {
        objectStore.add(_queue.removeAt(0));
      }
    }
    _isProcessingQueue = false;
  }

  ///
  /// Save db log to a csv file
  ///
  static void save() {
    final idb.Transaction transaction = _db.transaction(_LOG_STORE, 'readonly');
    final idb.ObjectStore objectStore = transaction.objectStore(_LOG_STORE);
    final CsvLog csv = new CsvLog();

    objectStore.openCursor(autoAdvance: true).listen((idb.CursorWithValue cursor) {
      csv.add(cursor.value);
    })
    .onDone(() {
      _writeToFile(csv);
    });
  }

  ///
  /// Write to File
  ///
  static void _writeToFile(CsvLog csv) {
    final String text = csv.toString(); // use.toTxt for plain list of log entries
    final Blob blob = new Blob(<String>[text], 'text/plain', 'native');

    if (_writeUrl != null)
      Url.revokeObjectUrl(_writeUrl);
    _writeUrl = Url.createObjectUrlFromBlob(blob);

    new AnchorElement(href: _writeUrl)
        ..download = 'log.csv'
        ..click();
  }
}

// ---------------------------------------------------

///
/// Transform the log rows to csv format
///
class CsvLog {
  /// Constructor
  CsvLog();

  /// Channels data
  Map<String, List<String>> matrix = <String, List<String>>{};

//  /// raw data received
//  List<String> raw = <String>[];

  /// time marks
  List<String> timeLine = <String>[];

  ///
  /// row = 'time channel value'
  ///
  void add(String row) {
//    raw.add(row);
    final List<String> _row = row.split(' ');
    final String time = _row[0];
    final String channel = _row[1];
    final String value = _row[2];

    addChannelValue(channel, value); // order is important
    timeLine.add(time);
  }

  ///
  /// adds a value to the matrix
  ///
  void addChannelValue(String channel, String value) {
    // add channel and synchronize
    if (!matrix.containsKey(channel)) {
      final List<String> entry = <String>[];
      for (int i = 0; i < timeLine.length; i++) {
        entry.add('');
      }
      matrix[channel] = entry;
    }

    matrix.forEach((String key, List<String> entry) {
      entry.add(key == channel ? value : '');
    });
  }

//  /// Plain txt, as recorded
//  String toTxt() => raw.join('\n');

  ///
  /// Build de csv text
  ///
  /// TIMELINE,time1,time2, ...
  /// Channel1,,,event,,...
  /// ...
  /// ChannelN,,event,,,,...
  ///
  @override
  String toString() {
    // ignore: prefer_interpolation_to_compose_strings
    String result = 'TIMELINE,' + timeLine.join(',') + '\n';

    matrix.forEach((String key, List<String> entry) {
      // ignore: prefer_interpolation_to_compose_strings
      result = result + key + ',' + entry.join(',') + '\n';
    });

    return result;
  }
}

