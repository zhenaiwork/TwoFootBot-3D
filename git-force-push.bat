@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================================
echo 脚本: git-force-push.bat
echo 功能: 将本地分支强制推送到远程，让远程与本地完全一致
echo ============================================================

REM ---------- 检查是否在 Git 仓库 ----------
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [错误] 当前目录不是 Git 仓库
    exit /b 1
)

REM ---------- 获取当前分支 ----------
for /f %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
if "%CURRENT_BRANCH%"=="" (
    echo [错误] 当前处于 HEAD 分离状态，请先切换到具体分支。
    exit /b 1
)
echo [信息] 当前分支：%CURRENT_BRANCH%

REM ---------- 拉取远程最新信息 ----------
echo [信息] 正在获取远程最新引用...
git fetch origin

REM ---------- 检查本地是否有未提交更改 ----------
git diff --quiet >nul 2>&1
if errorlevel 1 (
    echo [警告] 检测到本地有未提交的更改（已暂存或未暂存）。
    echo [警告] 这些更改不会被推送，但会保留在工作区。
    set /p CONTINUE="是否继续强制推送？(y/N): "
    if /i not "!CONTINUE!"=="y" (
        echo [信息] 操作已取消。
        exit /b 0
    )
)

REM ---------- 检查本地是否落后于远程 ----------
for /f %%i in ('git rev-list --count @..@{u} 2^>nul') do set AHEAD=%%i
if not defined AHEAD set AHEAD=0
if %AHEAD% gtr 0 (
    echo [警告] 远程有 %AHEAD% 个新提交，本地落后于远程。
    echo [警告] 强制推送会覆盖这些提交，请确认这不是他人刚提交的代码！
)

REM ---------- 选择推送模式 ----------
echo 请选择推送模式：
echo   1) --force-with-lease (推荐，安全覆盖)
echo   2) --force          (强制覆盖，极度危险)
set /p MODE="请输入数字 (1 或 2，默认 1): "
if "%MODE%"=="" set MODE=1
if "%MODE%"=="2" (
    set FORCE_FLAG=--force
    echo [警告] 您选择了 --force，这将无条件覆盖远程分支！
) else (
    set FORCE_FLAG=--force-with-lease
    echo [信息] 您选择了 --force-with-lease，安全模式。
)

REM ---------- 最终确认 ----------
set /p CONFIRM="确认将本地分支 %CURRENT_BRANCH% 强制推送到远程？请输入 'yes' 继续: "
if /i not "%CONFIRM%"=="yes" (
    echo [信息] 操作已取消。
    exit /b 0
)

REM ---------- 执行推送 ----------
echo [信息] 正在执行: git push %FORCE_FLAG% origin %CURRENT_BRANCH%
git push %FORCE_FLAG% origin %CURRENT_BRANCH%
if errorlevel 1 (
    echo [错误] 推送失败，请检查网络或权限。
    exit /b %errorlevel%
)

echo [成功] 推送完成！远程 origin/%CURRENT_BRANCH% 已与本地保持一致。
endlocal
