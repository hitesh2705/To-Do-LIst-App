import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
//import 'package:firebase_core/firebase_core.dart'; // No need to import FirebaseCore here

class DatabaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a Personal Task
  Future<void> addPersonalTask(Map<String, dynamic> personalTaskMap, String id) async {
    try {
      await _firestore.collection("Personal").doc(id).set(personalTaskMap);
      print("Personal Task added successfully!");
    } catch (e) {
      print("Error adding Personal Task: $e");
    }
  }

  // Add a College Task
  Future<void> addCollegeTask(Map<String, dynamic> collegeTaskMap, String id) async {
    try {
      await _firestore.collection("College").doc(id).set(collegeTaskMap);
      print("College Task added successfully!");
    } catch (e) {
      print("Error adding College Task: $e");
    }
  }

  // Add an Shopping Task
  Future<void> addShoppingTask(Map<String, dynamic> ShoppingTaskMap, String id) async {
    try {
      await _firestore.collection("Shopping").doc(id).set(ShoppingTaskMap);
      print("Shopping Task added successfully!");
    } catch (e) {
      print("Error adding Shopping Task: $e");
    }
  }

  // Get Tasks based on Category (Personal, College, Shopping)
  Stream<QuerySnapshot> getTask(String task) {
    return _firestore.collection(task).snapshots();
  }

  // Update Task (the new method you need)
  Future<void> updateTask(
      String category, String id, String work, String detail, String date) async {
    try {
      await _firestore.collection(category).doc(id).update({
        'work': work,
        'detail': detail,
        'date': date,
      });
      print("Task Updated successfully!");
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  // Tick Method (Mark as Complete)
  Future<void> tickMethod(String id, String task) async {
    try {
      await _firestore.collection(task).doc(id).update({"Yes": true});
      print("Task marked as complete!");
    } catch (e) {
      print("Error marking task as complete: $e");
    }
  }

  // Remove Method (Delete Task)
  Future<void> removeMethod(String id, String task) async {
    try {
      await _firestore.collection(task).doc(id).delete();
      print("Task deleted successfully!");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
}