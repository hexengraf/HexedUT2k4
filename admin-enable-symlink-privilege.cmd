cd %TEMP%
secedit /export /cfg secpol.txt
powershell -NoProfile -Command "$u=whoami;$p='secpol.txt';$c=Get-Content $p;$c=$c|%{if($_ -match '^SeCreateSymbolicLinkPrivilege\s*=' -and $_ -notmatch [regex]::Escape($u)){$_+','+$u}else{$_}};Set-Content $p $c"
secedit /configure /db C:\Windows\Security\Local.sdb /cfg secpol.txt /areas USER_RIGHTS
