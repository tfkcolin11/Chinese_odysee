import 'package:equatable/equatable.dart';

/// Base class for all models in the application
abstract class BaseModel extends Equatable {
  /// Converts the model to a JSON map
  Map<String, dynamic> toJson();
  
  @override
  List<Object?> get props => [];
}
