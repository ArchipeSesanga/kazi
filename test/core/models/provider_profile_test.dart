import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/models/provider_profile.dart';

void main() {
  group('ProviderProfile.toCreateMap', () {
    test('emits the exact provider create keys and normalized values', () {
      final payload = _profile().toCreateMap();

      expect(payload.keys.toSet(), {
        'displayName',
        'bio',
        'photoUrl',
        'coverUrl',
        'categoryIds',
        'city',
        'baseCommune',
        'communes',
        'whatsappNumber',
        'callNumber',
        'yearsExperience',
        'portfolio',
        'status',
        'verified',
        'ratingAvg',
        'ratingCount',
        'ratingSum',
        'listingCount',
        'createdAt',
        'updatedAt',
      });
      expect(payload['yearsExperience'], 8);
      expect(payload['yearsExperience'], isA<int>());
      expect(payload['whatsappNumber'], '+243812345678');
      expect(payload['callNumber'], isNull);
      expect(
        payload['photoUrl'],
        'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/avatar.jpg?alt=media&token=test',
      );
      expect(
        payload['coverUrl'],
        'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/cover.jpg?alt=media&token=test',
      );
      expect(payload['baseCommune'], 'gombe');
      expect(payload['communes'], ['gombe', 'lingwala']);
      expect(payload['status'], 'pending');
      expect(payload['verified'], isFalse);
      expect(payload['ratingAvg'], 0);
      expect(payload['ratingCount'], 0);
      expect(payload['ratingSum'], 0);
      expect(payload['listingCount'], 0);
      expect(payload['createdAt'], isA<FieldValue>());
      expect(payload['updatedAt'], isA<FieldValue>());
    });

    test('defaults missing experience to int zero', () {
      final payload = _profile(yearsExperience: 0).toCreateMap();

      expect(payload['yearsExperience'], 0);
      expect(payload['yearsExperience'], isA<int>());
    });

    test('normalizes optional call number to E.164', () {
      final payload = _profile()
          .copyWith(callNumber: '0812345678')
          .toCreateMap();

      expect(payload['callNumber'], '+243812345678');
    });

    test('normalizes empty photo URLs to null without dropping their keys', () {
      final payload = _profile(photoUrl: '', coverUrl: '   ').toCreateMap();

      expect(payload.containsKey('photoUrl'), isTrue);
      expect(payload['photoUrl'], isNull);
      expect(payload.containsKey('coverUrl'), isTrue);
      expect(payload['coverUrl'], isNull);
    });
  });
}

ProviderProfile _profile({
  int yearsExperience = 8,
  String? photoUrl = 'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/avatar.jpg?alt=media&token=test',
  String? coverUrl = 'https://firebasestorage.googleapis.com/v0/b/kazi-dev/o/cover.jpg?alt=media&token=test',
}) => ProviderProfile(
  uid: 'provider-uid',
  displayName: 'Jean Mukendi',
  bio: 'Plombier depuis 8 ans',
  photoUrl: photoUrl,
  coverUrl: coverUrl,
  whatsappNumber: '0812345678',
  yearsExperience: yearsExperience,
  categoryIds: const ['plomberie'],
  baseCommune: 'gombe',
  communes: const ['lingwala'],
);
