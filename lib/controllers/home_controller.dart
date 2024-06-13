import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poll_item_model.dart';
import '../services/create_poll_popup.dart';
import '../views/view_votes_screen.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _pollsCollection = FirebaseFirestore.instance.collection('polls');
  RxList<PollItem> polls = <PollItem>[].obs; // List to store all polls
  Rx<String?> selectedOption = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadPolls();
  }

  void showCreatePollPopup(BuildContext context) async {
    CreatePollBottomSheet(onPollCreated: (poll) async {
      DocumentReference docRef = await _pollsCollection.add(poll.toMap());
      poll.id = docRef.id;  // Set the document ID
      PollItem newPoll = PollItem(
        id: docRef.id,
        question: poll.question,
        options: poll.options,
        votes: poll.votes,
        allowMultipleAnswers: poll.allowMultipleAnswers,
      );
      polls.add(newPoll);
      savePolls();
    }).show(context);
  }

  void voteForOption(String option, int pollIndex) {
    if (polls.length > pollIndex && polls[pollIndex] != null) {
      selectedOption.value = option;
      polls[pollIndex].voteForOption(option);
      savePolls();
    }
  }

  Future<void> createPoll(PollItem poll) async {
    try {
      DocumentReference docRef = await _pollsCollection.add(poll.toMap());
      poll.id = docRef.id;
    } catch (e) {
      print('Error creating poll: $e');
    }
  }

  Future<void> savePolls() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedPolls = polls.map((poll) => poll.toString()).toList();
    await prefs.setStringList('polls', encodedPolls); // Save all polls as a list
  }

  void viewVotes(int pollIndex) {
    if (polls.length > pollIndex && polls[pollIndex] != null) {
      Get.to(() => ViewVotesPage(polls[pollIndex])); // Pass the selected poll object
    } else {
      Get.snackbar('Error', 'No poll available');
    }
  }

  Future<void> loadPolls() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedPolls = prefs.getStringList('polls');
    if (encodedPolls != null) {
      polls.value = encodedPolls.map((data) => PollItem.fromString(data)).toList();
    }

    // Load from Firestore as well
    try {
      QuerySnapshot querySnapshot = await _pollsCollection.get();
      polls.value = querySnapshot.docs.map((doc) {
        return PollItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading polls from Firestore: $e');
    }
  }

  Future<void> deletePoll(int pollIndex) async {
    if (polls.length > pollIndex && polls[pollIndex] != null) {
      String? pollId = polls[pollIndex].id;
      try {
        if (pollId != null) {
          await _pollsCollection.doc(pollId).delete();
        }
        polls.removeAt(pollIndex);
        savePolls();
      } catch (e) {
        print('Error deleting poll: $e');
      }
    }
  }
}
