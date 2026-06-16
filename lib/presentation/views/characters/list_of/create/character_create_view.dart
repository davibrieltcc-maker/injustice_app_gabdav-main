import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../widgets/account_attribute_card.dart';
import '../../../../widgets/input_text_field.dart';

class CharacterCreateView extends StatefulWidget {
  final Character? character;
  const CharacterCreateView({super.key, this.character});

  @override
  State<CharacterCreateView> createState() => _CharacterCreateViewState();
}

class _CharacterCreateViewState extends State<CharacterCreateView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  int level = 1;
  int attack = 10;
  int health = 10;
  int stars = 1;
  int threat = 0;

  @override
  void initState() {
    super.initState();
    final c = widget.character;
    _nameController = TextEditingController(text: c?.name ?? '');

    if (c != null) {
      selectedClass = c.characterClass;
      selectedRarity = c.rarity;
      selectedAlignment = c.alignment;
      level = c.level;
      attack = c.attack;
      health = c.health;
      stars = c.stars;
      threat = c.threat;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final character = Character(
        id: widget.character?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        characterClass: selectedClass,
        rarity: selectedRarity,
        level: level,
        threat: threat,
        attack: attack,
        health: health,
        stars: stars,
        alignment: selectedAlignment,
        createdAt: widget.character?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.pop(context, character);
    } on ArgumentError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.character != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Personagem' : 'Criar Personagem'),
      ),
      body: Padding(
        padding: AppSpacing.paddingMd,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    children: [
                      InputTextField(
                        label: 'Nome',
                        controller: _nameController,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'O nome é obrigatório';
                          if (text.length < 2) return 'Nome deve ter ao menos 2 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<CharacterClass>(
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
                      DropdownButtonFormField<CharacterRarity>(
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
                      DropdownButtonFormField<CharacterAlignment>(
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
                child: Text(isEditing ? 'Atualizar Dados' : 'Salvar Personagem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
