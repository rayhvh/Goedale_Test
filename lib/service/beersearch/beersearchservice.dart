import '../../model/beersearch.dart';
import 'dart:async';
import 'dart:io';

abstract class BeerSearchService {
  Future<List<Items>> findBeersMatching( String pattern);
}