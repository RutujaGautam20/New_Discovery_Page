import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({Key? key}) : super(key: key);

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  List<Map<String, dynamic>> items = [];
  int page = 1;
  int limit = 10;
  bool isLoading = false;
  bool hasMore = true;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchItems(page, limit);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isLoading && hasMore) {
          fetchItems(page + 1, limit);
        }
      }
    });
  }

  Future<void> fetchItems(int page, int limit) async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final Uri url = Uri.parse(
        'https://api-stg.together.buzz/mocks/discovery?page=$page&limit=$limit');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];

      setState(() {
        items.addAll(data.cast<Map<String, dynamic>>());
        this.page = page;
        isLoading = false;

        if (data.isEmpty) {
          hasMore = false;
        }
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Discovery Page',
          style:
              TextStyle(fontFamily: 'ProtestRevolution', color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length + (hasMore ? 1 : 0),
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index < items.length) {
            return Padding(
              padding:
                  const EdgeInsets.only(left: 2, right: 2, bottom: 8, top: 8),
              child: Card(
                color: Color(0xff6A0000),
                child: ListTile(
                  title: Text(
                    items[index]['title'],
                    style: TextStyle(
                        fontFamily: 'ProtestRevolution', color: Colors.white),
                  ),
                  subtitle: Text(
                    items[index]['description'],
                    style: TextStyle(
                        fontFamily: 'ProtestRevolution', color: Colors.white),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      items[index]['image_url'],
                      height: 50,
                      width: 60,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
        },
      ),
    );
  }
}
