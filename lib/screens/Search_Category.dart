import 'dart:convert';
import 'package:aaram_bd/config.dart';
import 'package:aaram_bd/screens/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchCategory extends StatefulWidget {
  final String categoryType; // Add a categoryType parameter

  // Constructor
  const SearchCategory({Key? key, required this.categoryType}) : super(key: key);

  @override
  _SearchCategoryState createState() => _SearchCategoryState();
}

class _SearchCategoryState extends State<SearchCategory> {
  TextEditingController searchBarController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filteredCategories = [];

  // Mapping first letters to gradients
  final Map<String, List<Color>> letterToGradient = {
  'A': [Colors.pinkAccent, Colors.orangeAccent],
  'B': [Colors.lightBlueAccent, Colors.cyanAccent],
  'C': [Colors.lightGreenAccent, Colors.limeAccent],
  'D': [Colors.purpleAccent, Colors.deepPurpleAccent],
  'E': [Colors.yellowAccent, Colors.amberAccent],
  'F': [Colors.redAccent, Colors.deepOrangeAccent],
  'G': [Colors.tealAccent, Colors.greenAccent],
  'H': [Colors.indigoAccent, Colors.blueAccent],
  'I': [Colors.deepOrangeAccent, Colors.orangeAccent],
  'J': [Colors.limeAccent, Colors.lightGreenAccent],
  'K': [Colors.blueGrey, Colors.grey],
  'L': [Colors.pinkAccent, Colors.redAccent],
  'M': [Colors.orangeAccent, Colors.deepOrangeAccent],
  'N': [Colors.greenAccent, Colors.tealAccent],
  'O': [Colors.amberAccent, Colors.yellowAccent],
  'P': [Colors.purpleAccent, Colors.pinkAccent],
  'Q': [Colors.blueAccent, Colors.indigoAccent],
  'R': [Colors.cyanAccent, Colors.lightBlueAccent],
  'S': [Colors.limeAccent, Colors.lightGreenAccent],
  'T': [Colors.redAccent, Colors.pinkAccent],
  'U': [Colors.orangeAccent, Colors.amberAccent],
  'V': [Colors.tealAccent, Colors.cyanAccent],
  'W': [Colors.yellowAccent, Colors.limeAccent],
  'X': [Colors.blueAccent, Colors.indigoAccent],
  'Y': [Colors.pinkAccent, Colors.purpleAccent],
  'Z': [Colors.deepPurpleAccent, Colors.purpleAccent],
};


  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$host/get_categories_name?type=${widget.categoryType}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = List<Map<String, dynamic>>.from(data['categories']);
        filteredCategories = categories; // Initially show all categories
      });
    } else {
      print('Failed to load categories');
    }
  }

  void filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCategories = categories;
      } else {
        // Filter categories by starting characters matching input
        filteredCategories = categories
            .where((category) =>
                category['cat_name'].toLowerCase().startsWith(query.toLowerCase()))
            .toList();

        // Sort filtered categories alphabetically based on user input
        filteredCategories.sort((a, b) =>
            a['cat_name'].toLowerCase().compareTo(b['cat_name'].toLowerCase()));
      }
    });
  }

  // Function to get the gradient for a category based on its starting letter
  List<Color> getGradientForCategory(String catName) {
    String firstLetter = catName[0].toUpperCase();
    return letterToGradient[firstLetter] ??
        [Colors.grey, Colors.blueGrey]; // Default gradient for unmatched letters
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      child: SearchAnchor(
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: searchBarController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            onTap: () {
              controller.openView();
            },
            onChanged: (query) {
              filterCategories(query); // Dynamically filter categories as user types
              controller.openView();
            },
            leading: const Icon(Icons.search),
          );
        },
        suggestionsBuilder: (BuildContext context, SearchController controller) {
          return filteredCategories.isNotEmpty
              ? List.generate(filteredCategories.length, (index) {
                  final item = filteredCategories[index];
                  final gradientColors = getGradientForCategory(item['cat_name']); // Get gradient

                  return Card(
  elevation: 3,
  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(40),
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(40), // Ensure rounded corners
      gradient: LinearGradient(
        colors: gradientColors, // Apply gradient based on first letter
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradientColors, // Apply gradient for avatar based on first letter
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white, // Border color for avatar
            width: 3, // Border width
          ),
        ),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.transparent,
          child: Text(
            item['cat_name'][0].toUpperCase(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        item['cat_name'],
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: Colors.black, // White text for contrast against gradient background
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoriteScreen(
              categoryName: item['cat_name'],
              cat_id: item['cat_id'].toString(),
            ),
          ),
        );
      },
    ),
  ),
);

                })
              : [
                  ListTile(
                    title: Text("No categories found"),
                  )
                ];
        },
      ),
    );
  }
}
