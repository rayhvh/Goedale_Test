import 'package:meta/meta.dart';

class Beer {
  final String id;
  final String name;
  final String description;
  final BeerLabel label;
  final double abv;
  final BeerStyle style;
  final double rating;
// add rating to model
  Beer({
    @required this.id,
    @required this.name,
    this.description,
    this.abv,
    this.label,
    this.style,
    this.rating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Beer &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              description == other.description &&
              label == other.label &&
              abv == other.abv &&
              style == other.style &&
              rating == other.rating;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      label.hashCode ^
      abv.hashCode ^
      style.hashCode^
      rating.hashCode;
}

class BeerStyle {
  final String id;
  final String name;

  BeerStyle({
    @required this.id,
    @required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BeerStyle &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode;
}


class BeerLabel {
  final String iconUrl;
  final String mediumUrl;
  final String largeUrl;

  BeerLabel({
    this.iconUrl,
    this.mediumUrl,
    this.largeUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BeerLabel &&
              runtimeType == other.runtimeType &&
              iconUrl == other.iconUrl &&
              mediumUrl == other.mediumUrl &&
              largeUrl == other.largeUrl;

  @override
  int get hashCode =>
      iconUrl.hashCode ^
      mediumUrl.hashCode ^
      largeUrl.hashCode;
}