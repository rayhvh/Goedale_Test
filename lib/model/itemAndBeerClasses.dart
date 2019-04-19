import 'package:meta/meta.dart';

class BeerSearch {
  final Item items;
  BeerSearch({this.items});
}

class Item {
  final Beer beer;
  final Brewery brewery;
  Item({this.beer, this.brewery});
}

class Brewery {
  final String id;
  final String name;
  Brewery({this.id, this.name});
}

class Beer {
  final String id;
  final String name;
  final String description;
  final BeerLabel label;
  final double abv;
  final BeerStyle style;
  final double rating;
  final String brewery;
  final List<BeerPhoto> beerPhotos;

  Beer({
    @required this.id,
    @required this.name,
    this.description,
    this.label,
    this.abv,
    this.style,
    this.rating,
    this.brewery,
    this.beerPhotos,
  });

  factory Beer.fromJson(Map<String, dynamic> json){
    return Beer(
      id: json['response']['beer']['bid'].toString(),
      name: json['response']['beer']['beer_name'],
      description: json['response']['beer']['beer_description'],
      label: BeerLabel(
        largeUrl: json['response']['beer']['beer_label_hd']
      ) ,
      abv: double.parse(json['response']['beer']['beer_abv'].toString()),

      style: BeerStyle(id: json['response']['beer']['beer_id'], name: json['response']['beer']['beer_style']),
      rating: json['response']['beer']['rating_score'],
      brewery: json['response']['beer']['brewery']['brewery_name'],
    );
  }
/*
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
      rating.hashCode;*/
}

class BeerPhoto{
  final String photo_md;
  BeerPhoto({this.photo_md});
}

class BeerStyle {
  final String id;
  final String name;

  BeerStyle({
    @required this.id,
    @required this.name,
  });

  /*@override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BeerStyle &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode;*/
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

  /* @override
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
      largeUrl.hashCode;*/
}
