import '../../model/itemAndBeerClasses.dart';
import 'dart:async';
import 'dart:io';

abstract class BeerSearchService {
  Future<List<Item>> findBeersMatching( String pattern);
}