import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/provider/search_provider.dart';
import 'package:skill_swap/screens/other/search_results.dart';
import 'package:skill_swap/utils/extensions.dart';
import 'package:skill_swap/utils/transition.dart';

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            controller: context.read<SearchProvider>().searchController,
            onSubmitted:
                (value) => Navigator.of(context).push(
                  transitionToNextScreen(SearchResults(searchValue: value)),
                ),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Search People by their Skills",
            ),
          ),
          Flexible(
            child: Consumer<SearchProvider>(
              builder: (context, value, child) {
                return ListView.builder(
                  itemCount:
                      value.searchController.text.isEmpty
                          ? value.searchData.length
                          : value.results.length,
                  itemBuilder:
                      (context, index) => searchElement(
                        value.searchController.text.isEmpty
                            ? value.searchData[index]
                            : value.results[index],
                        context,
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget searchElement(String data, BuildContext context) {
    return ListTile(
      shape: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      title: Text(data.capitalize()),
      minTileHeight: 0,
      contentPadding: const EdgeInsets.all(5),
      onTap: () =>Navigator.of(context).push(
                  transitionToNextScreen(SearchResults(searchValue: data)),
                ),
    );
  }
}
