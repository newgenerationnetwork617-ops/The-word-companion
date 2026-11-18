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
  ),,

  'Matthew 6:33': StudyGuide(
    understand: 'Jesus calls his followers to make God’s kingdom and righteousness their first priority. The promise about daily needs belongs to a teaching that invites trust in the Father rather than anxious obsession with possessions.',
    context: 'Matthew 6:25–34 addresses worry about food, drink and clothing. Jesus points to the Father’s care and contrasts a life ruled by anxiety with a life that seeks God’s reign.',
    apply: 'Let God’s values guide your choices about time, money and relationships. Make responsible plans for daily needs, but do not let the pursuit of them displace faith, justice and care for others.',
    connections: [
      StudyConnection('Matthew 6:25–32', 'The surrounding teaching explains the call to seek God’s kingdom in the context of daily needs.'),
      StudyConnection('Luke 12:31', 'Luke records a parallel invitation to seek the kingdom.'),
      StudyConnection('Colossians 3:1–2', 'It similarly directs attention toward the things above and a life shaped by Christ.'),
    ],
    reflection: ['What currently competes most strongly for first place in your attention?', 'What practical choice could show that God’s values come first this week?'],
  ),
  'Micah 6:8': StudyGuide(
    understand: 'Micah summarises faithful living as practising justice, loving mercy and walking humbly with God. Faith is expressed not only in religious activity but also in how people treat others.',
    context: 'Micah 6 presents a courtroom-like picture in which God reminds Israel of his faithfulness and challenges empty religious performance. Verse 8 answers what the Lord requires.',
    apply: 'Act fairly, show compassion consistently and remain teachable before God. Look for a concrete way to treat someone with dignity, especially where you have influence or responsibility.',
    connections: [
      StudyConnection('Amos 5:24', 'The prophet also insists that justice must become part of public life.'),
      StudyConnection('Matthew 23:23', 'Jesus highlights justice, mercy and faithfulness as weightier matters of the law.'),
      StudyConnection('James 1:27', 'It describes practical care for vulnerable people as part of sincere religion.'),
    ],
    reflection: ['Which of justice, mercy or humility needs more attention in your daily choices?', 'How can your faith become visible through one fair and compassionate action?'],
  ),
  'James 1:5': StudyGuide(
    understand: 'James encourages anyone who lacks wisdom to ask God, who gives generously. Wisdom is more than information; it is the ability to respond faithfully to life and its challenges.',
    context: 'James 1 speaks about trials, perseverance and becoming mature in faith. The invitation to ask for wisdom follows the call to face testing with endurance.',
    apply: 'Pray for wisdom before reacting, consider Scripture carefully and seek advice from mature, trustworthy people. Then be willing to act on what is wise and good.',
    connections: [
      StudyConnection('Proverbs 2:6', 'It identifies the Lord as the source of wisdom and understanding.'),
      StudyConnection('1 Kings 3:9–12', 'Solomon asks God for an understanding heart to lead well.'),
      StudyConnection('James 3:17', 'It describes the character and fruit of wisdom from above.'),
    ],
    reflection: ['Where do you need wisdom rather than simply a quick answer?', 'What would a wise and peaceable response look like in that situation?'],
  ),
  'Ephesians 2:8': StudyGuide(
    understand: 'Paul teaches that salvation is a gift of grace received through faith, not an achievement people can boast about. The verse directs attention away from self-earned status and toward God’s generosity.',
    context: 'Ephesians 2:1–10 describes the movement from spiritual death to life with Christ. Verses 8–9 explain salvation as God’s gift, and verse 10 describes a life of good works prepared by God.',
    apply: 'Approach God with gratitude rather than pride or despair. Let grace encourage humility, and let the following verse motivate you to do good without treating good works as a way to purchase salvation.',
    connections: [
      StudyConnection('Romans 3:23–24', 'It connects universal need with being justified freely by grace.'),
      StudyConnection('Titus 3:5–7', 'It describes salvation as grounded in God’s mercy rather than human deeds.'),
      StudyConnection('Ephesians 2:10', 'The next verse explains that grace leads into a life of good works.'),
    ],
    reflection: ['How does understanding salvation as a gift challenge pride or discouragement?', 'What good work can you do out of gratitude rather than to earn approval?'],
  ),
  'Galatians 5:22': StudyGuide(
    understand: 'Paul describes the fruit produced by the Holy Spirit in a person’s life. Love, joy, peace, patience, kindness, goodness, faithfulness, gentleness and self-control are qualities that grow as believers live by the Spirit.',
    context: 'Galatians 5 contrasts life directed by selfish desires with life guided by the Spirit. The fruit is a unified picture of character, not a checklist for judging other people.',
    apply: 'Choose one quality to practise in a real relationship today. Ask God for help, make room for correction and remember that spiritual growth is a continuing process.',
    connections: [
      StudyConnection('John 15:4–5', 'Jesus teaches that lasting fruit comes from remaining connected to him.'),
      StudyConnection('Colossians 3:12–14', 'It lists virtues believers are to put on, with love binding them together.'),
      StudyConnection('2 Peter 1:5–8', 'It encourages growth in qualities that make faith fruitful.'),
    ],
    reflection: ['Which quality in this list would make the greatest difference in one of your relationships?', 'What small, specific action could help you practise that quality today?'],
  ),
};
