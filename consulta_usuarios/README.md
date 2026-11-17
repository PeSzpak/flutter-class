# Aula 09: Consulta de Usuários + APK

Consome `https://jsonplaceholder.typicode.com/users` com o pacote `http` e mostra nome, e-mail e telefone de cada usuário.

- Indicador de carregamento enquanto a requisição está em andamento (`ConnectionState.waiting`).
- Erro de rede, código diferente de 200 ou JSON fora do formato: aviso com botão "Tentar de novo".
- Lista vazia: aviso próprio.
- Puxar a lista para baixo ou tocar no ícone do topo recarrega.

## Entregáveis

1. Código-fonte: `lib/` (`api_service.dart`, `usuario.dart`, `main.dart`).
2. Capturas de tela: [`prints/`](prints). As de número 03 e 04 são do **APK release instalado no emulador Android** (com internet e sem internet).
3. APK: anexado na [release `consulta-usuarios-v1.0.0`](https://github.com/PeSzpak/flutter-class/releases/tag/consulta-usuarios-v1.0.0) do repositório.
4. Relato da compilação: abaixo.

## Relato do processo de compilação

1. **Biblioteca HTTP:** `flutter pub add http`.
2. **Permissão de internet:** `<uses-permission android:name="android.permission.INTERNET"/>` em `android/app/src/main/AndroidManifest.xml`. Sem ela, o app funciona em debug, mas a versão release não acessa a rede.
3. **Nome e identificador:** `android:label="Consulta de Usuários"` no manifesto; `applicationId = "br.senac.ads.consulta_usuarios"` em `android/app/build.gradle.kts`; versão `1.0.0+1` no `pubspec.yaml`.
4. **Testes:** `flutter test` (5 testes com respostas simuladas: sucesso, erro 500, falha de rede, lista vazia e JSON inválido).
5. **Build:** `flutter build apk --release`. Na primeira vez, o Gradle baixou o Android SDK Platform 36 e o Build-Tools 36 sozinho. Levou cerca de 1 min 40 s e gerou `build/app/outputs/flutter-apk/app-release.apk` (46,8 MB, com as arquiteturas arm64-v8a, armeabi-v7a e x86_64). O `flutter build apk --release --split-per-abi` geraria um APK menor por arquitetura.
6. **Conferência do pacote:** `aapt2 dump badging` confirmou o nome "Consulta de Usuários", o pacote `br.senac.ads.consulta_usuarios` e a permissão `INTERNET`.
7. **Instalação:** emulador Android 15 (API 35, arm64) criado com o `avdmanager`; `adb install app-release.apk`; o app abriu e listou os 10 usuários da API real. Com o Wi-Fi e os dados desligados (`adb shell svc wifi disable`), mostrou o aviso de falha de conexão.
8. **Assinatura:** o APK está assinado com a chave de debug, o padrão do Flutter. Serve para teste; para publicar na Play Store seria preciso criar uma chave própria (release signing) e gerar um `appbundle`.
