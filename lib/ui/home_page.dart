import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
    //helper.deleteContact(5);
    print(contacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/person.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      checkLength(contacts[index].name, 16),
                      overflow: TextOverflow.fade,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      checkLength(contacts[index].email, 22),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      checkLength(contacts[index].phone, 16),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        //_showContactPage(contact: contacts[index]);
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          launch("tel: ${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20),
                        ),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  String checkLength(String text, int length) {
    String newText = "";
    if (text != null) {
      if (text.length < length) {
        return text;
      } else {
        for (int i = 0; i < length; i++) {
          newText += text[i];
          print(text[i]);
        }
        newText += "...";
        print(newText);
        return newText;
      }
    }
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactPage(
            contact: contact,
          ),
        ));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });

        break;
    }
    setState(() {});
  }
}
