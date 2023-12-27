import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  final String name;
  final int points;

  Tag({required this.name, required this.points});
}

class TagCreatorPage extends StatefulWidget {
  @override
  _TagCreatorPageState createState() => _TagCreatorPageState();
}

enum SelectedTagsMode {
  UpdateTags,
  DeleteTags,
}

class _TagCreatorPageState extends State<TagCreatorPage> {
  List<String> selectedTags = [];
  List<Tag> selectedTagObjects = [];
  Map<String, Color> tagColors = {};

  TextEditingController tagController = TextEditingController();
  TextEditingController pointsController = TextEditingController();

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  SelectedTagsMode selectedMode = SelectedTagsMode.UpdateTags;

  Future<void> addToFirestore() async {
    CollectionReference batches =
        FirebaseFirestore.instance.collection('creditpoints');
    Map<String, dynamic> tagsMap = {};

    // Retrieve existing tags from Firestore
    DocumentSnapshot doc = await batches.doc('creditpoints').get();
    if (doc.exists) {
      tagsMap = (doc.data() as Map<String, dynamic>?)?['tags'] ?? {};
    }

    // Add new tags to the map
    for (Tag tag in selectedTagObjects) {
      tagsMap[tag.name] = tag.points;
    }

    // Update the document with the merged tags
    await batches.doc('creditpoints').set({
      'tags': tagsMap,
    });

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Uploaded to Firestore'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear the cards
    clearCards();
  }

  void clearCards() {
    setState(() {
      selectedTags.clear();
      selectedTagObjects.clear();
    });
  }

  void selectTag(String tagName, String pointsString) {
    setState(() {
      int points = int.tryParse(pointsString) ?? 0;

      selectedTags.add(tagName);
      tagColors.putIfAbsent(tagName, () => _getRandomColor());
      selectedTagObjects.add(Tag(name: tagName, points: points));
    });
  }

  void removeTag(String tagName) async {
    if (selectedMode == SelectedTagsMode.DeleteTags) {
      try {
        CollectionReference batches =
            FirebaseFirestore.instance.collection('creditpoints');

        // Fetch the document containing tags
        DocumentSnapshot doc = await batches.doc('creditpoints').get();

        if (doc.exists) {
          Map<String, dynamic> tagsMap =
              (doc.data() as Map<String, dynamic>?)?['tags'] ?? {};

          // Remove the tag from the map
          tagsMap.remove(tagName);

          // Update the document with the modified tags map
          await batches.doc('creditpoints').update({
            'tags': tagsMap,
          });
        }
      } catch (e) {
        print('Error removing tag from Firestore: $e');
        // Handle errors as needed
        return; // Don't proceed with the local state update if there's an error
      }
    }

    // Update the local state after successful Firestore operation
    setState(() {
      selectedTags.remove(tagName);
      selectedTagObjects.removeWhere((tag) => tag.name == tagName);
    });
  }

  Widget buildSelectedTags() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Tags and Points:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tagController,
                  decoration: InputDecoration(
                    labelText: 'Tag',
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: pointsController,
                  decoration: InputDecoration(
                    labelText: 'Points',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  String tagName = tagController.text;
                  String points = pointsController.text;

                  if (tagName.isNotEmpty && points.isNotEmpty) {
                    selectTag(tagName, points);
                    tagController.clear();
                    pointsController.clear();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Selected Tags:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          // Dropdown button to select mode
          DropdownButton<SelectedTagsMode>(
            value: selectedMode,
            onChanged: (mode) {
              setState(() {
                selectedMode = mode!;
              });
            },
            items: [
              DropdownMenuItem(
                value: SelectedTagsMode.UpdateTags,
                child: Text('Update Tags'),
              ),
              DropdownMenuItem(
                value: SelectedTagsMode.DeleteTags,
                child: Text('Delete Tags'),
              ),
            ],
          ),

          // Content based on the selected mode
          if (selectedMode == SelectedTagsMode.UpdateTags)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: selectedTagObjects.map((tag) {
                return Card(
                  child: ListTile(
                    title: Text(
                      tag.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Points: ${tag.points}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        removeTag(tag.name);
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                );
              }).toList(),
            ),

          if (selectedMode == SelectedTagsMode.DeleteTags)
            // Fetch and display tags as cards
            FutureBuilder<List<Tag>>(
              future: fetchTagsFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No tags available.');
                } else {
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: snapshot.data!.map((tag) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            tag.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Points: ${tag.points}',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              // Uncomment the next line to enable tag deletion
                              removeTag(tag.name);
                            },
                            child: Icon(Icons.close),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),

          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (selectedMode == SelectedTagsMode.UpdateTags) {
                  await addToFirestore();
                } else if (selectedMode == SelectedTagsMode.DeleteTags) {
                  // Add logic for deleting tags here
                }
              },
              child: Text('Save to Firestore'),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Tag>> fetchTagsFromFirestore() async {
    CollectionReference batches =
        FirebaseFirestore.instance.collection('creditpoints');
    List<Tag> tags = [];

    try {
      // Fetch the document containing tags
      DocumentSnapshot doc = await batches.doc('creditpoints').get();

      if (doc.exists) {
        Map<String, dynamic> tagsMap =
            (doc.data() as Map<String, dynamic>?)?['tags'] ?? {};

        // Convert tags from the map to a list of Tag objects
        tagsMap.forEach((tagName, points) {
          tags.add(Tag(name: tagName, points: points));
        });
      }
    } catch (e) {
      print('Error fetching tags: $e');
      // Handle errors as needed
    }

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(child: buildSelectedTags())),
    );
  }
}
