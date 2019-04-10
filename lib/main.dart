import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:goedale_test/model/beer.dart';

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
      title: 'Flutter Demo',
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
              onTap: () {
                //   print( UntappdService().findBeersMatching("paradox"));
              },
            ),
          ],
        )),
        appBar: AppBar(
          title: Text('Cloud FireStore Example'),
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
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance.collection('beers').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return FirestoreListView(documents: snapshot.data.documents);
                },
              ),
            ),
            Expanded(child: UntappdListView())
          ],
        ));
  }
}

class BeerDetailPage extends StatelessWidget {
  final Beer _beer;

  BeerDetailPage(this._beer);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(_beer.name)));
  }
}

class UntappdListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UntappdListViewState();
  }
}

class _UntappdListViewState extends State<UntappdListView> {
  Future<List<Beer>> _beerList;


  Future<List<Beer>> _getBeersByString(String searchString) {
    return UntappdService().findBeersMatching(searchString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _beerList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Column(children: <Widget>[
            Flexible(
              child: TextFormField(
                decoration:
                    const InputDecoration(hintText: "Zoek naar een bier.."),

                onFieldSubmitted: (String item) {
                  this.setState(() {
                    _beerList = _getBeersByString(item);
                  });
                },
              ),
            )
          ]);
        } else {
          return Column(children: <Widget>[
            Flexible(
              child: TextFormField(
                initialValue: "zoeken",
                //        controller: myController,
                onFieldSubmitted: (String item) {
                  this.setState(() {
                    _beerList = _getBeersByString(item);
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
                        backgroundImage:
                            NetworkImage(snapshot.data[index].label.iconUrl),
                      ),
                      title: Text(snapshot.data[index].name),
                      subtitle: Text(snapshot.data[index].style.name + " " + snapshot.data[index].abv.toString() + "%"),
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    BeerDetailPage(snapshot.data[index])));
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

class FirestoreListView extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  FirestoreListView({this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemExtent: 110.0,
      itemBuilder: (BuildContext context, int index) {
        String title = documents[index].data['title'].toString();
        int amount = documents[index].data['amount'];
        return ListTile(
            title: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: Colors.white),
              ),
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: !documents[index].data['editing']
                        ? Text(title)
                        : TextFormField(
                            initialValue: title,
                            onFieldSubmitted: (String item) {
                              Firestore.instance
                                  .runTransaction((transaction) async {
                                DocumentSnapshot snapshot = await transaction
                                    .get(documents[index].reference);

                                await transaction.update(
                                    snapshot.reference, {'title': item});

                                await transaction.update(snapshot.reference,
                                    {"editing": !snapshot['editing']});
                              });
                            },
                          ),
                  ),
                  Text("$amount"),
                  Column(
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          Firestore.instance
                              .runTransaction((Transaction transaction) async {
                            DocumentSnapshot snapshot = await transaction
                                .get(documents[index].reference);
                            await transaction.update(snapshot.reference,
                                {'amount': snapshot['amount'] + 1});
                          });
                        },
                        icon: Icon(Icons.arrow_upward),
                      ),
                      IconButton(
                        onPressed: () {
                          Firestore.instance
                              .runTransaction((Transaction transaction) async {
                            DocumentSnapshot snapshot = await transaction
                                .get(documents[index].reference);
                            await transaction.update(snapshot.reference,
                                {'amount': snapshot['amount'] - 1});
                          });
                        },
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Firestore.instance.runTransaction((transaction) async {
                        DocumentSnapshot snapshot =
                            await transaction.get(documents[index].reference);
                        await transaction.delete(snapshot.reference);
                      });
                    },
                  )
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

  @override
  Future<List<Beer>> findBeersMatching(String pattern) async {
    HttpClient client = new HttpClient();
    //print(_callApi(client, pattern, 1));
    return _callApi(client, pattern, 1);
  }

  Future<List<Beer>> _callApi(
      HttpClient httpClient, String pattern, int retryCount) async {
    if (pattern == null || pattern.trim().isEmpty) {
      return List(0);
    }

    final serviceUri = _buildUntappdServiceURI(
        path: "search/beer",
        queryParameters: {'q': pattern, 'limit': '5'},
        retryCount: retryCount);

    HttpClientRequest request = await httpClient.getUrl(serviceUri.item1);
    HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode > 299) {
      if (retryCount < _MAX_TRY_BEFORE_FAIL) {
        //  BeerMeUpApp.sentry.capture(event: Event(message: "Invalid provider id: ${serviceUri.item2}"));
        _keysExcludedIds.add(serviceUri.item2);

        return _callApi(httpClient, pattern, retryCount + 1);
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

      return Beer(
        id: (beerJson["bid"] as int).toString(),
        name: beerJson["beer_name"],
        description: beerJson["beer_description"],
        abv: abv,
        label: label,
        style: style,
      );
    }).toList(growable: false);
  }
}
