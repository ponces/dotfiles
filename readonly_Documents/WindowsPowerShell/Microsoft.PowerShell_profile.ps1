oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/robbyrussell.omp.json" | Invoke-Expression
Import-Module "$env:APPDATA/posh-git/src/posh-git.psd1"

mise activate pwsh | Out-String | Invoke-Expression

function cdown() { cd $env:USERPROFILE/Downloads }
function cgit() { cd $env:USERPROFILE/Git }
function md5sum { Get-FileHash -Path $args[0] -Algorithm MD5 | Select-Object -ExpandProperty Hash }
function sha1sum { Get-FileHash -Path $args[0] -Algorithm SHA1 | Select-Object -ExpandProperty Hash }
function sha256sum { Get-FileHash -Path $args[0] -Algorithm SHA256 | Select-Object -ExpandProperty Hash }
function sshcode() { code --remote ssh-remote+root@ubuild01.ponces.dev @Args }
function unzip() { Expand-Archive -Path $args[0] -DestinationPath $(if ($args[1]) { $args[1] } else { Split-Path $args[0] -Parent }) }
