import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-grocery-list-d5753-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItemsList = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((categoryItem) =>
              categoryItem.value.title == item.value['category'])
          .value;
      _loadedItemsList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = _loadedItemsList;
    });
  }

  void _addItem() async {
    final addedItem = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return NewItem();
      }),
    );
    // _loadItems();
    if (addedItem != null) {
      setState(() {
        _groceryItems.add(addedItem);
      });
    } else {
      return;
    }
  }

  void _removeItem(groceryItem) {
    setState(() {
      _groceryItems.remove(groceryItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget screenContents = _groceryItems.isEmpty
        ? SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset("assets/empty_list.json"),
                const SizedBox(height: 16),
                const Text(
                  "There's nothing here!",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (ctx, index) {
              return Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: _groceryItems[index].category.color,
                  ),
                  title: Text(
                    _groceryItems[index].name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  trailing: Text("${_groceryItems[index].quantity}"),
                ),
              );
            },
          );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: screenContents,
    );
  }
}
