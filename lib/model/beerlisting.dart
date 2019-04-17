import 'package:meta/meta.dart';

import 'itemAndBeerClasses.dart';

class BeerListing {
  final Beer beer;
  final int price;
  final int stockAmount;
  // meer nodig voor een listing?
  BeerListing(
      {@required this.beer, @required this.price, @required this.stockAmount});
}
