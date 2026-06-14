import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import '../../../../../core/theme/app_theme.dart';
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
  late final TextEditingController _levelController;
  late final TextEditingController _attackController;
  late final TextEditingController _healthController;
  late final TextEditingController _threatController;
  late final TextEditingController _starsController;

  CharacterClass selectedClass = CharacterClass.poderoso;
  CharacterRarity selectedRarity = CharacterRarity.prata;
  CharacterAlignment selectedAlignment = CharacterAlignment.heroi;

  // Variáveis para armazenar os valores numéricos
  int level = 1;
  int attack = 10;
  int health = 10;
  int stars = 1;
  int threat = 0;

  @override
  void initState() {
    super.initState();
    
    // 1. Identifica se é edição ou criação
    final isEditing = widget.character != null;
    
    _nameController = TextEditingController(text: widget.character?.name ?? '');
    
    if (isEditing) {
      selectedClass = widget.character!.characterClass;
      selectedRarity = widget.character!.rarity;
      selectedAlignment = widget.character!.alignment;
      level = widget.character!.level;
      attack = widget.character!.attack;
      health = widget.character!.health;
      stars = widget.character!.stars;
      threat = widget.character!.threat;
    }

    _levelController = TextEditingController(text: level.toString());
    _attackController = TextEditingController(text: attack.toString());
    _healthController = TextEditingController(text: health.toString());
    _threatController = TextEditingController(text: threat.toString());
    _starsController = TextEditingController(text: stars.toString());
  }

  int _readInt(TextEditingController controller, {required int fallback}) {
    return int.tryParse(controller.text) ?? fallback;
  }

  String? _validateRange(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return '$label inválido';
    if (parsed < min || parsed > max) return '$label deve estar entre $min e $max';
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    level = _readInt(_levelController, fallback: 1);
    attack = _readInt(_attackController, fallback: 10);
    health = _readInt(_healthController, fallback: 10);
    threat = _readInt(_threatController, fallback: 0);
    stars = _readInt(_starsController, fallback: 1);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    required int min,
    required int max,
  }) {
    return InputTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => _validateRange(
        value,
        label: label,
        min: min,
        max: max,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Define os textos baseados no estado (Edição vs Criação)
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
              Card(
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    children: [
                      _numberField('Level', _levelController, min: 1, max: 80),
                      const SizedBox(height: AppSpacing.md),
                      _numberField('Ataque', _attackController, min: 0, max: 99999),
                      const SizedBox(height: AppSpacing.md),
                      _numberField('Vida', _healthController, min: 0, max: 99999),
                      const SizedBox(height: AppSpacing.md),
                      _numberField('Ameaça', _threatController, min: 0, max: 99999),
                      const SizedBox(height: AppSpacing.md),
                      _numberField('Estrelas', _starsController, min: 1, max: 14),
                    ],
                  ),
                ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _attackController.dispose();
    _healthController.dispose();
    _threatController.dispose();
    _starsController.dispose();
    super.dispose();
  }
}