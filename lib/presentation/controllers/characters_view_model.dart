import '../../data/services/character_local_storage_interface.dart';
import '../../domain/facades/character_facade_usecases_interface.dart';
import '../commands/character_commands.dart';
import 'characters_commands_view_model.dart';
import 'characters_state_viewmodel.dart';

class CharactersViewModel {
  late final CharactersStateViewmodel _state;
  CharactersStateViewmodel get charactersState => _state;

  late final CharactersCommandsViewModel commands;

  final ICharacterLocalStorage _localStorage;

  CharactersViewModel(
    ICharacterFacadeUseCases facade,
    ICharacterLocalStorage localStorage,
  ) : _localStorage = localStorage {
    _state = CharactersStateViewmodel();

    commands = CharactersCommandsViewModel(
      state: _state,
      getAccountCommand: GetAllCharactersCommand(facade),
      createCharacterCommand: CreateCharacterCommand(facade),
      deleteCharacterCommand: DeleteCharacterCommand(facade),
      updateCharacterCommand: UpdateCharacterCommand(facade),
    );
  }

  /// Define a conta ativa antes de carregar personagens.
  /// Deve ser chamado na inicialização da tela de personagens.
  void initForAccount(String accountId) {
    _localStorage.setActiveAccount(accountId);
  }

  GetAllCharactersCommand get getAllCharactersCommand =>
      commands.getAllCharactersCommand;
  CreateCharacterCommand get createCharacterCommand =>
      commands.createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand =>
      commands.updateCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand =>
      commands.deleteCharacterCommand;
}
