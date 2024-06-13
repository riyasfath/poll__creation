class PollItem {
  String? id;  // Make this nullable
  final String question;
  final List<String> options;
  final Map<String, int> votes;
  bool allowMultipleAnswers;

  PollItem({
    this.id,  // id is optional
    required this.question,
    required this.options,
    Map<String, int>? votes,
    required this.allowMultipleAnswers,
  }) : votes = votes ?? {};

  void voteForOption(String option) {
    votes[option] = (votes[option] ?? 0) + 1;
  }

  @override
  String toString() {
    return '$id|$question|${options.join(',')}|${votes.entries.map((e) => '${e.key}:${e.value}').join(',')}';
  }

  static PollItem fromString(String data) {
    final parts = data.split('|');
    final id = parts[0] != 'null' ? parts[0] : null;  // Handle nullable id
    final question = parts[1];
    final options = parts[2].split(',');
    final votes = parts[3].split(',').fold<Map<String, int>>({}, (map, pair) {
      final kv = pair.split(':');
      map[kv[0]] = int.parse(kv[1]);
      return map;
    });

    return PollItem(
      id: id,
      question: question,
      options: options,
      votes: votes,
      allowMultipleAnswers: false,
    );
  }

  factory PollItem.fromMap(Map<String, dynamic> map, String id) {
    return PollItem(
      id: id,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      votes: Map<String, int>.from(map['votes'] as Map),
      allowMultipleAnswers: map['allowMultipleAnswers'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'votes': votes,
      'allowMultipleAnswers': allowMultipleAnswers,
    };
  }
}
