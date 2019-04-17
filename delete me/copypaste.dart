Firestore.instance
    .runTransaction((Transaction transaction) async {
CollectionReference reference =
Firestore.instance.collection('beers');
await reference
    .add({"title": "", "editing": false, "amount": 0});



// oude firestore list view.r

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

