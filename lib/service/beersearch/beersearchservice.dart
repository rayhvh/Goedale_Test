import '../../model/beer.dart';
import 'dart:async';
import 'dart:io';

abstract class BeerSearchService {
  Future<List<Beer>> findBeersMatching( String pattern);
}