final List<String> roomNames = List<String>.unmodifiable(
  <String>[
    'Zombik: a halálzóna',
    'A Kalapos',
    'Varázskastély',
    'Alice',
    'Kocka',
    'Kalóz öböl',
    'A Trón',
    'A sógun',
    'A katedrális',
    'A fáraó sírja I.',
    'A fáraó sírja II.',
    'A Tengeralattjáró',
    'Az időgép',
  ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
);

const timeSlots = <String>[
  '9:00-10:00',
  '10:30-11:30',
  '12:00-13:00',
  '13:30-14:30',
  '15:00-16:00',
  '16:30-17:30',
  '18:00-19:00',
  '19:30-20:30',
  '21:00-22:00',
];
