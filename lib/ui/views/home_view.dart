import 'package:flutter/material.dart';
import 'package:cookingapp/ui/views/catagory_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text("What's Cooking?"),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MyHomePage(title: "What's Cooking?")));
                });
              },
            ),
            ListTile(
              title: const Text('Desserts'),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CatagoryPage()));
                });
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              }, suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(5, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              }),
              SizedBox(height: 50),
              InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CatagoryPage()));
                  });
                },
                child: Container(
                  width: 400,
                  height: 150,
                  child: Card(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.network(
                              'https://www.foodandwine.com/thmb/ckc6L6xKox0WfpfO6dMkuVGPQOY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Angel-Food-Cake-with-Three-Berry-Compote-FT-RECIPE0323-541a780b871441e0ab14383ee38acc44.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'DESSERT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40, // Adjust size as needed
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CatagoryPage()));
                  });
                },
                child: Container(
                  width: 400,
                  height: 150,
                  child: Card(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.network(
                              'https://www.southernliving.com/thmb/-_Rri5vav4ttiNj2arDaRNzvG-g=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/27496_MkitEasy_DIGI_44_preview_scale_100_ppi_150_quality_100-cc4c5cc90b124650806f5baa603a4d42.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'APPETIZERS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40, // Adjust size as needed
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              /*InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {},
                child: Container(
                  width: 400,
                  height: 150,
                  child: Card(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Breakfast')),
                  ),
                ),
              ),*/
              
            ],
          ),
        ),
      ),
    );
  }
}
