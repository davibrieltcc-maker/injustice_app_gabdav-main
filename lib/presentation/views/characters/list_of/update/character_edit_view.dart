import 'package:flutter/material.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../widgets/account_attribute_card.dart';

class CharacterEditView extends StatefulWidget {
  final Character character;

  const CharacterEditView({super.key, required this.character});

  @override
  State<CharacterEditView> createState() => _CharacterEditViewState();
}

class _CharacterEditViewState extends State<CharacterEditView> {
  late TextEditingController _nameController;

  late CharacterClass selectedClass;
  late CharacterRarity selectedRarity;
  late CharacterAlignment selectedAlignment;

  late int level;
  late int attack;
  late int health;
  late int stars;
  late int threat;

  @override
  void initState() {
    super.initState();

    final c = widget.character;
    _nameController = TextEditingController(text: c.name);
    selectedClass = c.characterClass;
    selectedRarity = c.rarity;
    selectedAlignment = c.alignment;
    level = c.level;
    attack = c.attack;
    health = c.health;
    stars = c.stars;
    threat = c.threat;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.character.copyWith(
      name: _nameController.text.trim(),
      characterClass: selectedClass,
      rarity: selectedRarity,
      alignment: selectedAlignment,
      level: level,
      attack: attack,
      health: health,
      stars: stars,
      threat: threat,
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Personagem')),
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField(
                      initialValue: selectedClass,
                      decoration: const InputDecoration(labelText: 'Classe'),
                      items: CharacterClass.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedClass = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField(
                      initialValue: selectedRarity,
                      decoration: const InputDecoration(labelText: 'Raridade'),
                      items: CharacterRarity.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedRarity = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField(
                      initialValue: selectedAlignment,
                      decoration: const InputDecoration(labelText: 'Alinhamento'),
                      items: CharacterAlignment.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedAlignment = v!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AccountAttributeCard(
              icon: Icons.star,
              iconColor: Theme.of(context).colorScheme.primary,
              label: 'Level',
              hint: '[1, 80]',
              minValue: 1,
              maxValue: 80,
              value: level,
              onChanged: (v) => setState(() => level = v),
            ),
            const SizedBox(height: 1),
            AccountAttributeCard(
              icon: Icons.sports_martial_arts,
              iconColor: Colors.red,
              label: 'Ataque',
              hint: '[0, 99999]',
              minValue: 0,
              maxValue: 99999,
              value: attack,
              onChanged: (v) => setState(() => attack = v),
            ),
            const SizedBox(height: 1),
            AccountAttributeCard(
              icon: Icons.favorite,
              iconColor: Colors.green,
              label: 'Vida',
              hint: '[0, 99999]',
              minValue: 0,
              maxValue: 99999,
              value: health,
              onChanged: (v) => setState(() => health = v),
            ),
            const SizedBox(height: 1),
            AccountAttributeCard(
              icon: Icons.warning_amber,
              iconColor: Colors.orange,
              label: 'Ameaça',
              hint: '[0, 99999]',
              minValue: 0,
              maxValue: 99999,
              value: threat,
              onChanged: (v) => setState(() => threat = v),
            ),
            const SizedBox(height: 1),
            AccountAttributeCard(
              icon: Icons.grade,
              iconColor: Colors.amber,
              label: 'Estrelas',
              hint: '[1, 14]',
              minValue: 1,
              maxValue: 14,
              value: stars,
              onChanged: (v) => setState(() => stars = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
