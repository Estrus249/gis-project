@echo off
chcp 65001 > nul
echo ==================================
echo       开发环境自检脚本
echo ==================================

echo.
echo [1/4] Node.js 版本:
node -v 2>nul
if %errorlevel% neq 0 echo ❌ 未安装 Node.js

echo.
echo [2/4] Python 版本:
python --version 2>nul
if %errorlevel% neq 0 echo ❌ 未安装 Python

echo.
echo [3/4] Java 版本:
java -version 2>nul
if %errorlevel% neq 0 echo ❌ 未安装 Java

echo.
echo [4/4] Git 版本:
git --version 2>nul
if %errorlevel% neq 0 echo ❌ 未安装 Git

echo.
echo ==================================
echo 按任意键退出...
pause > nul