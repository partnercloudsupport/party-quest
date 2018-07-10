class IntroItem {
  IntroItem({
    this.title,
    this.category,
    this.imageUrl,
  });

  final String title;
  final String category;
  final String imageUrl;
}

final sampleItems = <IntroItem>[
  new IntroItem(title: 'Modern day city life full of derelicts and suits.', category: 'CITY QUEST', imageUrl: 'assets/images/city_bg.jpg',),
  new IntroItem(title: 'Dragons, dwarves, goblins, and long white beards.', category: 'FANTASY QUEST', imageUrl: 'assets/images/fantasy_bg.jpg',),
  new IntroItem(title: 'The future never looked so bleak and full of opportunity.', category: 'CYBERPUNK QUEST', imageUrl: 'assets/images/cyberpunk_bg.jpg',),
];