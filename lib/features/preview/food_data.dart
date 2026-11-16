class Food {
  final String name, image, time, rating, description, category;
  final int price;
  const Food(
    this.name,
    this.image,
    this.price,
    this.rating,
    this.time,
    this.description,
    this.category,
  );
}

const sampleFoods = [
  Food(
    'Margherita Pizza',
    'margherita.jpg',
    220,
    '4.8',
    '20 dk',
    'Domates sosu, mozzarella ve taze fesleğen.',
    'Pizza',
  ),
  Food(
    'Cheeseburger',
    'cheeseburger.jpg',
    190,
    '4.7',
    '25 dk',
    'Izgara köfte, cheddar ve taze sebzeler.',
    'Burger',
  ),
  Food(
    'Tavuklu Bowl',
    'bowl.jpg',
    175,
    '4.6',
    '15 dk',
    'Izgara tavuk, taze yeşillikler ve pirinç.',
    'Bowl',
  ),
  Food(
    'Pepperoni Pizza',
    'pepperoni.jpg',
    245,
    '4.9',
    '25 dk',
    'Pepperoni, mozzarella ve özel sos.',
    'Pizza',
  ),
  Food(
    'Çıtır Tavuk Menü',
    'chicken.jpg',
    210,
    '4.5',
    '20 dk',
    'Çıtır tavuk, patates ve özel sos.',
    'Tavuk',
  ),
  Food(
    'Sebzeli Makarna',
    'pasta.jpg',
    160,
    '4.4',
    '18 dk',
    'Mevsim sebzeleri ve domates sosu.',
    'Makarna',
  ),
];
