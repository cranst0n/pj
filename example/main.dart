import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:pj/pj.dart';

void main() {
  final people = [
    Person('Albert', 'Einstein', DateTime(1879, 3, 14), 7, some(true)),
    Person('Douglas', 'Adams', DateTime(1952, 5, 11), 42, none()),
    Person('Dolly', 'Parton', DateTime(1946, 1, 19), 95, some(false)),
  ];

  // Encode and attempt decode of Albert Einstein
  final albertJsonString = jsonEncode(Person.codec.encode(people[0]));

  Person.codec.decode(jsonDecode(albertJsonString)).fold(
        (err) => print('Failed to decode Einstein: $err'),
        (success) => print('Alberts lucky number is: ${success.luckyNumber}'),
      );

  // Encode the entire list of people
  final peopleJsonString = jsonEncode(Codec.list(Person.codec).encode(people));

  // Build our own codec to decode the list of people
  Codec.list(Person.codec).decode(jsonDecode(peopleJsonString)).fold(
        (err) => print('Nobody is coming to the party.'),
        (inviteList) => print(
            '${inviteList.map((e) => e.firstName).join(", ")} will be attending the party.'),
      );

  // Good-boy
  final petJson = {'pet-name': 'Ribs', 'age': 13};

  Pet.codec.decode(petJson).fold(
        (err) => print('Good boy parse failed: $err'),
        (ribs) => print(
            'Ribs is the best boy. Give him ${ribs.bellyRubs} belly rubs!'),
      );

  // Decoding other json will fail with an error
  Person.codec.decode(petJson).fold(
        (err) => print("Of course you can't turn a pet into a person!"),
        (humanPet) => print(
          "Your scientists were so preoccupied with whether or not they could, they didn't stop to think if they should.",
        ),
      );
}

class Person {
  final String firstName;
  final String lastName;
  final DateTime birthday;
  final int luckyNumber;
  final Option<bool> registeredVoter;

  Person(
    this.firstName,
    this.lastName,
    this.birthday,
    this.luckyNumber,
    this.registeredVoter,
  );

  // Constructor tearoffs make this obsolete
  static Person apply(
    String firstName,
    String lastName,
    DateTime birthday,
    int luckyNumber,
    Option<bool> registeredVoter,
  ) =>
      Person(firstName, lastName, birthday, luckyNumber, registeredVoter);

  static final codec = Codec.forProduct5(
    codecString('firstName'),
    codecString('lastName'),
    codecDateTime('birthday'),
    codecInt('luckyNumber'),
    codecBool('registeredVoter').optional,
    Person.apply,
    (person) => tuple5(person.firstName, person.lastName, person.birthday,
        person.luckyNumber, person.registeredVoter),
  );
}

class Pet {
  final String name;
  final Option<int> age;
  final int bellyRubs;

  Pet(this.name, this.age, this.bellyRubs);

  static Pet apply(String name, Option<int> age, int bellyRubs) =>
      Pet(name, age, bellyRubs);

  static final codec = Codec.forProduct3(
    codecString('pet-name'),
    codecInt('age').optional,
    codecInt('belly-rubs').withDefault(8675309),
    Pet.apply,
    (pet) => tuple3(pet.name, pet.age, pet.bellyRubs),
  );
}
