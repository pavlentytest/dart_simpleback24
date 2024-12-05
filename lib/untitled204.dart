import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'untitled204.g.dart';


@HiveType(typeId: 0)
class CarHiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double power;
  CarHiveObject({
    required this.name,
    required this.power
  });
}

@JsonSerializable()
class CarDTO {
  int? id;
  String name;
  double power;

  CarDTO({
    this.id,
    required this.name,
    required this.power,
  });

  factory CarDTO.fromJson(Map<String, dynamic> json) => _$CarDTOFromJson(json);
  Map<String, dynamic> toJson() => _$CarDTOToJson(this);

 CarHiveObject toHive() => CarHiveObject(
    name: name,
    power: power
  );

  factory CarDTO.fromHive(int id, CarHiveObject hive) => CarDTO(
    id: id,
    name: hive.name,
    power: hive.power,
  );

  @override
  String toString() =>
      'Car(id=$id, name=$name, price=$power)';
}


abstract interface class CarsRepository {
  Future<void> init();
  Future<void> dispose();
  FutureOr<List<CarDTO>> getCars();
  FutureOr<CarDTO?> getCar(int id);
  FutureOr<int> addCar(CarDTO car);
  FutureOr<void> deleteCar(int id);
  FutureOr<void> updateCar(int id, CarDTO car);
}

class CarsRepositoryImpl implements CarsRepository {
  late Box<CarHiveObject> box;

  @override
  Future<void> init() async {
    Hive.init('.');
    Hive.registerAdapter(CarHiveObjectAdapter());
    box = await Hive.openBox('products');
    box.put(
      1,
      CarHiveObject(
        name: 'BMW 5',
        power: 234.0,
      ),
    );
  }

  @override
  Future<void> dispose() => Hive.close();

  @override
  FutureOr<List<CarDTO>> getCars() =>
      box
          .toMap()
          .entries
          .map((e) => CarDTO.fromHive(e.key, e.value))
          .toList();

  @override
  FutureOr<int> addCar(CarDTO car) => box.add(car.toHive());

  @override
  FutureOr<void> deleteCar(int id) => box.delete(id);

  @override
  FutureOr<CarDTO?> getCar(int id) {
    final value = box.get(id);
    if (value == null) return null;
    return CarDTO.fromHive(id, value);
  }

  @override
  FutureOr<void> updateCar(int id, CarDTO car) => box.put(id, car.toHive());

}

class CarsApi {
  CarsRepository repository;

  CarsApi(this.repository);


  Future<String?> _handle(
      String method, int? id, CarDTO? body) async {
    switch (method) {
      case 'GET':
        if (id == null) {
          final cars = await repository.getCars();
          return jsonEncode(cars);
        } else {
          final car = await repository.getCar(id);
          return jsonEncode(car);
        }
      case 'DELETE':
        repository.deleteCar(id!);
      case 'PUT':
        repository.updateCar(id!, body!);
      case 'POST':
        repository.addCar(body!);
      default:
        return null;
    }
  }


  Future<void> run() async {
    final server = await HttpServer.bind('0.0.0.0', 8080);
    await repository.init();
    await for (final request in server) {
      final uri = request.requestedUri;
      final segments = uri.pathSegments;
      if (segments[0] != 'cars') {
        request.response.statusCode = HttpStatus.badRequest;
      } else {
        int? id = segments.length > 1 ? int.tryParse(segments[1]) : null;
        String method = request.method;

        CarDTO? body;
        try {
          body = CarDTO.fromJson(
              jsonDecode(await utf8.decoder.bind(request).join()));
        } catch (e) {
          body = null;
        }
        try {
          final response = await _handle(method, id, body);
          if (response != null) {
            request.response.write(response);
          }
        } on CarsHTTPException catch (e) {
          request.response.statusCode = e.status;
          request.response.writeln(e.message);
          request.response.writeln('URI: ${e.uri.toString()}');
        }
      }
      await request.response.close();
    }
  }
}

class CarsHTTPException implements HttpException {
  Uri _uri;
  int _status;
  String _message;

  CarsHTTPException(this._status, this._uri, this._message);

  int get status => _status;

  @override
  String get message => _message;

  @override
  Uri? get uri => _uri;
}

