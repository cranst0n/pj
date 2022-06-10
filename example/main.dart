import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';
import 'package:pj/syntax.dart';

// ignore_for_file: avoid_print

void main() {
  final people = [
    Person('Albert', 'Einstein', DateTime(1879, 3, 14), 7, some(true),
        [Pet('Physics', none(), 12)]),
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
  final peopleJson = Codec.listOf(Person.codec).encode(people);

  // Decode the entire list of people
  Codec.listOf(Person.codec).decode(peopleJson).fold(
        (err) => print('[✘] Nobody is coming to the party: $err'),
        (inviteList) => print(
            '[✔] ${inviteList.map((p) => p.firstName).join(", ")} will be attending the party.'),
      );

  final petJson = {'pet-name': 'Ribs', 'age': 13};

  Pet.codecAlt.decode(petJson).fold(
        (err) => print('[✘] Parse failed: $err'),
        (ribs) => print(
            '[✔] ${ribs.name} is the best boy. Give him ${ribs.bellyRubs} belly rubs!'),
      );

  // Decoding pet json with a Person decoder will fail with an error
  Person.codec.decode(petJson).fold(
        (err) =>
            print("[✔] Of course you can't turn a pet into a person: $err"),
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

  /// Our [Person] codec that will serialize a value to JSON object
  static final codec = Codec.forProduct6(
    // Provide the individual key-value codecs
    'firstName'.string.ensure((s) => s.isNotEmpty, 'Missing first name.'),
    'lastName'.string.nullable,
    'birthday'.dateTime,
    'luckyNumber'.integer,
    'registeredVoter'.boolean.optional,
    'pets'.listOf(Pet.codecAlt),
    // Provide how to turn the individual values into out Product type (Pet)
    Person.new,
    // Provide how to turn our product type into a tuple
    (person) => tuple6(person.firstName, person.lastName, person.birthday,
        person.luckyNumber, person.registeredVoter, person.pets),
  );

  /// Alternative codec definition equivalent to the one above.
  static final codecAlt = Codec.forProduct6(
    string('firstName').ensure((s) => s.isNotEmpty, 'Missing first name'),
    string('lastName').nullable,
    dateTime('birthday'),
    integer('luckyNumber'),
    boolean('registeredVoter').optional,
    listOf(Pet.codec)('pets'),
    Person.new,
    (person) => tuple6(person.firstName, person.lastName, person.birthday,
        person.luckyNumber, person.registeredVoter, person.pets),
  );
}

class Pet {
  final String name;
  final Option<int> age;
  final int bellyRubs;

  Pet(this.name, this.age, this.bellyRubs);

  /// Our [Pet] codec that will serialize a value to JSON object
  static final codec = Codec.forProduct3(
    'pet-name'.string,
    'age'.integer.optional,
    'belly-rubs'.integer.withDefault(8675309),
    Pet.new,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );

  /// Alternative way to define our [Pet] codec, equivalent to the
  /// definition above.
  static final codecAlt = Codec.forProduct3(
    string('pet-name'),
    integer('age').optional,
    integer('belly-rubs').withDefault(8675309),
    Pet.new,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );

  /// Another alternative, lower level, way to define our [Pet] codec
  /// This method opens a few addional doors that give you more power
  /// but also more ways to potentially shoot yourself in the foot.
  static final codecLowLevel = Codec.forProduct3(
    Codec.string.at('pet-name'),
    Codec.integer.at('age').optional,
    Codec.integer.at('belly-rubs').withDefault(8675309),
    Pet.new,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );
}
