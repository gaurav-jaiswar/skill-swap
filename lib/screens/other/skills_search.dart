import 'package:flutter/material.dart';
import 'package:skill_swap/utils/constants.dart';
import 'package:skill_swap/utils/extensions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.searchData});

  final List searchData;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController controller = TextEditingController();
  List results = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(search);
  }

  void search() {
    results = [];
    results.addAll(
      widget.searchData.where(
        (item) => item.contains(controller.text.toString()),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Skill",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: mediumLarge),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              controller: controller,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: "Skills",
              ),
            ),
            if (controller.text.isNotEmpty && results.isEmpty)
              searchElement(controller.text),
            Expanded(
              child: ListView.builder(
                itemCount:
                    controller.text.isEmpty
                        ? widget.searchData.length
                        : results.length,
                itemBuilder:
                    (context, index) => searchElement(
                      controller.text.isEmpty
                          ? widget.searchData[index]
                          : results[index],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchElement(String data) {
    return ListTile(
      shape: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      title: Text(data.capitalize()),
      minTileHeight: 0,
      contentPadding: const EdgeInsets.all(5),
      onTap: () => Navigator.of(context).pop(data.toLowerCase()),
    );
  }
}
