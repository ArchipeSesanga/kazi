import '../../../core/models/category.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/models/location.dart';

const List<Category> defaultCategories = [
  Category(id: 'plomberie', name: LocalizedText(fr: 'Plomberie', en: 'Plumbing'), icon: 'wrench', order: 1),
  Category(id: 'electricite', name: LocalizedText(fr: 'Électricité', en: 'Electrical'), icon: 'zap', order: 2),
  Category(id: 'coiffure_beaute', name: LocalizedText(fr: 'Coiffure & beauté', en: 'Hair & beauty'), icon: 'scissors', order: 3),
  Category(id: 'couture', name: LocalizedText(fr: 'Couture', en: 'Tailoring'), icon: 'shirt', order: 4),
  Category(id: 'menuiserie', name: LocalizedText(fr: 'Menuiserie', en: 'Carpentry'), icon: 'hammer', order: 5),
  Category(id: 'maconnerie', name: LocalizedText(fr: 'Maçonnerie & construction', en: 'Masonry & building'), icon: 'brick-wall', order: 6),
  Category(id: 'peinture', name: LocalizedText(fr: 'Peinture', en: 'Painting'), icon: 'paint-roller', order: 7),
  Category(id: 'mecanique_auto', name: LocalizedText(fr: 'Mécanique auto', en: 'Car mechanics'), icon: 'car', order: 8),
  Category(id: 'reparation_telephones', name: LocalizedText(fr: 'Réparation téléphones & électronique', en: 'Phone & electronics repair'), icon: 'smartphone', order: 9),
  Category(id: 'informatique', name: LocalizedText(fr: 'Informatique', en: 'IT services'), icon: 'laptop', order: 10),
  Category(id: 'cours_particuliers', name: LocalizedText(fr: 'Cours particuliers', en: 'Tutoring'), icon: 'graduation-cap', order: 11),
  Category(id: 'menage', name: LocalizedText(fr: 'Ménage & nettoyage', en: 'Cleaning'), icon: 'sparkles', order: 12),
  Category(id: 'cuisine_traiteur', name: LocalizedText(fr: 'Cuisine & traiteur', en: 'Cooking & catering'), icon: 'chef-hat', order: 13),
  Category(id: 'transport_demenagement', name: LocalizedText(fr: 'Transport & déménagement', en: 'Transport & moving'), icon: 'truck', order: 14),
  Category(id: 'evenementiel', name: LocalizedText(fr: 'Événementiel', en: 'Events (DJ, décor, photo)'), icon: 'party-popper', order: 15),
  Category(id: 'climatisation', name: LocalizedText(fr: 'Climatisation & froid', en: 'Air-con & refrigeration'), icon: 'snowflake', order: 16),
  Category(id: 'soudure', name: LocalizedText(fr: 'Soudure', en: 'Welding'), icon: 'flame', order: 17),
  Category(id: 'jardinage', name: LocalizedText(fr: 'Jardinage', en: 'Gardening'), icon: 'sprout', order: 18),
  Category(id: 'garde_enfants', name: LocalizedText(fr: "Garde d'enfants", en: 'Childcare'), icon: 'baby', order: 19),
  Category(id: 'autres', name: LocalizedText(fr: 'Autres services', en: 'Other services'), icon: 'ellipsis', order: 20),
];

const List<City> defaultCities = [
  City(
    id: 'kinshasa',
    name: 'Kinshasa',
    communes: [
      Commune(id: 'bandalungwa', name: 'Bandalungwa'),
      Commune(id: 'barumbu', name: 'Barumbu'),
      Commune(id: 'bumbu', name: 'Bumbu'),
      Commune(id: 'gombe', name: 'Gombe'),
      Commune(id: 'kalamu', name: 'Kalamu'),
      Commune(id: 'kasa_vubu', name: 'Kasa-Vubu'),
      Commune(id: 'kimbanseke', name: 'Kimbanseke'),
      Commune(id: 'kinshasa', name: 'Kinshasa'),
      Commune(id: 'kintambo', name: 'Kintambo'),
      Commune(id: 'kisenso', name: 'Kisenso'),
      Commune(id: 'lemba', name: 'Lemba'),
      Commune(id: 'limete', name: 'Limete'),
      Commune(id: 'lingwala', name: 'Lingwala'),
      Commune(id: 'makala', name: 'Makala'),
      Commune(id: 'maluku', name: 'Maluku'),
      Commune(id: 'masina', name: 'Masina'),
      Commune(id: 'matete', name: 'Matete'),
      Commune(id: 'mont_ngafula', name: 'Mont-Ngafula'),
      Commune(id: 'ndjili', name: "N'djili"),
      Commune(id: 'ngaba', name: 'Ngaba'),
      Commune(id: 'ngaliema', name: 'Ngaliema'),
      Commune(id: 'ngiri_ngiri', name: 'Ngiri-Ngiri'),
      Commune(id: 'nsele', name: 'Nsele'),
      Commune(id: 'selembao', name: 'Selembao'),
    ],
  ),
];
