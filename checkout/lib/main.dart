import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class ListItem extends StatelessWidget {
  final IconData iconData;
  final String itemName;
  final String price;
  final int quantity;
  final Function(int) onChanged;

  const ListItem({
    super.key,
    required this.iconData,
    required this.itemName,
    required this.price,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(itemName),
      subtitle: Text(price),
      trailing: ActionItem(
        quantity: quantity,
        onChanged: onChanged,
      ),
    );
  }
}

class ActionItem extends StatefulWidget {
  final int quantity;
  final Function(int) onChanged;

  const ActionItem({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  State<ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<ActionItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("${widget.quantity}"),
        IconButton(
          onPressed: () {
            widget.onChanged(widget.quantity + 1);
          },
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () {
            if (widget.quantity > 0) {
              widget.onChanged(widget.quantity - 1);
            }
          },
          icon: const Icon(Icons.remove),
        ),
      ],
    );
  }
}

class TipSelector extends StatefulWidget {
  const TipSelector({super.key});

  @override
  State<TipSelector> createState() => _TipSelectorState();
}

class _TipSelectorState extends State<TipSelector> {
  bool addTip = false;
  int selectedTip = 10;
  List<int> tipOptions = [10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Add a tip?"),
          value: addTip,
          onChanged: (value) {
            setState(() {
              addTip = value;
            });
          },
        ),
        if (addTip)
          Wrap(
            spacing: 8,
            children: tipOptions.map((tip) {
              return ChoiceChip(
                label: Text("$tip%"),
                selected: selectedTip == tip,
                onSelected: (selected) {
                  setState(() {
                    selectedTip = tip;
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}

class ConfirmSelection extends StatelessWidget {
  const ConfirmSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Order Confirmed"),
              content: const Text("Your checkout order has been submitted"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Dismiss"),
                ),
              ],
            );
          },
        );
      },
      child: const Text("Confirm Order"),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'AU Coffee Shop Checkout'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pizzaQty = 0;
  int coffeeQty = 0;
  int iceCreamQty = 0;
  int wineQty = 0;

  double get total {
    return (pizzaQty * 15.99) +
        (coffeeQty * 5.99) +
        (iceCreamQty * 7.99) +
        (wineQty * 20.99);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            Card(
              child: Column(
                children: [
                   Image.asset(
                     "assets/images/aulogo.png",
                    height: 150,
                     width: 150,
                  ),
                  ListItem(
                    iconData: Icons.local_pizza,
                    itemName: "Pizza",
                    price: "15.99",
                    quantity: pizzaQty,
                    onChanged: (val) {
                      setState(() {
                        pizzaQty = val;
                      });
                    },
                  ),
                  ListItem(
                    iconData: Icons.local_cafe,
                    itemName: "Coffee",
                    price: "5.99",
                    quantity: coffeeQty,
                    onChanged: (val) {
                      setState(() {
                        coffeeQty = val;
                      });
                    },
                  ),
                  ListItem(
                    iconData: Icons.icecream,
                    itemName: "Ice Cream",
                    price: "7.99",
                    quantity: iceCreamQty,
                    onChanged: (val) {
                      setState(() {
                        iceCreamQty = val;
                      });
                    },
                  ),
                  ListItem(
                    iconData: Icons.wine_bar,
                    itemName: "Wine",
                    price: "20.99",
                    quantity: wineQty,
                    onChanged: (val) {
                      setState(() {
                        wineQty = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const TipSelector(),
            const SizedBox(height: 15),
            const ConfirmSelection(),
          ],
        ),
      ),
    );
  }
}