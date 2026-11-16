import 'package:flutter/material.dart';
import 'domain/design_config.dart';
import 'food_data.dart';
export 'food_data.dart';

class _DesignScope extends InheritedWidget {
  final DesignConfig config;
  const _DesignScope({required this.config, required super.child});
  static DesignConfig of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DesignScope>()!.config;
  @override
  bool updateShouldNotify(_DesignScope oldWidget) => oldWidget.config != config;
}

class PhonePreview extends StatelessWidget {
  final DesignConfig? config;
  const PhonePreview({super.key, this.config});
  @override
  Widget build(BuildContext context) {
    final design = config ?? DesignConfig.demo();
    final seed = switch (design[0]) {
      'green' => const Color(0xff39865a),
      'blue' => const Color(0xff3974c8),
      _ => const Color(0xffc85b1b),
    };
    final brightness = switch (design[1]) {
      'dark' => Brightness.dark,
      'system' => MediaQuery.platformBrightnessOf(context),
      _ => Brightness.light,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            constraints.maxWidth.isFinite && constraints.maxWidth < 310
            ? constraints.maxWidth / 310
            : 1.0;
        return SizedBox(
          width: 310 * scale,
          height: 650 * scale,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: 310,
              height: 650,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff242b2a),
                borderRadius: BorderRadius.circular(43),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .18),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: _DesignScope(
                  config: design,
                  child: Theme(
                    data: ThemeData(
                      useMaterial3: true,
                      colorScheme: scheme,
                      scaffoldBackgroundColor: scheme.surface,
                      fontFamily: 'sans-serif',
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1)),
                      child: Navigator(
                        onGenerateRoute: (_) => MaterialPageRoute<void>(
                          builder: (_) => const FoodSample(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

IconData foodIcon(DesignConfig design, IconData filled, IconData outline) =>
    design[7] == 'outlined' ? outline : filled;
Color iconColor(
  DesignConfig design,
  ColorScheme color, [
  Color colorful = const Color(0xffd76631),
]) => design[7] == 'colored' ? colorful : color.onSurfaceVariant;

class FoodSample extends StatefulWidget {
  const FoodSample({super.key});
  @override
  State<FoodSample> createState() => _FoodSampleState();
}

class _FoodSampleState extends State<FoodSample> {
  int section = 0;
  String category = 'Tümü';
  final List<Food> cart = [];
  static const names = ['Ana Sayfa', 'Kategoriler', 'Sepet', 'Profil'];
  static const filled = [
    Icons.home,
    Icons.grid_view_rounded,
    Icons.shopping_bag,
    Icons.person,
  ];
  static const outlined = [
    Icons.home_outlined,
    Icons.grid_view_outlined,
    Icons.shopping_bag_outlined,
    Icons.person_outline,
  ];
  static const iconColors = [
    Color(0xffe06c33),
    Color(0xff569d68),
    Color(0xff6587cf),
    Color(0xffba70ac),
  ];
  void add(Food food) => setState(() => cart.add(food));
  void openFood(BuildContext context, Food food) {
    final config = _DesignScope.of(context);
    if (config[9] == 'bottom_sheet') {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (sheetContext) =>
            FoodDetail(food: food, onAdd: () => add(food), sheet: true),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoodDetail(food: food, onAdd: () => add(food)),
        ),
      );
    }
  }

  Widget navIcon(DesignConfig config, ColorScheme scheme, int i) => Icon(
    foodIcon(config, filled[i], outlined[i]),
    size: 19,
    color: section == i
        ? scheme.primary
        : iconColor(config, scheme, iconColors[i]),
  );
  @override
  Widget build(BuildContext context) {
    final config = _DesignScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: config[6] == 'drawer'
          ? Drawer(
              width: 235,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'lezzet.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 25),
                    for (var i = 0; i < 4; i++)
                      ListTile(
                        leading: navIcon(config, scheme, i),
                        title: Text(names[i]),
                        selected: section == i,
                        onTap: () {
                          setState(() => section = i);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              height: 30,
              alignment: Alignment.center,
              child: Container(
                width: 75,
                height: 17,
                decoration: BoxDecoration(
                  color: const Color(0xff242b2a),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Builder(builder: (inner) => _header(inner, config, scheme)),
            if (config[6] == 'tabs')
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => section = i),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 2,
                                  color: section == i
                                      ? scheme.primary
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Text(
                              names[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: section == i
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: section == i
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: switch (section) {
                1 => _categories(config),
                2 => _cart(config),
                3 => _profile(),
                _ => _home(config),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: config[6] == 'bottom'
          ? SafeArea(
              top: false,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: .45),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => section = i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              navIcon(config, scheme, i),
                              const SizedBox(height: 3),
                              Text(
                                names[i],
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: section == i
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: section == i
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _header(
    BuildContext context,
    DesignConfig config,
    ColorScheme scheme,
  ) {
    final menu = config[6] == 'drawer'
        ? IconButton(
            tooltip: 'Menüyü aç',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              foodIcon(config, Icons.menu, Icons.menu_outlined),
              size: 21,
            ),
          )
        : null;
    Widget text(String top, String bottom) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          top,
          style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
        ),
        Text(
          bottom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
    Widget right(IconData a, IconData b) => Icon(
      foodIcon(config, a, b),
      size: 21,
      color: iconColor(config, scheme),
    );
    final header = switch (config[2]) {
      'logo' => Row(
        children: [
          Text('✳', style: TextStyle(color: scheme.primary, fontSize: 20)),
          const Expanded(
            child: Center(
              child: Text(
                'lezzet.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          right(Icons.person, Icons.person_outline),
        ],
      ),
      'greeting' => Row(
        children: [
          Expanded(
            child: text('Merhaba, hoş geldin!', 'Bugün ne yemek istersin?'),
          ),
          CircleAvatar(
            radius: 15,
            backgroundColor: scheme.primaryContainer,
            child: right(Icons.person, Icons.person_outline),
          ),
        ],
      ),
      _ => Row(
        children: [
          Icon(
            foodIcon(config, Icons.location_on, Icons.location_on_outlined),
            color: scheme.primary,
            size: 18,
          ),
          const SizedBox(width: 5),
          Expanded(child: text('TESLİMAT ADRESİ', 'Atatürk Mah. No: 12')),
          right(Icons.notifications, Icons.notifications_outlined),
        ],
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 15, 8),
      child: Row(
        children: [
          ?menu,
          Expanded(child: header),
        ],
      ),
    );
  }

  Widget _home(DesignConfig config) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bugün ne yiyelim?',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sevdiğin lezzetler kapında.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Campaign(config: config),
        const SizedBox(height: 20),
        const Text(
          'Popüler lezzetler',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ProductList(
          config: config,
          foods: sampleFoods,
          onOpen: (f) => openFood(context, f),
          onAdd: add,
        ),
      ],
    ),
  );
  Widget _categories(DesignConfig config) {
    final categories = ['Tümü', ...sampleFoods.map((f) => f.category).toSet()];
    final foods = category == 'Tümü'
        ? sampleFoods
        : sampleFoods.where((f) => f.category == category).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategoriler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 5,
            children: [
              for (final item in categories)
                ChoiceChip(
                  label: Text(item, style: const TextStyle(fontSize: 10)),
                  selected: category == item,
                  onSelected: (_) => setState(() => category = item),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ProductList(
            config: config,
            foods: foods,
            onOpen: (f) => openFood(context, f),
            onAdd: add,
          ),
        ],
      ),
    );
  }

  Widget _cart(DesignConfig config) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sepetim',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        if (cart.isEmpty)
          const Text(
            'Sepetinde henüz ürün yok.',
            style: TextStyle(fontSize: 12),
          )
        else ...[
          for (var i = 0; i < cart.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: FoodImage(food: cart[i], width: 48, height: 48),
              title: Text(
                cart[i].name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${cart[i].price} TL',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: IconButton(
                tooltip: 'Ürünü çıkar',
                onPressed: () => setState(() => cart.removeAt(i)),
                icon: Icon(
                  foodIcon(config, Icons.delete, Icons.delete_outline),
                  size: 19,
                ),
              ),
            ),
          const Divider(),
          Text(
            'Toplam: ${cart.fold<int>(0, (sum, f) => sum + f.price)} TL',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu bir demo sepetidir; ödeme yapılmaz.',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ],
    ),
  );
  Widget _profile() => const Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 16),
        Text(
          'Bu bir örnek uygulamadır. Hesap oluşturulmaz.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

class FoodImage extends StatelessWidget {
  final Food food;
  final double? width, height;
  const FoodImage({super.key, required this.food, this.width, this.height});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.asset(
      'assets/images/${food.image}',
      width: width,
      height: height,
      fit: BoxFit.cover,
      semanticLabel: food.name,
    ),
  );
}

class Campaign extends StatelessWidget {
  final DesignConfig config;
  const Campaign({super.key, required this.config});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget campaign(
      String title,
      String subtitle, {
      bool image = true,
      double? width,
    }) => Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 8,
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (image)
            FoodImage(food: sampleFoods[0], width: 68, height: 68)
          else
            Icon(Icons.local_offer_outlined, color: scheme.onPrimaryContainer),
        ],
      ),
    );
    if (config[8] == 'cards') {
      return SizedBox(
        height: 96,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            campaign('%30 indirim', 'İLK SİPARİŞİNE', width: 220),
            const SizedBox(width: 8),
            campaign('Lezzet molası', 'BUGÜNE ÖZEL', width: 220),
          ],
        ),
      );
    }
    if (config[8] == 'minimal') {
      return campaign('İlk siparişine %30 indirim', 'FIRSATLAR', image: false);
    }
    return SizedBox(
      height: 110,
      child: campaign('İlk siparişine\n%30 indirim', 'SADECE SANA ÖZEL'),
    );
  }
}

class ProductList extends StatelessWidget {
  final DesignConfig config;
  final List<Food> foods;
  final void Function(Food) onOpen, onAdd;
  const ProductList({
    super.key,
    required this.config,
    required this.foods,
    required this.onOpen,
    required this.onAdd,
  });
  @override
  Widget build(BuildContext context) {
    Widget card(Food food, {bool horizontal = false}) => ProductCard(
      food: food,
      config: config,
      horizontal: horizontal,
      onOpen: () => onOpen(food),
      onAdd: () => onAdd(food),
    );
    if (config[3] == 'list') {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: foods.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => card(foods[i], horizontal: true),
      );
    }
    if (config[3] == 'carousel') {
      return SizedBox(
        height: 250,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: foods.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (_, i) => SizedBox(width: 175, child: card(foods[i])),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: foods.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 228,
      ),
      itemBuilder: (_, i) => card(foods[i]),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Food food;
  final DesignConfig config;
  final bool horizontal;
  final VoidCallback onOpen, onAdd;
  const ProductCard({
    super.key,
    required this.food,
    required this.config,
    required this.horizontal,
    required this.onOpen,
    required this.onAdd,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          food.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
        if (config[4] == 'image_name_price_rating_time')
          Text(
            '★ ${food.rating} · ${food.time}',
            maxLines: 1,
            style: TextStyle(fontSize: 9, color: scheme.onSurfaceVariant),
          ),
        if (config[4] == 'description_discount') ...[
          Text(
            food.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            'İndirimli',
            style: TextStyle(
              fontSize: 9,
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        const SizedBox(height: 3),
        Text(
          '${food.price} TL',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: horizontal
          ? Row(
              children: [
                InkWell(
                  onTap: onOpen,
                  child: FoodImage(food: food, width: 75, height: 95),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(onTap: onOpen, child: info),
                      const SizedBox(height: 4),
                      AddButton(
                        config: config,
                        onPressed: onAdd,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onOpen,
                    child: SizedBox(
                      width: double.infinity,
                      child: FoodImage(food: food),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onOpen,
                  child: SizedBox(width: double.infinity, child: info),
                ),
                const SizedBox(height: 4),
                AddButton(config: config, onPressed: onAdd, compact: true),
              ],
            ),
    );
  }
}

class AddButton extends StatelessWidget {
  final DesignConfig config;
  final VoidCallback onPressed;
  final bool compact;
  const AddButton({
    super.key,
    required this.config,
    required this.onPressed,
    this.compact = false,
  });
  @override
  Widget build(BuildContext context) {
    if (config[5] == 'icon') {
      return SizedBox(
        width: compact ? 34 : 48,
        height: compact ? 34 : 48,
        child: IconButton.filled(
          tooltip: 'Sepete ekle',
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 20),
        ),
      );
    }
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(compact ? 0 : 130, compact ? 34 : 48),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: compact ? 8 : 18),
      ),
      visualDensity: VisualDensity.compact,
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: compact ? 10 : 13, fontWeight: FontWeight.bold),
      ),
    );
    return config[5] == 'outlined'
        ? OutlinedButton(
            style: style,
            onPressed: onPressed,
            child: const Text('Sepete ekle', maxLines: 1),
          )
        : FilledButton(
            style: style,
            onPressed: onPressed,
            child: const Text('Sepete ekle', maxLines: 1),
          );
  }
}

class FoodDetail extends StatelessWidget {
  final Food food;
  final VoidCallback onAdd;
  final bool sheet;
  const FoodDetail({
    super.key,
    required this.food,
    required this.onAdd,
    this.sheet = false,
  });
  @override
  Widget build(BuildContext context) {
    final config = _DesignScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final informationFirst = config[9] == 'information_full_page';
    final contents = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!informationFirst) ...[
            FoodImage(
              food: food,
              width: double.infinity,
              height: sheet ? 125 : 230,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            food.name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (informationFirst) ...[
            Text(
              '★ ${food.rating}   •   ${food.time}   •   ${food.category}',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'İçindekiler',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            food.description,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          if (!informationFirst)
            Text(
              '★ ${food.rating}   •   ${food.time}',
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          if (informationFirst) ...[
            const SizedBox(height: 16),
            FoodImage(food: food, width: double.infinity, height: 110),
          ],
          const SizedBox(height: 18),
          Text(
            '${food.price} TL',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          AddButton(
            config: config,
            onPressed: () {
              onAdd();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ürün sepete eklendi'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
    if (sheet) return SizedBox(height: 450, child: contents);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ürün detayı',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: contents,
    );
  }
}
