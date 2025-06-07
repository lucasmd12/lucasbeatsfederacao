#!/bin/bash

echo "=== EXECUTANDO TESTES AUTOMATIZADOS ==="

# Testes unitários
echo "Executando testes unitários..."
flutter test

# Análise de código
echo "Analisando código..."
flutter analyze

# Verificar dependências
echo "Verificando dependências..."
flutter pub deps

# Teste de build
echo "Testando build..."
flutter build apk --debug --target-platform android-arm64

echo "=== TESTES CONCLUÍDOS ==="

