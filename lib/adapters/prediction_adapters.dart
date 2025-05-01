// prediction_adapter.dart
import 'package:admin/models/predictions.dart';
import 'package:admin/screens/dashboard/components/recent_files.dart';
import 'package:hive/hive.dart';

class PredictionAdapter extends TypeAdapter<Prediction> {
  @override
  final int typeId = 0;

  @override
  Prediction read(BinaryReader reader) {
    // First register the WeeklyPrediction adapter if not already done
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WeeklyPredictionAdapter());
    }

    final symbol = reader.read() as String;
    final currentPrediction = reader.read() as double;
    final weeklyPredictions = reader.readList().cast<WeeklyPrediction>();

    return Prediction(
      symbol: symbol,
      currentPrediction: currentPrediction,
      weeklyPredictions: weeklyPredictions,
    );
  }

  @override
  void write(BinaryWriter writer, Prediction obj) {
    writer.write(obj.symbol);
    writer.write(obj.currentPrediction);
    writer.writeList(obj.weeklyPredictions);
  }
}

class WeeklyPredictionAdapter extends TypeAdapter<WeeklyPrediction> {
  @override
  final int typeId = 1;

  @override
  WeeklyPrediction read(BinaryReader reader) {
    return WeeklyPrediction(
      week: reader.read() as int,
      open: reader.read() as double,
      high: reader.read() as double,
      low: reader.read() as double,
      close: reader.read() as double,
      adjustedClose: reader.read() as double?,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyPrediction obj) {
    writer.write(obj.week);
    writer.write(obj.open);
    writer.write(obj.high);
    writer.write(obj.low);
    writer.write(obj.close);
    writer.write(obj.adjustedClose);
  }
}

class ChartDataAdapter extends TypeAdapter<ChartData> {
  @override
  final int typeId = 2;

  @override
  ChartData read(BinaryReader reader) {
    return ChartData(
      x: reader.read() as DateTime,
      open: reader.read() as double,
      high: reader.read() as double,
      low: reader.read() as double,
      close: reader.read() as double,
    );
  }

  @override
  void write(BinaryWriter writer, ChartData obj) {
    writer.write(obj.x);
    writer.write(obj.open);
    writer.write(obj.high);
    writer.write(obj.low);
    writer.write(obj.close);
  }
}

class UserData {
  final String uid;
  final String name;
  final String lastName;
  final String email;
  final DateTime lastLogin;

  UserData({
    required this.uid,
    required this.name,
    required this.lastName,
    required this.email,
    required this.lastLogin,
  });
}

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 3; // Changed to 3 to avoid conflicts

  @override
  UserData read(BinaryReader reader) {
    return UserData(
      uid: reader.read() as String,
      name: reader.read() as String,
      lastName: reader.read() as String,
      email: reader.read() as String,
      lastLogin: DateTime.parse(reader.read() as String),
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer.write(obj.uid);
    writer.write(obj.name);
    writer.write(obj.lastName);
    writer.write(obj.email);
    writer.write(obj.lastLogin.toIso8601String());
  }
}
