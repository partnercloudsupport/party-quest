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
  new IntroItem(title: 'Modern day city life full of derelicts and suits.', category: 'City Quest', imageUrl: 'assets/images/city_bg.jpg',),
  new IntroItem(title: 'Dragons, dwarves, goblins, and long white beards.', category: 'Fantasy Quest', imageUrl: 'assets/images/fantasy_bg.jpg',),
  new IntroItem(title: 'The future never looked so bleak and full of opportunity.', category: 'Cyberpunk Quest', imageUrl: 'assets/images/cyberpunk_bg.jpg',),
];


class Quest {
  final String name;
  final String roomCode;
  final String playerNames;
  final String icon;
  final String background;

  Quest(this.name, this.roomCode, this.playerNames, this.icon, this.background);

  Quest.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        roomCode = json['roomCode'],
        playerNames = json['playerNames'],
        icon = json['icon'],
        background = json['background'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'roomCode': roomCode,
        'playerNames': playerNames,
        'icon': icon,
        'background': background
      };
}