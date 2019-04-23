import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:goedale_test/model/itemAndBeerClasses.dart';
import 'package:goedale_test/model/beerlisting.dart';
import 'package:http/http.dart' as http;

import 'package:goedale_test/service/beersearch/beersearchservice.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Goedale',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: new Drawer(
            child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text("Debug info"),
              decoration: BoxDecoration(),
            ),
            ListTile(
              title: Text("niets"),
              onTap: () {},
            ),
          ],
        )),
        appBar: AppBar(
          title: Text('Goedale aanbod'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Firestore.instance
                    .runTransaction((Transaction transaction) async {
                  CollectionReference reference =
                      Firestore.instance.collection('beers');
                  await reference
                      .add({"title": "", "editing": false, "amount": 0});
                });
              },
            )
          ],
        ),
        body: Row(
          children: <Widget>[
            Expanded(child: Column(
              children: <Widget>[
                Container(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Vooraad", style: Theme.of(context).textTheme.title,),
                ),),
                Expanded(
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('bokaalStock')
                        .snapshots(), // change to dynamic db?
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      return FirestoreListViewBeerStock(
                          documents: snapshot.data.documents);
                    },
                  ),
                ),
              ],
            ),),
            Expanded(child: Column(
              children: <Widget>[
                Container(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Toevoegen nieuw bier", style: Theme.of(context).textTheme.title),
                ),),
                Expanded(child: UntappdListView()),
              ],
            ),)

          ],
        ));
  }
}



class UntappdBeerDetailPage extends StatefulWidget {
  final Beer _beer;
  UntappdBeerDetailPage(this._beer);
  @override
  State<StatefulWidget> createState() {
    return _UntappdBeerDetailPageState(_beer);
  }
}

class _UntappdBeerDetailPageState extends State<UntappdBeerDetailPage>{
  final Beer _beer;
  Future<Beer> _untappdBeer;

  _UntappdBeerDetailPageState(this._beer);
  TextEditingController amountController = new TextEditingController();
  TextEditingController priceController = new TextEditingController();
  TextEditingController tasteDescriptionController = new TextEditingController();
  @override
  void initState(){
    super.initState();
   _untappdBeer = UntappdService().findBeerById(_beer.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_beer.name)),
      body: Row(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _untappdBeer,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(child: Center(child: CircularProgressIndicator()));
              } else {
                print(snapshot.data.rating);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Image.network(snapshot.data.label.largeUrl, height: 200,),
                                  Text(_beer.name, style: Theme.of(context).textTheme.title),
                                  Text(snapshot.data.brewery), // via future untappd because we can only have 100 calls a hour. it only gets calls and info of beer at details
                                  Text(_beer.style.name),
                                  Text(_beer.abv.toString()+"%"),
                                  Text("Rating: " + snapshot.data.rating.toString()),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                      hintText: "Hoeveelheid"),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: priceController,
                                  decoration:
                                  const InputDecoration(hintText: "Prijs"),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: tasteDescriptionController,
                                  decoration:
                                  const InputDecoration(hintText: "Smaak omschrijving"),
                                ),
                                RaisedButton(
                                    onPressed: () {
                                      Firestore.instance.runTransaction(
                                              (Transaction transaction) async {
                                            DocumentReference reference =
                                            Firestore.instance
                                                .collection("bokaalStock").document(_beer.id);
                                            await reference.setData({
                                              "name": _beer.name,
                                              "abv": _beer.abv,
                                              "brewery": snapshot.data.brewery,
                                              "desc": _beer.description,
                                              "tasteDesc": tasteDescriptionController.text,
                                              "id": _beer.id,
                                              "rating": snapshot.data.rating,
                                              "style": _beer.style.name,
                                              "label": {
                                                "iconUrl": _beer.label.iconUrl,
                                                "mediumUrl": _beer.label.iconUrl,
                                                "largeUrl": snapshot.data.label.largeUrl,
                                              },
                                              "price": int.parse(priceController.text) ,
                                              "amount": int.parse(amountController.text),
                                            });
                                            
                                          });

                                      Firestore.instance.runTransaction(
                                              (Transaction transaction) async { // improve using batch,
                                            CollectionReference reference =
                                            Firestore.instance.collection("bokaalStock").document(_beer.id).collection("beerPhotos");
                                           /* reference.getDocuments().then((snapshot) {
                                              for (DocumentSnapshot ds in snapshot.documents){
                                                ds.reference.delete();
                                              };
                                            });*/
                                            print(snapshot.data.beerPhotos.length);
                                            for(var i = 0; i < snapshot.data.beerPhotos.length; i++){
                                              await reference.add({
                                                "photo_md": snapshot.data.beerPhotos[i].photo_md,
                                              });
                                            };
                                          }
                                      );

                                      Navigator.pop(context);
                                    },
                                    child: const Text('Toevoegen')),
                              ],
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text("Beschrijving",style: Theme.of(context).textTheme.title),
                            Text(_beer.description),
                            Text("Foto's",style: Theme.of(context).textTheme.title),

                            Container( height: 200,
                              child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: snapshot.data.beerPhotos.length, itemBuilder: (BuildContext context, int index){
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(snapshot.data.beerPhotos[index].photo_md, height: 200,),
                                );
                              },),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
          )
        ],
      ),
    );
  }
}

class UntappdListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UntappdListViewState();
  }
}

class _UntappdListViewState extends State<UntappdListView> {
  Future<List<Item>> _beerSearchItemsList;

  Future<List<Item>> _getBeerSearchItemsByString(String searchString) {
    return UntappdService().findBeersMatching(searchString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _beerSearchItemsList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Column(children: <Widget>[
            Flexible(
              child: TextFormField(
                decoration:
                    const InputDecoration(hintText: "Zoek naar een bier.."),
                onFieldSubmitted: (String item) {
                  this.setState(() {
                    _beerSearchItemsList = _getBeerSearchItemsByString(item);
                  });
                },
              ),
            )
          ]);
        } else {
          return Column(children: <Widget>[
            Container(
              child: TextFormField(
                initialValue: "",
                //        controller: myController,
                onFieldSubmitted: (String item) {
                  this.setState(() {
                    _beerSearchItemsList = _getBeerSearchItemsByString(item);
                  });
                },
              ),
            ),
            Expanded(

              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    // stateless widget maken
                    return ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot.data[index].beer.label.iconUrl),
                      ),
                      title: Text(snapshot.data[index].beer.name),
                      subtitle: Text(snapshot.data[index].beer.style.name +
                          " - " +
                          snapshot.data[index].beer.abv.toString() +
                          "% - " +
                          snapshot.data[index].brewery.name),
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => UntappdBeerDetailPage(
                                    snapshot.data[index].beer)));
                      },
                    );
                  }),
            ),
          ]);
        }
      },
    );
  }
}

class FirestoreListViewBeerStock extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  FirestoreListViewBeerStock({this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        var _listing = BeerListing(
          beer: Beer(
            id: documents[index].data['id'].toString(),
            name: documents[index].data['name'].toString(),
            brewery: documents[index].data['brewery'].toString(),
            label: BeerLabel(
                iconUrl: documents[index].data['label']['iconUrl'].toString()),
            style: BeerStyle(
                id: null, name: documents[index].data['style'].toString()),
            abv: documents[index].data['abv'],
            rating: documents[index].data['rating'],
          ),
          price: documents[index].data['price'],
          stockAmount: documents[index].data['amount'],
        );

        return ListTile(
            title: Container(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Flexible(child: ListTile(

                    isThreeLine: true,
                    leading: CircleAvatar(
                      backgroundImage:
                      NetworkImage(_listing.beer.label.iconUrl),
                    ),
                    title: Text(_listing.beer.name),
                    subtitle: Text(_listing.beer.brewery +
                        " - " +
                        _listing.beer.abv.toString() +
                        "% - " +
                        _listing.beer.style.name +
                        " - Rating "+
                        _listing.beer.rating.toString()
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  UntappdBeerDetailPage(_listing.beer))); //change to stockbeerdetail
                    },
                  ),),
                  Container( child: Column(
                    children: <Widget>[
                      Text(_listing.stockAmount.toString() +" x"),
                      Text("€ " + _listing.price.toString()),
                    ],
                  ),)
                ],
              ),
            ),
            onTap: () => Firestore.instance
                    .runTransaction((Transaction transaction) async {
                  DocumentSnapshot snapshot =
                      await transaction.get(documents[index].reference);
                  await transaction.update(
                      snapshot.reference, {"editing": !snapshot["editing"]});
                }));
      },
    );
  }
}

class UntappdService implements BeerSearchService {
  static const _UNTAPPD_DB_API_ENDPOINT = "api.untappd.com";
  static const _MAX_TRY_BEFORE_FAIL = 3;

  //final Config _config;
  final List<String> _keysExcludedIds = List();

  //final Random _random = Random();

  Tuple2<Uri, String> _buildUntappdServiceURI({
    @required String path,
    @required int retryCount,
    Map<String, String> queryParameters,
  }) {
    final Map<String, String> queryParams = queryParameters ?? Map();

    queryParams.addAll({
      "client_secret": "F9F5BE857919FE3A91196BDC3FA5E84A9B5A9C26",
      "client_id": "3F67FBB565C90403B951D4F0CD13D1A6FD7ED3E9"
    });

    return Tuple2(Uri.https(_UNTAPPD_DB_API_ENDPOINT, "/v4/$path", queryParams),
        "3F67FBB565C90403B951D4F0CD13D1A6FD7ED3E9");
  }

  Future<Beer> findBeerById(String id) async {
    HttpClient client = new HttpClient();
    return _callApiBeerById(client, id, 1);
  }

  Future<Beer> _callApiBeerById(HttpClient httpClient, String id, int retryCount) async {
   /* final serviceUri = _buildUntappdServiceURI(
        path: "beer/info/"+id,
        retryCount: retryCount);
    HttpClientRequest request = await httpClient.getUrl(serviceUri.item1);
    HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode > 299) {
      if (retryCount < _MAX_TRY_BEFORE_FAIL) {
        _keysExcludedIds.add(serviceUri.item2);
        return _callApiBeerById(httpClient, id, retryCount + 1);
      }
      throw Exception(
          "Bad response: ${response.statusCode} (${response.reasonPhrase})");
    }
    String responseBody = await response.transform(utf8.decoder).join();
   // Map data = json.decode(responseBody);*/
   final response = await http.get("https://api.untappd.com/v4/beer/info/" +id + "?client_id=3F67FBB565C90403B951D4F0CD13D1A6FD7ED3E9&client_secret=F9F5BE857919FE3A91196BDC3FA5E84A9B5A9C26");
   if (response.statusCode == 200){
     print(json.decode(response.body));

     return Beer.fromJson(json.decode(response.body));
   }
   else {
     // If that response was not OK, throw an error.
     print (response.statusCode);
     throw Exception('Failed to load post');
   }
   /* final Map<String, dynamic> responseJson = data["response"];
    print(responseJson['beer']);
    return(responseJson['beer'] as Beer);*/
  }

  @override
  Future<List<Item>> findBeersMatching(String pattern) async {
    HttpClient client = new HttpClient();
    return _callApiBeerItems(client, pattern, 1);
  }

  Future<List<Item>> _callApiBeerItems(
      HttpClient httpClient, String pattern, int retryCount) async {
    if (pattern == null || pattern.trim().isEmpty) {
      return List(0);
    }

    final serviceUri = _buildUntappdServiceURI(
        path: "search/beer",
        queryParameters: {'q': pattern, 'limit': '20'},
        retryCount: retryCount);

    HttpClientRequest request = await httpClient.getUrl(serviceUri.item1);
    HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode > 299) {
      if (retryCount < _MAX_TRY_BEFORE_FAIL) {
        _keysExcludedIds.add(serviceUri.item2);
        return _callApiBeerItems(httpClient, pattern, retryCount + 1);
      }
      throw Exception(
          "Bad response: ${response.statusCode} (${response.reasonPhrase})");
    }

    String responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    final Map<String, dynamic> responseJson = data["response"];
    int totalResults = responseJson["found"] ?? 0;
    if (totalResults == 0) {
      return List(0);
    }

    return (responseJson['beers']['items'] as List).map((beerJsonObject) {
      final Map<String, dynamic> beerJson = beerJsonObject["beer"];
      final Map<String, dynamic> breweryJson = beerJsonObject["brewery"];

      BeerStyle style;
      final String styleName = beerJson["beer_style"];
      if (styleName != null) {
        style = BeerStyle(
          id: styleName,
          name: styleName,
        );
      }

      double abv;
      if (beerJson["beer_abv"] != null) {
        if (beerJson["beer_abv"] is double) {
          abv = beerJson["beer_abv"];
        } else if (beerJson["beer_abv"] is int) {
          abv = (beerJson["beer_abv"] as int).toDouble();
        }
      }

      BeerLabel label;
      if (beerJson["beer_label"] != null) {
        label = BeerLabel(
          iconUrl: beerJson["beer_label"],
        );
      }

      return Item(
          beer: Beer(
            id: (beerJson["bid"] as int).toString(),
            name: beerJson["beer_name"],
            description: beerJson["beer_description"],
            abv: abv,
            label: label,
            style: style,
          ),
          brewery: Brewery(
            id: breweryJson["brewery_id"].toString(),
            name: breweryJson["brewery_name"],
          ));
    }).toList(growable: false);
  }
}
