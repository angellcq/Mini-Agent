# ============================================================
# Mini-Agent 启动器 (Windows PowerShell)
#
# 用法（在本目录打开 PowerShell 后运行）:
#   .\start.ps1                            # 交互模式，工作区 .\workspace
#   .\start.ps1 -Task "看下项目结构"         # 单次任务模式，跑完退出
#   .\start.ps1 -Workspace .\sandbox       # 指定工作区
#   .\start.ps1 -Log                       # 查看历史运行日志目录
#
# 交互模式使用 prompt_toolkit，必须是真实终端窗口，不能在管道/重定向里跑。
# ============================================================

param(
    [string]$Task = "",
    [string]$Workspace = "workspace",
    [switch]$Log
)

$ErrorActionPreference = "Stop"
$RepoRoot = $PSScriptRoot
if (-not $RepoRoot) { $RepoRoot = (Get-Location).Path }
Set-Location $RepoRoot

if (-not $Workspace) { $Workspace = "workspace" }

# ---- 环境修正（三条都必须） ----
# 1) UTF-8：否则打印 emoji 时 GBK 编码崩溃
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

# 2) 主目录重定向：AgentLogger 写死 Path.home()/.mini-agent/log，
#    本机 C:\Users\Administrator\.mini-agent 建目录会 PermissionError WinError 5
$EnvHome = Join-Path (Split-Path $RepoRoot -Parent) ".home"
$env:USERPROFILE = $EnvHome
$env:HOMEDRIVE = (Split-Path $EnvHome -Qualifier)
$env:HOMEPATH = (Split-Path $EnvHome -NoQualifier)
New-Item -ItemType Directory -Force -Path $EnvHome | Out-Null

# 3) 工作区
$WsPath = Join-Path $RepoRoot $Workspace
New-Item -ItemType Directory -Force -Path $WsPath | Out-Null

$Py = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $Py)) {
    Write-Host "找不到虚拟环境: $Py" -ForegroundColor Red
    Write-Host "请先运行: uv sync" -ForegroundColor Yellow
    exit 1
}

# ---- 分发 ----
if ($Log) {
    & $Py -m mini_agent.cli log
}
elseif ($Task -ne "") {
    & $Py -m mini_agent.cli --workspace $WsPath --task $Task
}
else {
    Write-Host "Mini-Agent 交互模式" -ForegroundColor Cyan
    Write-Host "  工作区: $WsPath"
    Write-Host "  模型  : group/minimaxm3.1 @ http://127.0.0.1:3425"
    Write-Host "  命令  : /help  /clear  /history  /stats  /log  /exit"
    Write-Host ""
    & $Py -m mini_agent.cli --workspace $WsPath
}