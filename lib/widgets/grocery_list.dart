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
  var _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
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
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "Failed to get data, please check your internet connection and try again!";
      });
      return;
    }
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
    Widget screenContents = SizedBox(
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
    );
    if (_errorMessage != null && !_isLoading) {
      screenContents = SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage ?? "",
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _loadItems, // Disable while sending
              icon: Icon(Icons.refresh,
                  color: Theme.of(context).colorScheme.onPrimary),
              label: Text(
                "Reload",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_errorMessage == null && _isLoading) {
      screenContents = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      screenContents = ListView.builder(
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
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              trailing: Text("${_groceryItems[index].quantity}"),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: screenContents,
    );
  }
}
