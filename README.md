# Pokédex

Aplicativo em **Flutter** que reúne os dados da [PokéAPI](https://pokeapi.co) em uma Pokédex navegável: Pokémon, golpes, habilidades, itens, locais, jogos e mais. Roda na **web** e no **Android**.

> Projeto acadêmico, sem fins lucrativos. Pokémon e seus nomes são marcas de Nintendo, Game Freak e Creatures Inc.

<!-- Adicione aqui capturas de tela, por exemplo:
![Tela inicial](docs/home.png)
-->

## Funcionalidades

- **Tela inicial** com os grupos da API, busca global (Pokémon, golpes, itens e habilidades) e seletor de idioma.
- **Splash screen** nativa (Android e web) seguida de uma animação da pokébola, que pré-carrega a primeira página de Pokémon.
- **Tema escuro** com cabeçalhos vermelhos, cartões arredondados e cores por tipo.
- **Busca em todas as listas**, por nome ou número.
- **Textos traduzíveis**: o conteúdo vindo da API pode ser exibido em outros idiomas (usa o endpoint `/language`). O que não existir no idioma escolhido aparece em inglês.

### O que cada grupo traz

| Grupo | Conteúdo |
| --- | --- |
| **Pokémon** | Lista de Pokémon, habilidades, tipos, status, naturezas, grupos de ovo, características, habitats e status do Pokéathlon |
| **Golpes** | Lista com scroll infinito e página de cada golpe |
| **Itens** | Lista de todos os itens, com imagem, efeito e quais Pokémon os seguram |
| **Berries** | Lista e página com crescimento, sabores e tipo do Natural Gift |
| **Máquinas** | TMs, HMs e TRs, com o golpe que cada uma ensina em cada jogo |
| **Locais** | Regiões, localizações, áreas e Pal Park, com os Pokémon encontrados |
| **Encontros** | Métodos de encontro e condições (horário, enxame, rádio...) |
| **Evolução** | Variáveis (condições) e gatilhos de evolução |
| **Jogos** | Gerações, jogos e Pokédexes (uma página por Pokédex) |
| **Concursos** | Tipos de concurso e efeitos (normais e Super Contest) |
| **Moedas** | Lista de moedas |

### Página do Pokémon

Cabeçalho com a cor do tipo, seletor de formas (Mega, regionais, Gigantamax) e sete abas:

1. **Sobre**: espécie, altura, peso, habilidades, grupos de ovo, gênero, taxa de crescimento e habitat.
2. **Status**: barras coloridas por faixa de valor e fraquezas e resistências.
3. **Pokédex**: número em cada Pokédex e os textos por jogo.
4. **Evolução**: cadeia de evolução.
5. **Onde achar**: encontros por jogo, com método, nível, chance e condições.
6. **Golpes**: golpes do Pokémon.
7. **Galeria**: sprites.

Tipos, status, habilidades, grupos de ovo, habitat, locais e condições são **links** para as suas próprias páginas.

## Tecnologias

- [Flutter](https://flutter.dev) 3.13 ou superior e Dart 3
- [`http`](https://pub.dev/packages/http) para as requisições
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) para guardar o idioma escolhido
- [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) (dev) para a splash nativa
- Dados: [PokéAPI v2](https://pokeapi.co/docs/v2) · Sprites: [PokeAPI/sprites](https://github.com/PokeAPI/sprites)

## Como rodar

Pré-requisitos: [Flutter instalado](https://docs.flutter.dev/get-started/install) (`flutter doctor` sem erros para a plataforma desejada).

```bash
git clone <url-do-repositorio>
cd pokedex
flutter pub get
```

**Web**

```bash
flutter run -d chrome
```

**Android** (aparelho ou emulador)

```bash
flutter devices                 # veja o id do aparelho
flutter run -d <id-do-aparelho>
```

**Gerar o APK**

```bash
flutter build apk --release
# saída: build/app/outputs/flutter-apk/app-release.apk
```

> **Windows:** o Gradle não compila projetos em pastas com caracteres acentuados no caminho (por exemplo `C:\Users\Usuário\...`). Mantenha o projeto em um caminho sem acentos, como `C:\dev\pokedex`.

### Ícone e splash

Os ícones (web e Android) já estão no projeto. Para regerar a splash nativa depois de mudar `flutter_native_splash.yaml`:

```bash
dart run flutter_native_splash:create
```

## Estrutura do projeto

```
lib/
├── main.dart            # ponto de entrada, tema e splash
├── theme/               # paleta de cores e ThemeData
├── models/              # classes de dados (Pokémon, Item, Move, Location...)
├── services/            # chamadas HTTP à PokéAPI
├── repositories/        # cache em memória sobre os services
├── screens/             # telas (listas e páginas de detalhe)
├── widgets/             # componentes reutilizáveis
└── utils/               # rótulos, busca, cores de tipo e de status, idioma
```

### Organização do código

Cada grupo da API segue o mesmo caminho: **service** (busca o JSON) → **model** (converte) → **repository** (guarda em cache) → **screen** (mostra).

- **Cache em memória**: voltar para uma tela já vista é instantâneo. Uma requisição que falha não fica guardada, então "Tentar novamente" funciona.
- **Carregamento sob demanda**: as listas grandes (golpes, itens, Pokémon) montam só o que aparece na tela. As páginas de detalhe carregam cada seção de forma independente, e se uma falha, as outras continuam.
- **Busca local**: a lista completa de nomes é baixada uma vez, na primeira busca, e filtrada no aparelho. Os detalhes de cada resultado só carregam quando ele aparece.
- **Componentes compartilhados**: `NamedRefListScreen` (lista padrão com busca), `AsyncPage` (página com carregamento e erro), `PokeTile`, `ChipsSection` e `ListSearchField`.

## Limitações conhecidas

- **Interface em português**: botões, títulos e rótulos do app não são traduzidos. O seletor de idioma afeta só os textos vindos da API.
- **Nomes nas listas**: Pokémon, golpes e itens aparecem pelo identificador da API (`thunder-punch` → "Thunder Punch"), sem tradução.
- **Cobertura da API**: a PokéAPI tem bem mais conteúdo em inglês do que em outros idiomas, e alguns dados são incompletos (encontros dos jogos mais novos, por exemplo).
- **Chances de encontro**: a API lista uma entrada por nível e condição. O app combina as entradas para não passar de 100% e omite o percentual onde a API não tem taxa real (como em Let's Go).
- **Limite de requisições**: a PokéAPI limita o número de pedidos. Se aparecer um erro de excesso de requisições, aguarde um instante e tente de novo.

## Créditos

- [PokéAPI](https://pokeapi.co) e seus colaboradores, pelos dados e sprites.
- Pokémon © Nintendo, Game Freak e Creatures Inc.