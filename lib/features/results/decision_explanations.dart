import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../preview/domain/design_config.dart';

/// Explanations for *every* possible choice. No private answer key is encoded
/// here: the result document supplies the chosen reference only after the event.
const decisionRationales = <List<String>>[
  [
    'Turuncu, sıcak ve enerjik bir görsel kimlik oluşturmak için kullanılabilir; buton ve kampanya vurgularını aynı renk ailesinde birleştirir. Rengin etkisi bağlama ve hedef kitleye göre değişebilir; okunabilir metin ve yeterli kontrast ayrıca gözetilmelidir.',
    'Yeşil, tazelik ve doğal ürün çağrışımlarını öne çıkarmak için kullanılabilir. Ürün görselleri ve ana eylemlerle tutarlı bir renk sistemi oluşturmak ve kontrastı kontrol etmek önemlidir.',
    'Mavi, sakin ve düzenli bir marka görünümü oluşturmak için kullanılabilir. Yemek görsellerinin canlılığını korurken eylem ve metinlerin arka plandan yeterince ayrılması önemlidir.',
  ],
  [
    'Açık tema, içerik, ürün fotoğrafları ve metinler için tutarlı bir açık zemin sağlayabilir. Koyu veya sistem teması da geçerli tercihlerdir; hangi tema kullanılırsa kullanılsın metin kontrastı ve okunabilirlik korunmalıdır.',
    'Koyu tema, düşük ışıkta daha az parlak bir arayüz isteyen bir deneyim için tercih edilebilir. Metin ve kontrollerin koyu zeminde yeterince ayrılması ve görsellerin doğal görünmesi önemlidir.',
    'Sistem temasını izlemek, uygulamanın cihazda seçilen açık veya koyu görünüme uyum sağlamasına yardımcı olur. Her iki görünümde de metin, simge ve etkileşimlerin okunabilirliği ayrı ayrı kontrol edilmelidir.',
  ],
  [
    'Logo ve profil düzeni, marka kimliğini ve hesap erişimini ekranın üst bölümünde belirgin tutar. Teslimat adresi gibi siparişe ilişkin bilgiler başka bir yerde kolayca bulunabilmelidir.',
    'Konum ve bildirim düzeni, yemek siparişinde teslimat adresini kullanıcıya sürekli hatırlatır ve bildirimlere doğrudan erişim sunar. Böylece siparişin nereye gönderileceği önemli bir bağlam bilgisi olarak üst alanda görünür.',
    'Karşılama ve profil düzeni, kişisel bir giriş hissi oluşturmaya odaklanır. Teslimat konumu ve diğer sık kullanılan işlemler için ayrıca açık ve kolay erişilebilir alanlar ayrılmalıdır.',
  ],
  [
    'Tek sütunlu liste, her ürün için daha geniş yatay alan sağlar ve açıklamaları rahat sunabilir. Bunun karşılığında aynı anda daha az ürün gösterilebilir.',
    'İki sütunlu ızgara, dar telefon ekranında birden fazla yemeği aynı anda göstererek ürünleri karşılaştırmayı kolaylaştırmayı amaçlar. Kartların metinleri okunabilir kalmalı ve farklı ekran genişliklerinde taşmamalıdır.',
    'Yatay vitrin, büyük ürün görsellerine daha fazla alan ayırarak seçili yemekleri öne çıkarabilir. Yatay kaydırılabilen başka ürünler olduğu kullanıcıya anlaşılır biçimde gösterilmelidir.',
  ],
  [
    'Görsel, ad ve fiyatla sınırlı kart, sade ve hızlı taranabilir bir görünüm oluşturur. Puan ve süre gibi ek karar bilgilerine ürün detayından erişim sağlanmalıdır.',
    'Görsel, ad, fiyat, puan ve hazırlanma süresinin birlikte gösterilmesi, kullanıcının ürünleri detay sayfasına girmeden birkaç ölçüte göre karşılaştırabilmesini amaçlar. Bilgi yoğunluğu arttığı için kartta okunabilir bir görsel hiyerarşi önemlidir.',
    'Açıklama ve indirim etiketini gösteren kart, ürün içeriğini ve kampanyayı öne çıkarır. Etiketlerin fiyatı gölgelememesi ve bilginin küçük kartlarda da okunabilir olması gerekir.',
  ],
  [
    'Dolgulu ve metinli buton, temel eylem olan “Sepete ekle”yi diğer kontrollerden belirgin biçimde ayırabilir. Metin eylemin ne olduğunu açıklar; renk kontrastı ve dokunma alanı da erişilebilirlik için kontrol edilmelidir.',
    'Çerçeveli buton, daha sakin bir görsel hiyerarşi oluşturmak için kullanılabilir. Ana eylemin sayfada fark edilir kalması ve buton metninin okunabilir olması önemlidir.',
    'Artı ikonlu buton, küçük kartlarda yerden tasarruf sağlayabilir. İkonun ne yaptığının anlaşılması için erişilebilir ad ve yeterli dokunma alanı sağlanmalıdır.',
  ],
  [
    'Alt navigasyon, dört ana bölümü mobil ekranda sürekli görünür tutarak bölümler arasında doğrudan geçiş sağlamayı amaçlar. Seçili bölüm açıkça belirtilmeli ve alt alanın içerik için bıraktığı yer de değerlendirilmelidir.',
    'Yandan açılan menü, ana ekranda daha fazla alan bırakabilir ve daha çok bağlantıyı barındırabilir. Buna karşılık bölümleri görmek için menüyü açmak gerekir; menü simgesi ve bölüm adları anlaşılır olmalıdır.',
    'Üst sekmeler, aynı düzeydeki bölümleri ekranın üst kısmında bir arada sunar. Dört sekmenin dar ekranda okunabilir kalması ve seçili sekmenin belirgin olması önemlidir.',
  ],
  [
    'Dolu ikonlar, güçlü görsel vurgu oluşturabilir ve küçük boyutlarda belirgin kalabilir. Aynı ikon ailesi kullanılarak anlam ve görsel tutarlılık korunmalıdır.',
    'Çizgisel ikonlar, daha hafif ve tutarlı bir görsel dil oluşturabilir. İkonların anlamlarının anlaşılır, çizgilerinin yeterince belirgin ve ilgili metinlerle uyumlu olması önemlidir.',
    'Renkli ikonlar, bölümleri görsel olarak ayırt etmeye yardımcı olabilir. Anlam yalnızca renge bırakılmamalı; simge biçimi ve gerektiğinde metin de kullanılmalıdır.',
  ],
  [
    'Büyük banner, tek ana kampanyayı görsel ve metinle ön plana çıkarmayı amaçlar. Kampanya alanı ürün listesini aşırı aşağı itmemeli; teklif metni ve görsel arasındaki kontrast korunmalıdır.',
    'Birden fazla kampanya kartı, farklı teklifleri aynı alanda sunabilir. Kartların yatay kaydırılabildiği anlaşılmalı ve her teklifin koşulları okunabilir kalmalıdır.',
    'Minimal indirim alanı, kampanyayı daha az yer kaplayarak sunar ve ürünlere daha fazla ekran alanı bırakır. Teklifin fark edilebilirliği ve açık anlatımı korunmalıdır.',
  ],
  [
    'Görsel ağırlıklı tam ekran detay, yemeğin büyük fotoğrafını öne çıkarırken ad, açıklama, fiyat ve sepete ekleme eylemine ayrı bir alan sağlar. Görselin yanında karar vermek için gereken bilgilerin de kolayca bulunması önemlidir.',
    'Bilgi ağırlıklı tam ekran detay, içerik, puan, fiyat ve hazırlanma süresini daha belirgin sunarak ayrıntılı karşılaştırmayı destekler. Ürün görseli ve temel eylem de kolayca bulunmalıdır.',
    'Alt panel, kullanıcıyı ürün listesinden tamamen uzaklaştırmadan detayları gösterebilir. Panelin kapatılması, içeriğin kaydırılması ve sepete ekleme eylemi mobilde kolay olmalıdır.',
  ],
];

/// Displayed only after finalization and only for a differing classroom choice.
class DecisionExplanation extends StatelessWidget {
  final int questionIndex;
  final String classChoice;
  final String referenceChoice;
  const DecisionExplanation({
    super.key,
    required this.questionIndex,
    required this.classChoice,
    required this.referenceChoice,
  });

  @override
  Widget build(BuildContext context) {
    const choices = ['A', 'B', 'C'];
    final referenceIndex = choices.indexOf(referenceChoice);
    if (classChoice == referenceChoice ||
        !choices.contains(classChoice) ||
        referenceIndex < 0 ||
        questionIndex < 0 ||
        questionIndex >= decisionRationales.length) {
      return const SizedBox.shrink();
    }
    final label = DesignConfig.labels[questionIndex][referenceIndex];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffeff4e8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffd6e4c9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referans neden $referenceChoice · $label?',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: BattleColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            decisionRationales[questionIndex][referenceIndex],
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: BattleColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
