## Injustice App (Flutter)
Aplicação desenvolvida em Flutter para gerenciamento de conta de jogador e personagens, com foco em cadastro, listagem, edição e exclusão de personagens, seguindo o padrão visual do projeto.

Tecnologias utilizadas
Flutter / Dart
go_router (navegação)
signals_flutter (estado reativo)
auto_injector (injeção de dependências)
shared_preferences (persistência local)
uuid (geração de identificadores)
Pré-requisitos (ambiente)
Antes de rodar, tenha instalado:

Flutter SDK (compatível com sdk: ^3.10.7)
Dart SDK (vem com Flutter)
Google Chrome (para execução web)
Git (opcional, para clonar e versionar)

# Como executar o projeto:

flutter clean

flutter pub get

flutter run -d chrome

# Comandos úteis

Analisar o código:
flutter analyze

Rodar testes:
flutter test

Verificar dispositivos disponíveis:
flutter devices

# Como testar rapidamente (fluxo principal)
Criar/abrir conta.
Ir para a tela de personagens.
Cadastrar um personagem.
Editar um personagem (arrastando para a direita).
Excluir um personagem (arrastando para a esquerda e confirmando).
Recarregar a página e validar se as alterações (update/delete) persistiram.
