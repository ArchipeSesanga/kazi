import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/enums.dart';
import 'package:kazi/core/widgets/kazi_avatar.dart';
import 'package:kazi/features/listings/domain/listing_repository.dart';
import 'package:kazi/features/listings/presentation/listing_result_tile.dart';

const _photo = 'https://firebasestorage.googleapis.com/v0/b/x/o/avatar.jpg?alt=media&token=t';

Listing _listing({String? providerPhotoUrl}) => Listing(
      id: 'l1',
      providerId: 'p1',
      title: 'Réparation de fuite',
      categoryId: 'plomberie',
      priceType: PriceType.quote,
      city: 'kinshasa',
      providerName: 'Jean Mukendi',
      providerPhotoUrl: providerPhotoUrl,
    );

Future<void> _pump(WidgetTester tester, Listing l) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingResultTile(listing: l, locale: 'fr', onTap: () {}),
        ),
      ),
    );

void main() {
  testWidgets('shows the provider\'s picture', (tester) async {
    await _pump(tester, _listing(providerPhotoUrl: _photo));
    expect(tester.widget<KaziAvatar>(find.byType(KaziAvatar)).photoUrl, _photo);
    expect(find.text('Jean Mukendi'), findsOneWidget);
  });

  testWidgets('falls back to initials when the provider has no picture', (tester) async {
    await _pump(tester, _listing());
    expect(tester.widget<KaziAvatar>(find.byType(KaziAvatar)).photoUrl, isNull);
    expect(find.text('JM'), findsOneWidget);
  });
}
