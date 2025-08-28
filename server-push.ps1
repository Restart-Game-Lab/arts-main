<#
Usage:
  pwsh ./server-push.ps1               # 使用默认主机别名与路径（示例）
  pwsh ./server-push.ps1 -TargetHost myhost -RemotePath /var/www/site
  pwsh ./server-push.ps1 -TargetHost myhost -RemotePath /var/www/site -Force  # 跳过确认

说明：
  - 脚本会先运行 `npm run build`（生成 dist/），然后通过 ssh 清理远端目录，并使用 scp 复制文件，最后在远端修改属主。
  - 默认主机 `ARTS-R2-JP` 与路径为示例，运行前请替换为你自己的主机别名/地址与目标路径，避免误删他人数据。
#>

param(
    [string]$TargetHost = 'ARTS-R2-JP',
    [string]$RemotePath = '/usr/web-server/sites/arts-home/index',
    [switch]$Force    # 跳过确认提示
)

# 日志函数
function Write-Info([string]$msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn([string]$msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err([string]$msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 在退出时显示耗时
$scriptStartTime = Get-Date
trap { 
    $duration = (Get-Date) - $scriptStartTime
    Write-Info "总耗时: $($duration.TotalSeconds.ToString('0.00'))s"
}

Write-Info "目标主机: $TargetHost"
Write-Info "远程路径: $RemotePath"

# 简单依赖检查
foreach ($bin in @('npm','ssh','scp')) {
    if (-not (Get-Command $bin -ErrorAction SilentlyContinue)) {
        Write-Warn "未在 PATH 中找到 '$bin'。在某些 Windows 环境下，请确保安装并在 pwsh 中可用（Git for Windows / OpenSSH）。"
    }
}

# 检查依赖并运行构建
Write-Info "检查环境与依赖..."
if (-not (Test-Path -Path './package.json')) {
    Write-Err "未找到 package.json，请确保在正确的项目目录中运行此脚本。"
    exit 1
}

if (-not (Test-Path -Path './node_modules')) {
    Write-Info "正在安装依赖（node_modules 不存在）..."
    & npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Err "安装依赖失败，退出。"
        exit $LASTEXITCODE
    }
}

Write-Info "运行构建：npm run build"
try {
    # 通过 cmd.exe 调用 npm 以避免解析问题
    $buildCmd = "cmd.exe /c `"npm run build`""
    Write-Info "执行：$buildCmd"
    
    $result = Invoke-Expression -Command $buildCmd 2>&1
    $exitCode = $LASTEXITCODE
    
    # 输出构建结果
    $result | ForEach-Object { Write-Host $_ }
    
    if ($exitCode -ne 0) {
        Write-Err "构建失败，退出。退出码：$exitCode"
        exit $exitCode
    }
}
catch {
    Write-Err "执行 npm 命令时发生错误：$($_.Exception.Message)"
    exit 1
}

# 校验 dist
if (-not (Test-Path -Path './dist')) {
    Write-Err "未找到 dist/ 目录。构建可能失败或输出路径被更改。"
    exit 1
}

# 确认 destructive 操作
if (-not $Force) {
    $ans = Read-Host "将删除并覆盖远程目录 '$RemotePath' 上的内容。是否继续？输入 y 确认"
    if ($ans -ne 'y' -and $ans -ne 'Y') {
        Write-Info "已取消部署。"
        exit 0
    }
}
        
# 远程操作
Write-Info "清理远端目录: ssh $TargetHost rm -rf $RemotePath/*"
& ssh $TargetHost "rm -rf $RemotePath/*"
if ($LASTEXITCODE -ne 0) { Write-Warn "远端清理命令返回非零码：$LASTEXITCODE" }

# 上传文件
Write-Info "上传文件到 ${TargetHost}:$RemotePath ..."
& scp -r -p -C ".\dist\*" "${TargetHost}:$RemotePath"
if ($LASTEXITCODE -ne 0) {
    Write-Err "scp 上传失败，退出。错误代码：$LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Info "调整远端权限: ssh $TargetHost chown -R 1000:1000 $RemotePath/*"
& ssh $TargetHost "chown -R 1000:1000 $RemotePath/*"
if ($LASTEXITCODE -ne 0) { Write-Warn "chown 返回非零码：$LASTEXITCODE" }

Write-Info "部署完成。"