import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQLite Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _data = [];
  bool _isloading = true;
  void _refreshdata() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _data = data;
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshdata();
  }

  final TextEditingController _tittleCantroller = TextEditingController();
  final TextEditingController _descriptionCantroller = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingData = _data.firstWhere((element) => element['id'] == id);
      _tittleCantroller.text = existingData['tittle'];
      _descriptionCantroller.text = existingData['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    decoration: const InputDecoration(hintText: 'Tittle'),
                    controller: _tittleCantroller,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: const InputDecoration(hintText: 'Description'),
                    controller: _descriptionCantroller,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        _tittleCantroller.text = '';
                        _descriptionCantroller.text = '';
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    ),
                  )
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _tittleCantroller.text, _descriptionCantroller.text);
    _refreshdata();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _tittleCantroller.text, _descriptionCantroller.text);
    _refreshdata();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sucessfully deleted a data!')));
    _refreshdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter SQLite Tutorial"),
      ),
      body: _isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _data.isNotEmpty
              ? ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) => Card(
                        color: Colors.indigo[100],
                        margin: const EdgeInsets.all(15),
                        child: ListTile(
                          title: Text(
                            _data[index]['title'],
                          ),
                          subtitle: Text(_data[index]['description']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(children: [
                              IconButton(
                                onPressed: () => _showForm(_data[index]['id']),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                  onPressed: () =>
                                      _deleteItem(_data[index]['id']),
                                  icon: const Icon(Icons.delete)),
                            ]),
                          ),
                        ),
                      ))
              : const SizedBox(
                  child: Center(
                    child: Text('No data Found'),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
