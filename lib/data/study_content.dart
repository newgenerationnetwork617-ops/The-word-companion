class StudyGuide {
  const StudyGuide({
    required this.understand,
    required this.context,
    required this.apply,
    required this.connections,
    required this.reflection,
  });

  final String understand;
  final String context;
  final String apply;
  final List<StudyConnection> connections;
  final List<String> reflection;
}

class StudyConnection {
  const StudyConnection(this.reference, this.reason);
  final String reference;
  final String reason;
}

/// Editorial study notes written for this app. These are explanations,
/// not replacement Scripture translations or claims of exhaustive commentary.
const Map<String, StudyGuide> studyGuides = {
  'John 3:16': StudyGuide(
    understand: 'This verse presents God’s love as active and generous: God gives the Son so that people who trust in him may receive eternal life. The emphasis is on God’s initiative and the invitation to believe.',
    context: 'Jesus is speaking with Nicodemus, a religious teacher who has come to him at night. The conversation is about being born from above and entering God’s kingdom. The surrounding verses explain that the Son is sent to save, not to condemn the world.',
    apply: 'Receive God’s love with trust rather than treating faith as a way to earn acceptance. Let the value God places on people shape the way you treat others with patience, honesty and compassion.',
    connections: [
      StudyConnection('Romans 5:8', 'It also describes God demonstrating love while people are still sinners.'),
      StudyConnection('1 John 4:9–10', 'It explains God’s love through the sending of his Son.'),
      StudyConnection('John 1:12', 'It connects receiving Christ with becoming children of God.'),
    ],
    reflection: [
      'What does this verse show about who takes the first step in salvation?',
      'How can remembering God’s love change the way you treat someone today?',
    ],
  ),
  'Psalm 23:1': StudyGuide(
    understand: 'David describes the Lord as a shepherd: one who guides, protects and provides. The image expresses trust in God’s care rather than a promise that life will never include difficulty.',
    context: 'Psalm 23 is a song of confidence. Its shepherd image develops through the following verses into pictures of guidance, safety and hospitality, including in the presence of danger.',
    apply: 'Bring decisions and worries to God, seek wise guidance, and practise contentment. Trust does not remove every challenge, but it gives a reason not to face challenges as though you are abandoned.',
    connections: [
      StudyConnection('John 10:11', 'Jesus uses the shepherd image to describe his care and self-giving.'),
      StudyConnection('Isaiah 40:11', 'God is pictured gathering and gently leading his flock.'),
      StudyConnection('Ezekiel 34:11–16', 'God promises to seek, care for and guide his scattered sheep.'),
    ],
    reflection: [
      'Which part of the shepherd picture do you most need to remember right now?',
      'What is one decision in which you can seek God’s guidance?',
    ],
  ),
  'Romans 8:28': StudyGuide(
    understand: 'Paul assures believers that God is at work for good in the lives of those who love him and are called according to his purpose. It does not say that every event is good; it points to God’s ability to work amid every circumstance.',
    context: 'Romans 8 speaks about life in the Spirit, suffering, hope and the assurance of God’s love. The next verses describe God’s purpose of shaping believers to become like Christ.',
    apply: 'Avoid calling painful or unfair situations good. Instead, look for faithful next steps, ask for support when needed, and hold on to the wider hope that hardship does not have the final word.',
    connections: [
      StudyConnection('Genesis 50:20', 'Joseph recognises that God brought good out of an intention meant for harm.'),
      StudyConnection('Romans 8:29', 'The following verse explains the good purpose in terms of being shaped to Christ’s likeness.'),
      StudyConnection('James 1:2–4', 'It discusses how tested faith can develop perseverance.'),
    ],
    reflection: [
      'How is God’s purpose in this passage bigger than immediate comfort?',
      'What faithful action can you take while you wait for a difficult situation to change?',
    ],
  ),
  'Proverbs 3:5': StudyGuide(
    understand: 'The proverb calls readers to rely on the Lord wholeheartedly rather than treating their own understanding as the final authority. It encourages humility and trust.',
    context: 'Proverbs 3 is part of wisdom teaching that urges the learner to value instruction, kindness, faithfulness and reverence for God. Verse 6 continues the thought by speaking about acknowledging God in every path.',
    apply: 'Think carefully, seek wise counsel and make responsible plans, while remaining willing to correct your course in light of God’s wisdom. Trust is not an excuse to stop thinking.',
    connections: [
      StudyConnection('Proverbs 3:6', 'The next verse develops the call to acknowledge God in all one’s ways.'),
      StudyConnection('Psalm 37:5', 'It similarly encourages committing one’s way to the Lord and trusting him.'),
      StudyConnection('James 1:5', 'It invites those who lack wisdom to ask God for it.'),
    ],
    reflection: [
      'Where might you be relying only on your own viewpoint?',
      'Who could offer wise, trustworthy counsel about a decision you are facing?',
    ],
  ),
  'Philippians 4:6': StudyGuide(
    understand: 'Paul encourages believers to bring every concern to God through prayer, petition and thanksgiving. The verse invites honest dependence on God rather than pretending that worries do not exist.',
    context: 'Philippians 4 encourages unity, gentleness, rejoicing and steadfastness. Verse 7 follows with the promise of God’s peace guarding hearts and minds in Christ.',
    apply: 'Name your concerns honestly in prayer, include things you are thankful for, and take sensible steps to address what is within your control. Prayer can accompany asking trusted people for help.',
    connections: [
      StudyConnection('1 Peter 5:7', 'It encourages casting anxieties on God because he cares.'),
      StudyConnection('Matthew 6:25–34', 'Jesus teaches his followers not to be consumed by worry, and to seek God’s kingdom.'),
      StudyConnection('Philippians 4:7', 'The next verse describes the peace of God guarding hearts and minds.'),
    ],
    reflection: [
      'What concern can you honestly bring to God today?',
      'What is one thing you can thank God for even while that concern remains?',
    ],
  ),
};
