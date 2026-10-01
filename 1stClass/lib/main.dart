import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Um personagem da Turma do Cocoricó.
class Character {
  final String name;
  final String description;
  final String? imageUrl;

  const Character({
    required this.name,
    required this.description,
    this.imageUrl,
  });
}

/// Lista de personagens baseada em https://cocorico.fandom.com/pt-br/wiki/Lista_de_Personagens 
/// e mais outros a fora q eu gostava quando era criança

const List<Character> characters = [
  Character(
    name: 'Júlio',
    description:
        'Personagem principal, muito simpático e bem-humorado. Vive '
        'aventuras na fazenda com seus amigos.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/0/0c/Julio.png/revision/latest?cb=20201030143932&path-prefix=pt-br',
  ),
  Character(
    name: 'João',
    description: 'Primo moderno de Júlio.',
    imageUrl: 'https://assets.mycast.io/actor_images/actor-joao-cocorico-727094_large.jpg',
  ),
  Character(
    name: 'Alípio',
    description: 'Cavalo atrapalhado da fazenda.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/9/9b/Alipio.png/revision/latest?cb=20201030150103&path-prefix=pt-br',
  ),
  Character(
    name: 'Lola',
    description:
        'A galinha mais esperta da fazenda, que já foi uma grande '
        'cantora em um circo.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/e/ef/Lola_do_cocoricó_.png/revision/latest?cb=20230925000245&path-prefix=pt-br',
  ),
  Character(
    name: 'Zazá',
    description: 'A mais velha das galinhas e, às vezes, um pouco rabugenta.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/d/d2/Zazá.png/revision/latest?cb=20230619053819&path-prefix=pt-br',
  ),
  Character(
    name: 'Lilica',
    description:
        'Brincalhona, é a mais nova das galinhas e ainda está na '
        'pré-escola.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/1/1e/Lilica.png/revision/latest?cb=20230619052621&path-prefix=pt-br',
  ),
  Character(
    name: 'Mimosa',
    description: 'Muito simpática, é quem fornece leite à fazenda.',
    imageUrl: 'https://i.ytimg.com/vi/UbvrTSrXLtU/maxresdefault.jpg',
  ),
  Character(
    name: 'Caco',
    description: 'Apesar de implicante às vezes, é muito amigo.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/3/3c/Caco.jpg/revision/latest?cb=20230124202241&path-prefix=pt-br',
  ),
  Character(
    name: 'Oriba',
    description: 'Indiazinha, amiga do menino Júlio.',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTc3_sp84pSjWoSzJhoiEscHFHQIB5Rh091tLhILvBNqKGDpjtAGZ9OLgDW&s=10',
  ),
  Character(
    name: 'Toquinho',
    description: 'Morcego amigo da turma.',
    imageUrl: 'https://i.ytimg.com/vi/07uslTPDFYE/hq720.jpg?sqp=-oaymwE7CK4FEIIDSFryq4qpAy0IARUAAAAAGAElAADIQj0AgKJD8AEB-AG-B4AC0AWKAgwIABABGH8gNygTMA8=&rs=AOn4CLAN6BGFvq5qvXBKPPv5Om-2Gx54SQ',
  ),
  Character(
    name: 'Astolfo',
    description: 'Porquinho ainda bebê, muito divertido.',
    imageUrl: 'https://static.wikia.nocookie.net/cocorico/images/9/90/Astolfinho.png/revision/latest?cb=20230925000532&path-prefix=pt-br',
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocoricó',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.amber[50],
        useMaterial3: true,
      ),
      home: const CharacterListPage(),
    );
  }
}

class CharacterListPage extends StatelessWidget {
  const CharacterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Cocoricó'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: characters.length,
        separatorBuilder: (_, _) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final character = characters[index];
          return CharacterCard(character: character);
        },
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CharacterAvatar(character: character),
        title: Text(
          character.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(character.description),
        ),
      ),
    );
  }
}

/*  Avatar do personagem: mostra a imagem de rede quando disponível,
um indicador de carregamento enquanto ela baixa, e um ícone de
fallback caso não haja imagem ou o carregamento falhe.*/
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    const double size = 64;

    if (character.imageUrl == null) {
      return const _AvatarFallback(size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        character.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.fill,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: size,
            height: size,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const _AvatarFallback(size: size);
        },
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.amber[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.pets, color: Colors.brown),
    );
  }
}
