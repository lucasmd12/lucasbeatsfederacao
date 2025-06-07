#!/bin/bash

echo "=== VALIDANDO ESTRUTURA DO PROJETO ==="

# Verificar arquivos essenciais
files_to_check=(
  "pubspec.yaml"
  "android/app/build.gradle"
  "android/build.gradle"
  "android/gradle.properties"
  "android/app/src/main/AndroidManifest.xml"
  "lib/main.dart"
)

for file in "${files_to_check[@]}"; do
  if [ -f "$file" ]; then
    echo "✓ $file existe"
  else
    echo "✗ $file está faltando"
  fi
done

# Verificar permissões
echo "Verificando permissões..."
if grep -q "RECORD_AUDIO" android/app/src/main/AndroidManifest.xml; then
  echo "✓ Permissão RECORD_AUDIO encontrada"
else
  echo "✗ Permissão RECORD_AUDIO não encontrada"
fi

if grep -q "INTERNET" android/app/src/main/AndroidManifest.xml; then
  echo "✓ Permissão INTERNET encontrada"
else
  echo "✗ Permissão INTERNET não encontrada"
fi

echo "=== VALIDAÇÃO CONCLUÍDA ==="

