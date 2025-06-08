import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 12,
              backgroundColor: groceryItems[index].category.color,
            ),
            title: Text(
              groceryItems[index].name,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            trailing: Text("${groceryItems[index].quantity}"),
          );
        },
        // children: [
        //   ListTile(
        //     leading: CircleAvatar(
        //       radius: 16,
        //       backgroundColor: Colors.cyan,
        //     ),
        //     title: Text(
        //       "Milk",
        //       style: Theme.of(context)
        //           .textTheme
        //           .bodyLarge!
        //           .copyWith(color: Theme.of(context).colorScheme.surface),
        //     ),
        //     trailing: Text("1"),
        //   ),
        //   ListTile(
        //     leading: CircleAvatar(
        //       radius: 16,
        //       backgroundColor: Colors.lightGreen,
        //     ),
        //     title: Text(
        //       "Beef Steak",
        //       style: Theme.of(context)
        //           .textTheme
        //           .bodyLarge!
        //           .copyWith(color: Theme.of(context).colorScheme.surface),
        //     ),
        //     trailing: Text("1"),
        //   ),
        //   ListTile(
        //     leading: CircleAvatar(
        //       radius: 16,
        //       backgroundColor: Colors.deepOrangeAccent,
        //     ),
        //     title: Text(
        //       "Milk",
        //       style: Theme.of(context)
        //           .textTheme
        //           .bodyLarge!
        //           .copyWith(color: Theme.of(context).colorScheme.surface),
        //     ),
        //     trailing: Text("1"),
        //   )
        // ],
      ),
    );
  }
}
