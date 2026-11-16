import 'package:flutter_test/flutter_test.dart';
import 'package:design_battle/features/event/host_page.dart';

void main() {
  test('GitHub Pages alt yolunda QR linki admin bilgisini taşımaz', () {
    final uri = Uri.parse(
      participantUrl(
        Uri.parse('https://class.github.io/design-battle/#/host?event=OLD'),
        'Abcdef0123456789ABCD',
      ),
    );
    expect(uri.path, '/design-battle/');
    expect(uri.fragment, '/join?event=Abcdef0123456789ABCD');
    expect(uri.toString(), isNot(contains('/host')));
  });
}
