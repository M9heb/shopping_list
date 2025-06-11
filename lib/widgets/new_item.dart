import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  void _saveItem() async {
    setState(() {
      _isSending = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
          'flutter-grocery-list-d5753-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title
          },
        ),
      );
      if (response.statusCode == 200) {
        if (context.mounted) {
          final Map<String, dynamic> resposeData = json.decode(response.body);
          Navigator.of(context).pop(
            GroceryItem(
                id: resposeData['name'],
                name: _enteredName,
                quantity: _enteredQuantity,
                category: _selectedCategory),
          );
          setState(() {
            _isSending = false;
          });
        }
      } else {
        return;
      }

      // Navigator.of(context).pop(
      //   GroceryItem(
      //       id: DateTime.now().toString(),
      //       name: _enteredName,
      //       quantity: _enteredQuantity,
      //       category: _selectedCategory),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text("Name")),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return "Must be between 1 and 50 characters.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            label: Text("Quantity"),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialValue: _enteredQuantity.toString(),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return "Must be a valid positive number.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredQuantity = int.parse(value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: _selectedCategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(spacing: 8, children: [
                                      CircleAvatar(
                                        radius: 8,
                                        backgroundColor: category.value.color,
                                      ),
                                      Text(
                                        category.value.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface),
                                      ),
                                    ]))
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            }),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                spacing: 16,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isSending
                          ? null
                          : _saveItem, // Disable while sending
                      icon: _isSending
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSending ? "Saving..." : "Save item",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                              Navigator.pop(context);
                            },
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
