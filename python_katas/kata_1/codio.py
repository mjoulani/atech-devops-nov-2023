a=[
  {
    "id": 1,
    "num": "001",
    "name": "Bulbasaur",
    "img": "http://www.serebii.net/pokemongo/pokemon/001.png",
    "type": [
      "Grass",
      "Poison"
    ],
    "height": 0.71,
    "weight": 6.9,
    "candy": "Bulbasaur Candy",
    "candy_count": 25,
    "egg": "2 km",
    "spawn_chance": 0.69,
    "avg_spawns": 69,
    "spawn_time": "20:00",
    "multipliers": [
      1.58
    ],
    "weaknesses": [
      "Fire",
      "Ice",
      "Flying",
      "Psychic",
      "Water"
    ],
    "next_evolution": [
      {
        "num": "002",
        "name": "Ivysaur"
      },
      {
        "num": "003",
        "name": "Venusaur"
      }
    ]
  }
]
# print(list(map(lambda s:p["name"] for p in a if "Water" in p["weaknesses"] ,a)))
# print([p["name"] for p in a if "Water" in p["weaknesses"]])
 