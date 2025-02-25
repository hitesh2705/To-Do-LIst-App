import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for navigation
import 'package:random_string/random_string.dart'; // Import for generating random strings (task IDs)// Import for the Calendar screen // Import for the Dark Mode screen
import 'package:to_do_list/LogOut.dart'; // Import for the Log Out screen
import 'package:to_do_list/Setting.dart'; // Import for the Setting screen
import 'package:to_do_list/db_services/database.dart'; // Import for database services

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Category selection flags
  bool personal = true, college = false, shopping = false;

  // Text editing controllers for input fields
  TextEditingController todoController = TextEditingController();
  TextEditingController todoDetailController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  // Stream to listen for changes in the database
  Stream<QuerySnapshot>? todoStream;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Function to load tasks based on the selected category
  Future<void> loadTasks() async {
    todoStream = await DatabaseServices().getTask(
        personal ? "Personal" : college ? "College" : "Shopping");
    setState(() {});
  }

  // Function to change the selected category and reload tasks
  void changeCategory(String category) async {
    setState(() {
      personal = category == "Personal";
      college = category == "College";
      shopping = category == "Shopping";
    });
    await loadTasks();
  }

  // Widget to build the list of tasks
  Widget buildTaskList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: todoStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tasks found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot docSnap = snapshot.data!.docs[index];

              return Card(
                elevation: 2,
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Due Date: ${docSnap["date"]}",
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        docSnap["work"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    docSnap["detail"],
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: docSnap["Yes"],
                        activeColor: Colors.green,
                        onChanged: (newValue) async {
                          try {
                            await FirebaseFirestore.instance
                                .collection(personal
                                ? "Personal"
                                : college
                                ? "College"
                                : "Shopping")
                                .doc(docSnap["id"])
                                .update({"Yes": newValue});
                            setState(() {});
                          } catch (e) {
                            print("Error updating 'Yes' field: $e");
                            // Optionally show an error message to the user.
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outlined, color: Colors.redAccent),
                        onPressed: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text("Confirm Delete",style:TextStyle(color: Colors.blueAccent),),
                              content:
                              Text("Are you sure you want to delete this task?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text("Cancel",
                                      style: TextStyle(color: Colors.green)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Delete",
                                      style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            try {
                              await FirebaseFirestore.instance
                                  .collection(personal
                                  ? "Personal"
                                  : college
                                  ? "College"
                                  : "Shopping")
                                  .doc(docSnap["id"])
                                  .delete();
                            } catch (e) {
                              print("Error deleting task: $e");
                              // Optionally show an error message to the user.
                            }
                          }
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            openEditBox(docSnap);
                          },
                          icon: Icon(Icons.edit)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to open the dialog for adding a new task
  Future<void> openTaskDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Spacer(),
                IconButton(
                  icon: Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text("Add To-Do Task",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextField(
              controller: todoController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: todoDetailController,
              decoration: InputDecoration(
                labelText: 'Task Detail',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.date_range_outlined),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      dateController.text = formattedDate;

                      Navigator.pop(context);
                      openTaskDialog();
                    }
                  },
                ),
                labelText: 'Select Due Date',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: () async {
                  if (todoController.text.isNotEmpty) {
                    String id = randomAlphaNumeric(10);
                    Map<String, dynamic> userTodo = {
                      "work": todoController.text,
                      "detail": todoDetailController.text,
                      "date": dateController.text,
                      "id": id,
                      "Yes": false,
                    };

                    String category = personal
                        ? "Personal"
                        : college
                        ? "College"
                        : "Shopping";

                    try {
                      await DatabaseServices().addPersonalTask(userTodo, id);
                      if (personal) {
                        await DatabaseServices().addPersonalTask(userTodo, id);
                      } else if (college) {
                        await DatabaseServices().addCollegeTask(userTodo, id);
                      } else {
                        await DatabaseServices().addShoppingTask(userTodo, id);
                      }
                    } catch (e) {
                      print("Error adding task: $e");
                      // Optionally show an error message to the user.
                    }
                    todoController.clear();
                    todoDetailController.clear();
                    dateController.clear();
                    Navigator.pop(context);
                    loadTasks();
                  }
                },
                child: Text("Add Task",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build category selection buttons
  Widget buildCategoryButton(String category, Color color) {
    bool isSelected = (category == "Personal" && personal) ||
        (category == "College" && college) ||
        (category == "Shopping" && shopping);

    return GestureDetector(
      onTap: () => changeCategory(category),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(category,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey[800]))),
    );
  }

  // Function to open the dialog for editing an existing task
  Future openEditBox(DocumentSnapshot docsnap) {
    TextEditingController titleController =
    TextEditingController(text: docsnap["work"]);
    TextEditingController detailController =
    TextEditingController(text: docsnap["detail"]);
    TextEditingController editDateController =
    TextEditingController(text: docsnap["date"]);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit Task',
              style: TextStyle(color: Colors.blueAccent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: detailController,
                  decoration: InputDecoration(labelText: 'Detail'),
                ),
                TextField(
                  controller: editDateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      editDateController.text = formattedDate;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update',
                  style: TextStyle(color: Colors.green)),
              onPressed: () async {
                String category = personal
                    ? "Personal"
                    : college
                    ? "College"
                    : "Shopping";

                try {
                  await DatabaseServices().updateTask(
                    category,
                    docsnap["id"],
                    titleController.text,
                    detailController.text,
                    editDateController.text,
                  );
                  Navigator.of(context).pop();
                  loadTasks();
                } catch (e) {
                  print("Error updating task: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                accountName:null,
                accountEmail: null),
            ListTile(
                leading: Icon(Icons.settings, color: Colors.blueAccent),
                title: Text('Settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Get.to(() => SettingWidgets())),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.blueAccent,
              ),
              title: Text('Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(() => LogOutWidget()),
            ),
            SizedBox(height: 515),
            Divider(),
            Center(child: Text("Version 1.0.0"))
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskDialog,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("To-Do App",
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCategoryButton(
                      "Personal", Colors.lightBlueAccent.shade100),
                  buildCategoryButton("College", Colors.orangeAccent),
                  buildCategoryButton("Shopping", Colors.green.shade400),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildTaskList(),
          ],
        ),
      ),
    );
  }
}