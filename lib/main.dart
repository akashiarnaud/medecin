import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noms de médecins',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des médecins')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('medecin').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    final int idMed = record.id;

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
              title: Text(record.name),
              onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListRdv(idMed: idMed),
                    ),
                  ))),
    );
  }
}

class Record {
  final String name;
  final int id;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['nom'] != null),
        assert(map['id'] != null),
        name = map['nom'],
        id = map['id'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name>";
}

class RecordRdv {
  final String commentaire;
  final int id;
  final Timestamp dateH;
  final DocumentReference reference;

  RecordRdv.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['commentaire'] != null),
        assert(map['id'] != null),
        assert(map['dateH'] != null),
        commentaire = map['commentaire'],
        id = map['id'],
        dateH = map['dateH'];

  RecordRdv.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$commentaire>";
}

class ListRdv extends StatelessWidget {
  final idMed;

  ListRdv({this.idMed});

  @override
  Widget build(BuildContext context) {
    DateTime date;

    final CollectionReference collect =
        Firestore.instance.collection('rendezvous');
    return Scaffold(
      appBar: AppBar(title: Text('Liste des rendez-vous')),
      body: Center(
          child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.blueAccent,
        onPressed: () {
            DatePicker.showDateTimePicker(context,
                minTime: new DateTime.now(),
                theme: DatePickerTheme(
                  containerHeight: 600.0,
                ),
                showTitleActions: true,
                onChanged: (date) {
              print('change $date');
            }, onConfirm: (date) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RendezVous(idMed: idMed, date: date),
               //builder: (context) => MyCustomForm(idMed: idMed, date: date),
              ),
            );
          }, currentTime: DateTime.now(), locale: LocaleType.fr);
        },
        child: Text(
          'Choisir un rendez-vous',
          style: TextStyle(color: Colors.white),
        ),
      )),
    );
  }
}

Future<bool> doesNameAlreadyExist(String name) async {
  final QuerySnapshot result = await Firestore.instance
      .collection('company')
      .where('name', isEqualTo: name)
      .limit(1)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  return documents.length == 1;
}

class RendezVous extends StatelessWidget {
  final date;
  final idMed;
  final commentaire;

  RendezVous({this.idMed, this.date, this.commentaire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    Firestore.instance
        .collection('rendezvous')
        .where("idMedecin", isEqualTo: idMed)
        .where("dateH", isEqualTo: date)
        .getDocuments()
        .then((event) {
      if (event.documents.isNotEmpty) {
        print("Le rendez-vous est déjà pris, merci d'en choisir un autre");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ListRdv(idMed: idMed)));
        showDialog(
          context: context,
          builder: (BuildContext context) => _buildPopupDialog(context),
        );
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              
                builder: (context) => MyCustomForm(idMed: idMed, date: date)));
      }
    });
    /*var test = Firestore.instance.collection('rendezvous').where("idMedecin", isEqualTo: idMed).where("dateH", isEqualTo: date).getDocuments();
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('rendezvous').where("idMedecin", isEqualTo: idMed).where("dateH", isEqualTo: date).snapshots(),
      builder: (context, snapshot) {
        if (!test. || snapshot.data.documents.isEmpty)
           Navigator.push(context, MaterialPageRoute(builder: (context) => AddRdv(date: date, idMed: idMed)),
          );
           return null;
        } 
        else{
          print("Le rendez-vous est déjà pris, merci d'en choisir un autre");
           return LinearProgressIndicator();
            // return _buildList(context, snapshot.data.documents);
        }
       
      },
    );*/
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = RecordRdv.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.dateH),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ListTile(
            title: Text(record.dateH.toDate().toString()),
          )),
    );
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Echéc'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              "Le rendez-vous est déjà pris, merci de choisir une autre date, ou une autre heure"),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget RdvDejaPris(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          border: InputBorder.none, hintText: 'Enter a search term'),
    );
  }
}

class AddRdv extends StatelessWidget {
  final date;
  final idMed;
  final commentaire;

  AddRdv({this.date, this.idMed, this.commentaire});

  @override
  Widget build(BuildContext context) {
    // Create a CollectionReference called users that references the firestore collection
    CollectionReference rdv = Firestore.instance.collection('rendezvous');
    return FlatButton(
      onPressed: () {
        rdv.add({
          // John Doe
          'commentaire': commentaire, // Stokes and Sons
          'dateH': date,
          'idMedecin': idMed,
          'idPatient': 1,
          'id': 5,
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
        showDialog(
          context: context,
          builder: (BuildContext context) => _buildPopupDialog(context),
        );
      },
      child: Text(
        "Valider le rendez-vous",
      ),
      color: Colors.blueAccent,
      textColor: Colors.white,
    );

    /*Future<void> addRdv() {
      // Call the user's CollectionReference to add a new user
      return rdv
          .add({ // John Doe
            'commentaire': 'test commentaire ajout', // Stokes and Sons
            'dateH': date,
            'idMedecin' : idMed,
            'idPatient': 1
          })
          .then((value) => print("Rendez vous pris"))
          .catchError((error) => print("Failed to add user: $error"));
        
    }*/
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Réussi'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Le rendez-vous a bien été pris."),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class MyCustomForm extends StatefulWidget {
  final date;
  final idMed;

  MyCustomForm({this.date, this.idMed});
  @override
  _MyCustomFormState createState() => _MyCustomFormState(date: date, idMed: idMed);
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final date;
  final idMed;

  _MyCustomFormState({this.date, this.idMed});
  
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Decrivez vos symptômes en quelques mots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: myController,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        onPressed: () {
          Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRdv(idMed: idMed, date: date, commentaire: myController.text),
                    ),
                  );
        },
        tooltip: 'Show me the value!',
        child: Icon(Icons.text_fields),
      ),
    );
  }
}