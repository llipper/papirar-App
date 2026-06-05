@echo off
echo Restaurando os textos dos JSONs em assets/json/ para o estado anterior...
cd /d C:\Users\dev\Documents\documentos\papirar
git checkout -- assets/json/
echo.
echo Restore concluido.
echo Verifique com: git status assets/json/
echo.
pause
echo Agora rode flutter clean e flutter pub get no seu terminal, depois reinstale o app para ver as mudancas.
pause