/// Design decisions. The demo defaults are not the private reference key.
class DesignConfig {
  static const keys = [
    'primaryColorId',
    'themeMode',
    'appBarStyle',
    'productLayout',
    'productCardStyle',
    'buttonStyle',
    'navigationStyle',
    'iconStyle',
    'campaignStyle',
    'detailStyle',
  ];
  static const choices = [
    ['orange', 'green', 'blue'],
    ['light', 'dark', 'system'],
    ['logo', 'location_notification', 'greeting'],
    ['list', 'grid', 'carousel'],
    [
      'image_name_price',
      'image_name_price_rating_time',
      'description_discount',
    ],
    ['filled', 'outlined', 'icon'],
    ['bottom', 'drawer', 'tabs'],
    ['filled', 'outlined', 'colored'],
    ['large_banner', 'cards', 'minimal'],
    ['image_focused_full_page', 'information_full_page', 'bottom_sheet'],
  ];
  static const labels = [
    ['Turuncu', 'Yeşil', 'Mavi'],
    ['Açık tema', 'Koyu tema', 'Sistem teması'],
    ['Logo ve profil', 'Konum ve bildirim', 'Karşılama ve profil'],
    ['Liste', 'İki sütunlu ızgara', 'Yatay vitrin'],
    [
      'Görsel, ad, fiyat',
      'Görsel, ad, fiyat, puan, süre',
      'Görsel, ad, açıklama, fiyat, indirim',
    ],
    ['Dolgulu buton', 'Çerçeveli buton', 'İkon butonu'],
    ['Alt navigasyon', 'Yandan menü', 'Üst sekmeler'],
    ['Dolu ikonlar', 'Çizgisel ikonlar', 'Renkli ikonlar'],
    ['Büyük banner', 'Kampanya kartları', 'Minimal indirim alanı'],
    ['Görsel ağırlıklı tam ekran', 'Bilgi ağırlıklı tam ekran', 'Alt panel'],
  ];
  // Full wording from the specification; labels above are compact UI labels.
  static const optionDescriptions = [
    [
      'Turuncu: Enerjik, iştah açıcı.',
      'Yeşil: Doğal, taze.',
      'Mavi: Modern, güven veren.',
    ],
    [
      'Açık tema.',
      'Koyu tema.',
      'Sistem teması: Cihazın açık/koyu ayarına göre.',
    ],
    [
      'Solda logo, ortada uygulama adı, sağda profil ikonu.',
      'Solda konum bilgisi ve adres, sağda bildirim ikonu.',
      'Büyük karşılama başlığı ve kısa mesaj, sağda profil fotoğrafı.',
    ],
    [
      'Liste: Tek sütun, yatay ürün kartları.',
      'Izgara: İki sütunlu ürün kartları.',
      'Büyük kartlar: Yatay kaydırılabilen geniş vitrin kartları.',
    ],
    [
      'Büyük yemek görseli, yemek adı ve fiyat.',
      'Yemek görseli, adı, fiyatı, puanı ve hazırlanma süresi.',
      'Yemek görseli, adı, açıklaması, fiyatı ve indirim etiketi.',
    ],
    [
      'Dolgulu buton: Belirgin renkli, metin içeren buton.',
      'Çerçeveli buton: Outlined görünüm.',
      'İkon butonu: Yuvarlak artı simgesi.',
    ],
    [
      'Alt menü: Ana Sayfa, Kategoriler, Sepet, Profil.',
      'Drawer: Aynı bölümleri yandan açılan menüde gösterir.',
      'Üst sekmeler: Aynı bölümlere AppBar altındaki sekmelerden ulaşılır.',
    ],
    ['Dolu ikonlar.', 'Çizgisel ikonlar.', 'Renkli ikonlar.'],
    [
      'Büyük banner: Geniş, görsel ağırlıklı kampanya alanı.',
      'Kampanya kartları: Yan yana kaydırılabilir küçük kartlar.',
      'Minimal indirim alanı: Metin ve küçük ikon ağırlıklı.',
    ],
    [
      'Görsel ağırlıklı tam ekran detay: Büyük fotoğraf, altında ad, açıklama, fiyat ve sepete ekle butonu.',
      'Bilgi ağırlıklı detay: İçerik, puan, fiyat ve hazırlanma süresi daha baskın.',
      'Alt panel: Ürün detayları modal bottom sheet içinde açılır.',
    ],
  ];
  static const questions = [
    'Uygulamanın ana renk teması ne olsun?',
    'Uygulamanın tema modu nasıl olsun?',
    'Uygulamanın üst bölümünde nasıl bir AppBar olsun?',
    'Yemekler nasıl listelensin?',
    'Yemek kartlarında hangi bilgiler bulunsun?',
    'Sepete ekleme butonu nasıl tasarlansın?',
    'Ana navigasyon nasıl olsun?',
    'Uygulamada hangi ikon stili kullanılsın?',
    'Ana sayfada kampanya alanı nasıl görünsün?',
    'Bir yemeğe tıklandığında detay ekranı nasıl açılsın?',
  ];
  final List<String> _values;
  DesignConfig._(List<String> values) : _values = List.unmodifiable(values);
  factory DesignConfig.demo() =>
      DesignConfig._([for (final group in choices) group.first]);
  factory DesignConfig.fromJson(Map<String, dynamic> json) {
    final values = <String>[];
    for (var i = 0; i < keys.length; i++) {
      final value = json[keys[i]];
      if (value is! String || !choices[i].contains(value)) {
        throw FormatException('Geçersiz tasarım alanı: ${keys[i]}');
      }
      values.add(value);
    }
    return DesignConfig._(values);
  }
  Map<String, dynamic> toJson() => {
    for (var i = 0; i < keys.length; i++) keys[i]: _values[i],
  };
  String get primaryColorId => _values[0];
  String get themeMode => _values[1];
  String get appBarStyle => _values[2];
  String get productLayout => _values[3];
  String get productCardStyle => _values[4];
  String get buttonStyle => _values[5];
  String get navigationStyle => _values[6];
  String get iconStyle => _values[7];
  String get campaignStyle => _values[8];
  String get detailStyle => _values[9];
  String operator [](int index) => _values[index];
  DesignConfig choose(int question, int option) {
    if (question < 0 || question >= keys.length || option < 0 || option >= 3) {
      throw RangeError('Geçersiz soru veya seçenek');
    }
    final next = List<String>.of(_values);
    next[question] = choices[question][option];
    return DesignConfig._(next);
  }

  int selectedOption(int question) =>
      choices[question].indexOf(_values[question]);
}
