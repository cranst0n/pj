import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';

// ignore_for_file: avoid_print

void main() {
  final people = [
    Person(
      'Albert',
      'Einstein',
      DateTime(1879, 3, 14),
      7,
      some(true),
      [Pet('Physics', none(), 12)],
    ),
    Person('Douglas', 'Adams', DateTime(1952, 5, 11), 42, none(), []),
    Person('Dolly', 'Parton', DateTime(1946, 1, 19), 95, some(false), []),
  ];

  // Encode and attempt decode of Albert Einstein
  final albertJson = Person.codec.encode(people[0]);

  Person.codec.decode(albertJson).fold(
        (err) => print('[✘] Failed to decode Einstein: $err'),
        (albert) => print(
          '[✔] Alberts lucky number is ${albert.luckyNumber} and he has ${albert.pets.length} pet(s).',
        ),
      );

  // Encode the entire list of people
  final peopleJson = Codec.list(Person.codec).encode(people);

  // Decode the entire list of people
  Codec.list(Person.codec).decode(peopleJson).fold(
        (err) => print('[✘] Nobody is coming to the party: $err'),
        (inviteList) => print(
            '[✔] ${inviteList.map((p) => p.firstName).join(", ")} will be attending the party.'),
      );

  final petJson = {'pet-name': 'Ribs', 'age': 13};

  Pet.codecAlt.decode(petJson).fold(
        (err) => print('[✘] Parse failed: $err'),
        (ribs) => print(
            '[✔] Ribs is the best boy. Give him ${ribs.bellyRubs} belly rubs!'),
      );

  // Decoding pet json with a Person decoder will fail with an error
  Person.codec.decode(petJson).fold(
        (err) => print("[✔] Of course you can't turn a pet into a person!"),
        (humanPet) => print(
          "[✘] Your scientists were so preoccupied with whether or not they could, they didn't stop to think if they should.",
        ),
      );
}

class Person {
  final String firstName;
  final String? lastName;
  final DateTime birthday;
  final int luckyNumber;
  final Option<bool> registeredVoter;
  final List<Pet> pets;

  Person(
    this.firstName,
    this.lastName,
    this.birthday,
    this.luckyNumber,
    this.registeredVoter,
    this.pets,
  );

  // Constructor tearoffs make this obsolete
  static Person apply(
    String firstName,
    String? lastName,
    DateTime birthday,
    int luckyNumber,
    Option<bool> registeredVoter,
    List<Pet> pets,
  ) =>
      Person(firstName, lastName, birthday, luckyNumber, registeredVoter, pets);

  /// Our [Person] codec that will serialize a value to JSON object
  static final codec = Codec.forProduct6(
    // Provide the individual key-value codecs
    codecString('firstName')
        .ensure((s) => s.isNotEmpty, 'First name must be non-empty.'),
    codecString('lastName').nullable,
    codecDateTime('birthday'),
    codecInt('luckyNumber'),
    codecBool('registeredVoter').optional,
    codecList('pets', Pet.codec),
    // Provide how to turn the individual values into out Product type (Pet)
    Person.apply,
    // Provide how to turn our product type into a tuple
    (person) => tuple6(person.firstName, person.lastName, person.birthday,
        person.luckyNumber, person.registeredVoter, person.pets),
  );
}

class Pet {
  final String name;
  final Option<int> age;
  final int bellyRubs;

  Pet(this.name, this.age, this.bellyRubs);

  static Pet apply(String name, Option<int> age, int bellyRubs) =>
      Pet(name, age, bellyRubs);

  /// Our [Pet] codec that will serialize a value to JSON object
  static final codec = Codec.forProduct3(
    codecString('pet-name'),
    codecInt('age').optional,
    codecInt('belly-rubs').withDefault(8675309),
    Pet.apply,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );

  /// Alternative way to define our [Pet] codec
  /// This method opens a few addional doors that give you more power
  /// but also more ways to potentially shoot yourself in the foot.
  static final codecAlt = Codec.forProduct3(
    Codec.string.keyed('pet-name'),
    Codec.integer.keyed('age').optional,
    Codec.integer.keyed('belly-rubs').withDefault(8675309),
    Pet.apply,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );
}
