# Configure firewall to allow WinRM HTTP connections.
$fwtest1 = netsh advfirewall firewall show rule name="Allow WinRM HTTP"
$fwtest2 = netsh advfirewall firewall show rule name="Allow WinRM HTTP" profile=any
If ($fwtest1.count -lt 5)
{
    echo "Adding firewall rule to allow WinRM HTTP."
    netsh advfirewall firewall add rule profile=any name="Allow WinRM HTTP" dir=in localport=5985 protocol=TCP action=allow
}
ElseIf (($fwtest1.count -ge 5) -and ($fwtest2.count -lt 5))
{
    echo "Updating firewall rule to allow WinRM HTTP for any profile."
    netsh advfirewall firewall set rule name="Allow WinRM HTTP" new profile=any
}
Else
{
    echo "Firewall rule already exists to allow WinRM HTTP."
}

# Configure firewall to allow WinRM HTTPS connections.
$fwtest1 = netsh advfirewall firewall show rule name="Allow WinRM HTTPS"
$fwtest2 = netsh advfirewall firewall show rule name="Allow WinRM HTTPS" profile=any
If ($fwtest1.count -lt 5)
{
    echo "Adding firewall rule to allow WinRM HTTPS."
    netsh advfirewall firewall add rule profile=any name="Allow WinRM HTTPS" dir=in localport=5986 protocol=TCP action=allow
}
ElseIf (($fwtest1.count -ge 5) -and ($fwtest2.count -lt 5))
{
    echo "Updating firewall rule to allow WinRM HTTPS for any profile."
    netsh advfirewall firewall set rule name="Allow WinRM HTTPS" new profile=any
}
Else
{
    echo "Firewall rule already exists to allow WinRM HTTPS."
}

# Find and start the WinRM service.
echo "Verifying WinRM service."
If (!(Get-Service "WinRM"))
{
    Throw "Unable to find the WinRM service."
}
ElseIf ((Get-Service "WinRM").Status -ne "Running")
{
    echo "Starting WinRM service."
    Start-Service -Name "WinRM" -ErrorAction Stop
}

# WinRM should be running; check that we have a PS session config.
If (!(Get-PSSessionConfiguration -Verbose:$false) -or (!(Get-ChildItem WSMan:\localhost\Listener)))
{
	echo "Enabling PS Remoting without checking Network profile."
	Enable-PSRemoting -SkipNetworkProfileCheck -Force -ErrorAction Stop
}
Else
{
    echo "PS Remoting is already enabled."
}

# Check for service basic authentication.
$basicServiceAuthSetting = Get-ChildItem WSMan:\localhost\Service\Auth | Where {$_.Name -eq "Basic"}
If (($basicServiceAuthSetting.Value) -eq $false)
{
    echo "Enabling basic service auth support."
    Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value $true
}
Else
{
    echo "Basic service auth is already enabled."
}

# Check for client basic authentication.
$basicClientAuthSetting = Get-ChildItem WSMan:\localhost\Client\Auth | Where {$_.Name -eq "Basic"}
If (($basicClientAuthSetting.Value) -eq $false)
{
    echo "Enabling basic client auth support."
    Set-Item -Path "WSMan:\localhost\Client\Auth\Basic" -Value $true
}
Else
{
    echo "Basic client auth is already enabled."
}

# Check for service Unencrypted.
$basicServiceUnencryptedSetting = Get-ChildItem WSMan:\localhost\Service | Where {$_.Name -eq "AllowUnencrypted"}
If (($basicServiceUnencryptedSetting.Value) -eq $false)
{
    echo "Enabling service Unencrypted support."
    Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value $true
}
Else
{
    echo "Basic service Unencrypted is already enabled."
}