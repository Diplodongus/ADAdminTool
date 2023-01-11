#########################################################################
# Original Authors: Rich Prescott, Skyler Hunter, Stilianos Daskalakis  #
# Rewritten 2023 for MECM/Modern AD Changes By: Tanner J. Brouillard    #
# Needed: ActiveDirectory Tools (Searching AD for users/computers)      #
# Added: RSAT Auto-Installer if RSAT is not installed on host computer. #
#########################################################################

############################
#### USER SEARCH FORM 2 ####
############################
Function FormUserSearch {

    # Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    $InitialFormWindowState2 = New-Object System.Windows.Forms.FormWindowState
    
    # -----------------------------------------------
    
    function SelectItem {
        $UserString = '$list4.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.SamAccountName}'
        $UserString2 = '$list4.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.DisplayName}'
        $Username = invoke-expression $UserString
        $Username2 = invoke-expression $UserString2
        $EDIPI = $UserName
        $form2.Close()
        $stBar1.text = "Loading user " + $UserName2 + " (...Please Wait)"
        UserSearch
    }
    
    $OnLoadForm_StateCorrection2 =
    {
        $form2.WindowState = $InitialFormWindowState2
    }
    
    $form2 = New-Object System.Windows.Forms.Form
    $form2.Text = "Loading..."
    $form2.Name = "form2"
    $form2.DataBindings.DefaultDataSourceUpdateMode = 0
    $form2.StartPosition = "CenterScreen"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 430
    $System_Drawing_Size.Height = 380
    $form2.ClientSize = $System_Drawing_Size
    $Form2.KeyPreview = $True
    $Form2.Add_KeyDown({ if ($_.KeyCode -eq "Escape") 
            { $Form2.Close() } })
    
    # Label User Search #
    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.TabIndex = 8
    $lblUser.TextAlign = 256
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 400
    $System_Drawing_Size.Height = 15
    $lblUser.Size = $System_Drawing_Size
    $lblUser.Text = "Double-click a user or hit enter to select it."
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10
    $System_Drawing_Point.Y = 10
    $lblUser.Location = $System_Drawing_Point
    $lblUser.DataBindings.DefaultDataSourceUpdateMode = 0
    $lblUser.Name = "lblusername"
    $lblUser.Visible = $false
    $form2.Controls.Add($lblUser)
    
    # Listview User Search #
    $list4 = New-Object System.Windows.Forms.ListView
    $list4.UseCompatibleStateImageBehavior = $False
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 410
    $System_Drawing_Size.Height = 330
    $list4.Size = $System_Drawing_Size
    $list4.DataBindings.DefaultDataSourceUpdateMode = 0
    $list4.Name = "list4"
    $list4.TabIndex = 2
    $list4.anchor = "right, top, bottom, left"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10
    $System_Drawing_Point.Y = 40
    $list4.View = [System.Windows.Forms.View]"Details"
    $list4.FullRowSelect = $true
    $list4.GridLines = $true
    $columnnames = "User", "EDIPI"
    $list4.Columns.Add("User", 300) | out-null
    $list4.Columns.Add("EDIPI", 95) | out-null
    $list4.Location = $System_Drawing_Point
    $list4.add_DoubleClick({ SelectItem })
    $list4.Add_KeyDown({ if ($_.KeyCode -eq "Enter") 
            { SelectItem } })
    $form2.Controls.Add($list4)
    
    $progress2 = New-Object System.Windows.Forms.ProgressBar
    $progress2.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 400
    $System_Drawing_Size.Height = 23
    $progress2.Size = $System_Drawing_Size
    $progress2.Step = 1
    $progress2.TabIndex = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 10 #120
    $System_Drawing_Point.Y = 10 #13
    $progress2.Location = $System_Drawing_Point
    $progress2.Name = "p1"
    $progress2.text = "Loading..."
    $form2.Controls.Add($progress2)
    
    ###################################
    #### POPULATE USER SEARCH LIST ####
    ###################################
    
    function updateUserlist {
        if (Get-ADUser -Filter "displayname -like '$findusername*'") {
            $Users = Get-ADUser -Filter "displayname -like '$findusername*'" -Properties * | Select-Object displayname, SamAccountName | Sort-Object displayname
            foreach ($User in $Users) {
            
                $i++
                [int]$pct = ($i / ($Users.displayname).count) * 100
                #update the progress bar
                $progress2.Value = $pct
    
                $text = ""
                $item2 = new-object System.Windows.Forms.ListViewItem($User.displayname)
    
                if ($null -eq $User.SamAccountName) {
                    $item2.SubItems.Add($text)
                }
                Else { $item2.SubItems.Add($User.SamAccountName) }
    
                $item2.Tag = $User
                $list4.Items.Add($item2) > $null
                Start-Sleep -Milliseconds 5
            } #End foreach
            $stBar1.text = "Select user..."
            $progress2.visible = $false
            $lbluser.visible = $true
            $form2.Text = "Select User"
        }
    
        elseif (Get-ADUser -Filter "SamAccountName -like '$findusername*'") {
            $Users = Get-ADUser -Filter "SamAccountName -like '$findusername*'" -Properties * | Select-Object displayname, SamAccountName | Sort-Object displayname
            foreach ($User in $Users) {
            
                $p++
                [int]$pct = ($p / ($Users.displayname).count) * 100
                #update the progress bar
                $progress2.Value = $pct
    
                $text = ""
                $item2 = new-object System.Windows.Forms.ListViewItem($User.displayname)
    
                if ($null -eq $User.SamAccountName) {
                    $item2.SubItems.Add($text)
                }
                Else { $item2.SubItems.Add($User.SamAccountName) }
    
                $item2.Tag = $User
                $list4.Items.Add($item2) > $null
                Start-Sleep -Milliseconds 5
            } #End foreach
            $stBar1.text = "Select user..."
            $progress2.visible = $false
            $lbluser.visible = $true
            $form2.Text = "Select User"
        }
    
        else {
            $vbmsg1 = $vbmsg.popup("Unable to find user with name or EDIPI: $findusername....", 0, "Error", 0)
            $stBar1.text = "Unable to find user..."
            $form2.Close()
        }
    } #End function updatepclist
    #Save the initial state of the form
    $InitialFormWindowState2 = $form2.WindowState
    #Init the OnLoad event to correct the initial state of the form
    $form2.add_Load($OnLoadForm_StateCorrection2)
    $form2.add_Load({ updateUserlist })
    #Show the Form
    $form2.ShowDialog() | Out-Null
    
}
################
#### FORM 1 ####
################
#Generated Form Function
function GenerateForm {
    
    # Import the Assemblies
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles();
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
    
    $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
    $vbmsg = new-object -comobject wscript.shell
    
    #Checks to see if user is admin
    Function IsAdmin {
        $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
        $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }
    
    ###########################
    #### START USER SEARCH ####
    ###########################
    $btn14_OnClick = 
    {
        $findusername = $txt1.text
        if ($findusername -eq "") {
            # FIXME: Remove $vbmsg1 = $vbmsg.popup("The username or EDIPI didn't load correctly, please try again.", 0, "Error", 0)
            $stBar1.text = "Error loading user..."
        }
        else {
            $lbl2.text = ""
            $lbl2.visible = $true
            HideUnusedItems
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched for user " + $txt1.text | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
            FormUserSearch
        }
    }
    
    ###################
    ### USER SEARCH ###
    ###################
    Function UserSearch {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
        [int]$pct = (0 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $findusername = $EDIPI
        [int]$pct = (1 / 10) * 100
        #update the progress bar
        $progress1.Value = $pct
        AutoOU
        $UserDots = Get-ADUser $findusername -Properties * | Select-Object -ExpandProperty cn
        $UserDot = $UserDots.Split(".") | Sort-Object | Select-Object -First 1
        $ReportedPCs = Get-ADComputer -Filter "Location -like '*$UserDot*'" -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object Name, OperatingSystem, OperatingSystemVersion, IPv4Address, Location | Out-String
        if ($null -eq (Get-ADUser $findusername -Property * | Select-Object -ExpandProperty userSMIMECertificate)) { $UserCert = "No" } else { $UserCert = "Yes" }
    
        $userlist = Get-ADUser $findusername -Property * | Select-Object *
        $lbl2.text += "`t`t`t`t`t  ~ " + $userlist.personalTitle + " " + $userlist.GivenName + " " + $userlist.Surname + "'s Account Information ~ `t" + "`n`n"
        $lbl2.text += "User:`t`t`t" + $userlist.DisplayName + "`n"
        $lbl2.text += "Title: `t`t`t" + $userlist.Title + "`n"
        $lbl2.text += "Service: `t`t" + $userlist.Company + "`n"
        [int]$pct = (2 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "Nationality: `t`t" + $userlist.extensionAttribute4 + "`n"
        $lbl2.text += "Login Name: `t`t" + $userlist.UserPrincipalName + "`n"
        $lbl2.text += "Created: `t`t" + $userlist.Created + "`n"
        [int]$pct = (3 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "Expiration: `t`t" + $userlist.AccountExpirationDate + "`n"
        $lbl2.text += "Modified: `t`t" + $userlist.Modified + "`n"
        $lbl2.text += "Last Logon: `t`t" + $userlist.LastLogonDate + "`n"
        $lbl2.text += "Logon Count: `t`t" + $userlist.LogonCount + "`n"
        [int]$pct = (4 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "Enabled: `t`t" + $userlist.Enabled + "`n"
        $lbl2.text += "Locked: `t`t" + $userlist.LockedOut + "`n"
        $lbl2.text += "Lockout Time: `t`t" + $userlist.LockOutTime + "`n"
        $lbl2.text += "EDIPI: `t`t`t" + $userlist.SamAccountName + "`n"
        [int]$pct = (5 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "IA Date: `t`t" + $userlist.iaTrainingDate + "`n"
        $lbl2.text += "Smartcard Logon: `t" + $userlist.SmartcardLogonRequired + "`n`n"
        $lbl2.text += "Account Notes: `t" + $userlist.Description + "`n"
        $lbl2.text += "Manager: `t`t" + ($userlist.Manager -replace '^CN=([^,]+),OU=.+$', '$1' | Out-string) + "`n`n"
        $lbl2.text += "OU Info: `t`t" + $userlist.DistinguishedName + "`n`n"
        $lbl2.text += "Security ID: `t`t" + $userlist.SID + "`n`n"
        $lbl2.text += "Primary Group: `t" + $userlist.PrimaryGroup + "`n`n"
        [int]$pct = (6 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "DSN: `t`t`t" + $userlist.OfficePhone + "`n"
        $lbl2.text += "Country: `t`t" + $userlist.Country + "`n"
        $lbl2.text += "Base: `t`t`t" + $userlist.City + "`n"
        $lbl2.text += "Street: `t`t" + $userlist.Street + "`n"
        [int]$pct = (7 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "Building: `t`t" + $userlist.BuildingName + "`n"
        $lbl2.text += "Room: `t`t" + $userlist.RoomNumber + "`n`n"
        $lbl2.text += "Email: `t`t`t" + $userlist.mail + "`n"
        $lbl2.text += "CHES Email: `t`t" + ($userlist.TargetAddress -replace "SMTP:", "") + "`n"
        [int]$pct = (8 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "Mailbox Created: `t" + $userlist.msExchWhenMailboxCreated + "`n"
        $lbl2.text += "Has Public Cert: `t" + $UserCert + "`n"
        $lbl2.text += "Hidden From GAL: `t" + $userlist.msExchHideFromAddressLists + "`n`n"
        $lbl2.text += "SMTP Info (Upper Case 'SMTP' is the Address Being Used): `n" + ($userlist.proxyAddresses | Out-String) + "`n"
        $lbl2.text += "Security Groups " + "(" + ($userlist.MemberOf).count + "):" + "`n" + ($userlist.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' | Out-string) + "`n`n"
        [int]$pct = (9 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text += "User Reported PCs: " + $ReportedPCs
        #       ([ADSISEARCHER]"samaccountname=$($env:USERNAME)").Findone().Properties.memberof -replace '^CN=([^,]+).+$','$1'
        #       $lbl2.text += "Last Logged On Computers: `n" + ((get-content \\spmdm02\Software\AFNET\Spangdahlem\*.log -ReadCount 1000) | ForEach-Object {$_ -match "$findusername"} | Select-object -Last 8 | Out-String) + "`n`n"
        $stBar1.text = "Account Info for " + $userlist.DisplayName + " is displayed."
        #    if (!($userlist)){$vbmsg1 = $vbmsg.popup("No users were found matching your query. Make sure you're entering the EDIPI with the designator: 123456789a",0,"Error",0)}
        [int]$pct = (10 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    } #End $FindUser
    
    ##############
    #### PING ####
    ##############
    $btn27_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
        [int]$pct = (0 / 2) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
        $computername = $txt1.text
        $stBar1.text = "Pinging " + $computername.ToUpper() + " (Please wait...)"
        $Pinger = (Test-Connection $computername -quiet -count 1)
    
        [int]$pct = (1 / 2) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        if ($computername -like "*.*.*.*") {
            if ($Pinger -eq $true) {
                $HostQ = [System.Net.DNS]::GetHostEntry($computername) | Select-Object -ExpandProperty HostName -ev DNSerror -ErrorAction SilentlyContinue
                $HostName = $HostQ.Split('.') | Select-Object -First 1 -ErrorAction SilentlyContinue
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`t`t`t`t`t`tGot reply from " + $computername + "`n"
                if (!($HostQ -eq $DNSerror)) {
                    $lbl2.text += "`t`t`t`t`t`t Hostname " + $HostName
                }
                else {
                    $stBar1.text = "Error resolving " + $computername
                    $lbl2.text += "`t`t`t`t`t    Error: Unable to resolve IP to hostname"
                }
                $stBar1.text = "Got a reply from " + $computername
                [int]$pct = (2 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
            else {
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`t`t`t`t`t`tDidnt get a reply from " + $computername + " `n"
                $stBar1.text = "No reply from " + $computername
                [int]$pct = (2 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
        }
        else {
    
            if ($Pinger -eq $true) {
                $IPq = (([System.Net.DNS]::GetHostEntry($computername)).AddressList).IPAddressToString | Select-Object -Last 1 -ErrorAction SilentlyContinue
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`t`t`t`t`t`tGot reply from " + $computername.ToUpper() + "`n"
                $lbl2.text += "`t`t`t`t`t`t        IP Address " + $IPq + ""
                $stBar1.text = "Got a reply from " + $computername.ToUpper()
                [int]$pct = (2 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
            else {
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`t`t`t`t`t`tDidnt get a reply from " + $computername.ToUpper() + "`n"
                $stBar1.text = "No reply from " + $computername.ToUpper()
                [int]$pct = (2 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
        }
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Pinged " + $computername + " with a status of " + $Pinger | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    #####################
    #### SYSTEM INFO ####
    #####################
    $btn1_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
        [int]$pct = (0 / 10) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
    
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
    
        if ($txt1.text -like "*.*.*.*") {
            $HostQ = [System.Net.DNS]::GetHostEntry($txt1.text) | Select-Object -ExpandProperty HostName -ev DNSerror
            $HostName = $HostQ.Split('.') | Select-Object -First 1
            if (!($HostQ -eq $DNSerror)) {
                $computername = $HostName
            }
            else {
                $stBar1.text = "Error resolving " + $txt1.text
                $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t`t Unable to resolve IP " + $txt1.text
            }
        }
        else { $computername = $txt1.text }
    
        if (Get-ADComputer -Filter "CN -like '$computername'") {
            [int]$pct = (1 / 17) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            if (IsAdmin) {
                $stBar1.text = "Getting System Info for " + $computername.ToUpper() + " (Loading...)"
    
                [int]$pct = (2 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $Pinger = (Test-Connection $computername -quiet -count 1)
    
                if ($Pinger -eq $true) {
    
                    $systeminfoerror = $null
                    # Begin query #
                    $rComp = Get-WmiObject win32_computersystem -computername $computername -ev systeminfoerror
                    if ($systeminfoerror) {
                        [int]$pct = (15 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error retrieving info from " + $computername.ToUpper()
                        $lbl2.text = "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t $systeminfoerror"
                    }
    
                    else {
                        [int]$pct = (3 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $rComp1 = (Get-WmiObject win32_computersystem -computername $computername).UserName -Split "\\" | Select-Object -Skip 1 -ErrorAction SilentlyContinue
                        $rComp3 = get-childitem -Path "\\$computername\c$\Users" -Filter "1*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Select-Object -expandProperty Name -ErrorAction SilentlyContinue
                        $rComp4 = get-childitem -Path "\\$computername\c$\Users" -Filter "1*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Select-Object -expandProperty LastWriteTime -ErrorAction SilentlyContinue
                        $rOS = Get-WmiObject win32_operatingsystem -computername $computername -EA 0
                        $rComp2 = Get-WmiObject win32_computersystemproduct -computername $computername -EA 0
                        $rCPU = Get-WmiObject win32_processor -computername $computername -EA 0
                        $rBIOS = Get-WmiObject win32_bios -computername $computername -EA 0
                        [int]$pct = (4 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $rRam = Get-WmiObject win32_physicalmemory -computername $computername -EA 0
                        $rIP = Get-WmiObject win32_networkadapterconfiguration -computername $computername -EA 0
                        #$rMAC = Get-WmiObject win32_networkadapterconfiguration -computername $computername | Select-Object Description, MACAddress, IPAddress -EA 0
                        $rMon = Get-WmiObject win32_desktopmonitor -computername $computername -filter "Availability='3'" -EA 0
                        $rVid = Get-WmiObject win32_videocontroller -computername $computername -EA 0
                        $rDVD = Get-WmiObject win32_cdromdrive -computername $computername -EA 0
                        $rHD = Get-WmiObject win32_logicaldisk -computername $computername -filter "Drivetype='3'" -EA 0
                        $rProc = Get-WmiObject win32_process -ComputerName $computername -EA 0
                        #$rOU = (Get-ADComputer $computername -Properties DistinguishedName).DistinguishedName -Split ("OU=") | Select-Object -First 4 | Select-Object -Skip 1
                        [int]$pct = (5 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        # SDC Version #
                        try { $SDC = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computername).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation').GetValue('Model') }
                        catch { $SDC = "Cant find registry value" }
                        #$SDC = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name Model}).Model
    
                        # Separate sticks of memory #
                        $RAM = $rComp.totalphysicalmemory / 1GB
                        $mem = "{0:N2}" -f $RAM + " GB Usable -- "
                        $memcount = 0
                        foreach ($stick in $rRam) {
                            $mem += "(" + "$($rRam[$memcount].capacity / 1GB) GB" + ") "
                            $memcount += 1
                        }
                        $mem += "Physical Stick(s)"
    
                        # Enumerate Monitors #
                        $monitor = ""
                        foreach ($mon in $rmon) {
                            $monitor += "(" + $mon.screenwidth + " x " + $mon.screenHeight + ") "
                        }
    
                        [int]$pct = (6 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
    
                        # List IP/MAC Address#
                        $IP = $rIP.IPaddress | Select-Object -First 1
                        $GW = $rIP.DefaultIPGateway
                        $DNS = $rIP.DNSServerSearchOrder
                        $Subnet = $rIP.IPSubnet | Select-Object -First 1
                        $rMAC = $rIP | Select-Object Description, MACAddress, IPAddress
    
                        # Convert Date fields #
                        $imagedate = [System.Management.ManagementDateTimeconverter]::ToDateTime($rOS.InstallDate)
                        $localdate = [System.Management.ManagementDateTimeconverter]::ToDateTime($rOS.LocalDateTime)
    
                        # Format Hard Disk sizes #
                        $HDfree = $rHD.Freespace / 1GB
                        $HDSize = $rHD.Size / 1GB
        
                        # User Logon Duration #
                        [int]$pct = (7 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $explorer = $rProc | Where-Object { $_.name -match "explorer.exe" }
                        if (!$explorer) {
                            $userlogonduration = $null
                        }
                        elseif ($explorer.count) {
                            $explorer = $explorer | Sort-Object creationdate
                            $UserLogonDuration = $explorer[0]
                        }
                        else {
                            $UserLogonDuration = $explorer
                        }
                        if ($UserLogonDuration) { $ULD = Compare-DateTime $UserLogonDuration "CreationDate" }
                        else { $ULD = "" }
    
    
                        <#
    # Desktop/My Documents folder sizes #
    if ($rComp.Username -eq $null){}
    else {
        if ($rOS.Caption -match "Windows 7" -OR "Vista"){$userpath = "users\"; $mydocs = "\Documents"}
        if ($rOS.Caption -match "XP"){$userpath = "documents and settings\"; $mydocs = "\My Documents"}
        $path = "\\$computername\c$\$userpath"
        $username = $rComp.Username
        if ($username.indexof("\") -ne -1){$username = $username.remove(0,$username.lastindexof("\")+1)}
            
        # Desktop Folder Size
        $startFolder1 = $path + $username + "\Desktop"
        $colItems1 = (Get-ChildItem $startFolder1 -recurse| Measure-Object -property length -sum)
        $rDesk = "{0:N2}" -f ($colItems1.sum / 1MB)
    
        # My Documents Folder Size
        $startFolder2 = $path + $username + $mydocs
        $colItems2 = (Get-ChildItem $startFolder2 -recurse| Measure-Object -property length -sum)
        $rMyDoc = "{0:N2}" -f ($colItems2.sum / 1MB)
        }
    #>
    
                        [int]$pct = (8 / 17) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
    
                        # Creating function for pending restart result
                        function Test-PendingReboot {
                            if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
                            if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
                            if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
                            try { 
                                $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
                                $status = $util.DetermineIfRebootPending()
                                if (($null -ne $status) -and $status.RebootPending) {
                                    return $true
                                }
                            }
                            catch {} 
                            return $false
                        }
                        $RestartStatus = Test-PendingReboot -computername $computername
                    }
                }
    
                $PClist = Get-ADComputer $computername -Property * | Select-Object *
                $IPS = [System.Net.Dns]::GetHostAddresses($computername)
                if (Invoke-Command -ComputerName $computername -ScriptBlock { get-module -list ActiveDirectory }) { $RSAT = "Yes" }
                else { $RSAT = "No" }
    
                # Write query results #
                [int]$pct = (9 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "`t`t`t`t`t~ Computer Information for " + $computername + " ~`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "`t`t`t`t`t`t     ~ AD Computer Info ~ `n`n"
                $lbl2.text += "Domain Location:`t " + $PClist.DistinguishedName + "`n`n"
                $lbl2.text += "Physical Location:`t " + $PClist.Location + "`n`n"
                $lbl2.text += "Computer Name:`t " + $computername + "`n"
                $lbl2.text += "Creation Date:`t`t " + $PClist.WhenCreated + "`n"
                [int]$pct = (10 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "Last Changed:`t`t " + $PClist.WhenChanged + "`n"
                $lbl2.text += "Last Logged on:`t " + $PClist.LastLogonDate + "`n"
                $lbl2.text += "Enabled: `t`t " + $PClist.Enabled + "`n"
                $lbl2.text += "Locked: `t`t " + $PClist.LockedOut + "`n"
                [int]$pct = (11 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "Lockout Time: `t " + $PClist.AccountLockoutTime + "`n"
                $lbl2.text += "Member Of: `t`t " + ($PClist.memberof -replace '^CN=([^,]+),OU=.+$', '$1') + "`n"
                $lbl2.text += "Managed By: `t`t " + ($PClist.ManagedBy -replace '^CN=([^,]+),OU=.+$', '$1') + "`n"
                $lbl2.text += "Notes: `t`t " + $PClist.Description + "`n`n"
                $lbl2.text += "Password Last Set:`t " + $PClist.PasswordLastSet + "`n"
                $lbl2.text += "Password Expires:`t " + $PClist.PasswordNeverExpires + "`n`n"
                [int]$pct = (12 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "SID:`t`t`t " + $PClist.SID + "`n"
                $lbl2.text += "AD Object Type:`t " + $PClist.ObjectClass + "`n"
                $lbl2.text += "Operating System:`t " + $PClist.OperatingSystem + "`n"
                $lbl2.text += "OS Version: `t`t " + $PClist.OperatingSystemVersion + "`n"
                $lbl2.text += "Logon Count: `t`t " + $PClist.LogonCount + "`n`n"
                [int]$pct = (13 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "IP Address (DNS):`t" + $IPS + "`n"
                $lbl2.text += "Online: `t`t" + $Pinger + "`n`n`n"
                [int]$pct = (14 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                # Local Computer Info #
                if ($Pinger -eq $true) {
                    $lbl2.text += "`t`t`t`t`t`t     ~ Local Computer Info ~ `n`n"
                    $lbl2.text += "Current User:`t`t " + (([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$rComp1))").FindAll().Properties.cn) + "`n"
                    $lbl2.text += "Last User:`t`t " + (([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$rComp3))").FindAll().Properties.cn) + "`n"
                    $lbl2.text += "User logged on for:`t " + $ULD + "`n"
                    $lbl2.text += "Last Restart:`t`t " + (Compare-DateTime -TimeOfObject $rOS -Property "Lastbootuptime") + "`n"
                    $lbl2.text += "Pending Restart:`t " + $RestartStatus + "`n"
                    $lbl2.text += "RSAT/ADUC:`t`t " + $RSAT + "`n`n"
                    $lbl2.text += "Manufacturer:`t`t " + $rComp.Manufacturer + "`n"
                    $lbl2.text += "Model:`t`t " + $rComp.Model + "`n"
                    [int]$pct = (15 / 17) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $lbl2.text += "SKU Number:`t`t " + $rComp.SystemSKUNumber + "`n"
                    $lbl2.text += "Serial:`t`t`t " + $rBIOS.SerialNumber + "`n`n"
                    $lbl2.text += "CPU:`t`t`t " + $rCPU.Name.Trim() + "`n"
                    $lbl2.text += "RAM:`t`t`t " + $mem + "`n"
                    $lbl2.text += "Hard Drive: `t`t {0:N1} GB Free / {1:N1} GB Total `n" -f $HDfree, $HDsize
                    $lbl2.text += "Optical Drive:`t`t " + "(" + $rDVD.Drive + ") " + $rDVD.Caption + "`n"
                    $lbl2.text += "Video Card:`t`t " + $rVid.Name + "`n"
                    $lbl2.text += "Monitor(s):`t`t " + $monitor + "`n`n"
                    $lbl2.text += "Local Date/Time:`t " + $localdate + "`n"
                    $lbl2.text += "Operating System:`t " + $rOS.Caption + "`n"
                    $lbl2.text += "SDC Version:`t`t " + $SDC + "`n"
                    [int]$pct = (16 / 17) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $lbl2.text += "OS Version:`t`t " + $rOS.Version + "`n"
                    $lbl2.text += "Service Pack:`t`t " + $rOS.CSDVersion + "`n"
                    $lbl2.text += "OS Architecture:`t " + $rComp.SystemType + "`n"
                    $lbl2.text += "PC imaged on:`t`t " + $imagedate + "`n`n"
                    $lbl2.text += "IP Address:`t`t" + $IP + "`n"
                    $lbl2.text += "Subnet:`t`t" + $Subnet + "`n"
                    $lbl2.text += "Gateway:`t`t" + $GW + "`n"
                    $lbl2.text += "DNS:`t`t`t" + $DNS + "`n`n"
                    $lbl2.text += "Network Adapters and MAC Addresses:`t" + ($rMAC | Out-String) + "`n"
                }
                else {
                    $lbl2.text += "`t`t`t`t`t`t     ~ Local Computer Info ~ `n`n"
                    $lbl2.text += "`t`t`t`t`t`t         No ping reply from " + $computername
                    [int]$pct = (17 / 17) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                }
                <#
    # Desktop/My Docs labels #
    if ($rComp.Username -eq $null){}
    else {
        $lbl2.text += "Desktop Folder:`t" + $rDesk + " MB" + "`n"
        $lbl2.text += "My Docs Folder:`t" + $rMyDoc + " MB"
        }
    #>
    
                $stBar1.text = "System Info for " + $computername.ToUpper()
                [int]$pct = (17 / 17) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
      
            ########## Non-admin PC Details ############
    
            Else {
                [int]$pct = (1 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $PClist = Get-ADComputer $computername -Property * | Select-Object *
                $Pinger = (Test-Connection $computername -quiet -count 1)
                $IPS = [System.Net.Dns]::GetHostAddresses($computername)
    
                $lbl2.text += "`t`t`t`t`t~ Computer Information for " + $computername + " ~`n"
                $lbl2.text += "`n"
                $lbl2.text += "`n"
                $lbl2.text += "Domain Location:`t " + $PClist.DistinguishedName + "`n`n"
                $lbl2.text += "Physical Location:`t " + $PClist.Location + "`n`n"
                $lbl2.text += "Computer Name:`t " + $computername + "`n"
                $lbl2.text += "Creation Date:`t`t " + $PClist.WhenCreated + "`n"
                [int]$pct = (2 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "Last Changed:`t`t " + $PClist.WhenChanged + "`n"
                $lbl2.text += "Last Logged on:`t " + $PClist.LastLogonDate + "`n"
                $lbl2.text += "Enabled: `t`t " + $PClist.Enabled + "`n"
                $lbl2.text += "Locked: `t`t " + $PClist.LockedOut + "`n"
                [int]$pct = (3 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "Lockout Time: `t " + $PClist.AccountLockoutTime + "`n"
                $lbl2.text += "MemberOf: `t`t " + ($PClist.memberof -replace '^CN=([^,]+),OU=.+$', '$1') + "`n"
                $lbl2.text += "Managed By: `t`t " + ($PClist.ManagedBy -replace '^CN=([^,]+),OU=.+$', '$1') + "`n"
                $lbl2.text += "Notes: `t`t " + $PClist.Description + "`n`n"
                $lbl2.text += "Password Last Set:`t " + $PClist.PasswordLastSet + "`n"
                $lbl2.text += "Password Expires:`t " + $PClist.PasswordNeverExpires + "`n`n"
                [int]$pct = (4 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "SID:`t`t`t " + $PClist.SID + "`n"
                $lbl2.text += "AD Object Type:`t " + $PClist.ObjectClass + "`n"
                $lbl2.text += "Operating System:`t " + $PClist.OperatingSystem + "`n"
                $lbl2.text += "OS Version: `t`t " + $PClist.OperatingSystemVersion + "`n"
                $lbl2.text += "Logon Count: `t`t " + $PClist.LogonCount + "`n`n"
                [int]$pct = (5 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text += "IP Address (DNS):`t" + $IPS + "`n"
                $lbl2.text += "Online: `t`t" + $Pinger
                [int]$pct = (6 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "System Info for " + $computername.ToUpper()
            }
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched " + $computername + " for system info" | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        Else {
            [int]$pct = (6 / 6) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Computer $computername doesn't exist..."
            $vbmsg1 = $vbmsg.popup("The computer name or IP address you entered doesn't exist, try again.", 0, "Error", 0)
        }
    }
    
    ######################
    #Client Health Status#
    ######################
    Function ClientStatus {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
    
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
    
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            [int]$pct = (0 / 10) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            if (test-connection $computername -quiet -count 1) {
    
                $stBar1.text = "Getting Client Health Status For " + $computername.ToUpper() + " (Loading...)"
                $lbl2.visible = $true
                $systeminfoerror = $null
    
                [int]$pct = (1 / 10) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                # Begin query #
                $rComp = Get-WmiObject win32_computersystem -computername $computername -ev systeminfoerror
                if ($systeminfoerror) {
                    [int]$pct = (10 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error retrieving info from " + $computername.ToUpper()
                    $lbl2.text = "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t $systeminfoerror"
                }
    
                Else {
                    # Software List #
                    $software = Invoke-Command -Computer $computername { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* } | Select-Object DisplayName
                    if ($software -like "*McAfee*") { $IsInstalledMc = "Yes" } else { $IsInstalledMc = "No" }
                    if ($software -like "*Configuration*") { $IsInstalledCM = "Yes" } else { $IsInstalledCM = "No" }
                    if ($software -like "*Tanium*") { $IsInstalledTa = "Yes" } else { $IsInstalledTa = "No" }
    
                    # McAfee Info #
                    $McAfeeVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\Agent').GetValue('AgentVersion')
                    #$McAfeeVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\Agent -Name AgentVersion}).AgentVersion
                    $PackVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\TVD\Shared Components\Framework').GetValue('certPkgVersion')
                    #$DatDate = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\AVEngine -Name AVDatDate}).AVDatDate
                    [int]$pct = (2 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $LastCheck = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\TVD\Shared Components\Framework').GetValue('LastUpdateCheck')
                    $CoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\McAfee\AVSolution\AVS\AVS').GetValue('szAMCoreVersion')
                    #$DatVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\AVEngine -Name AVDatVersion}).AVDatVersion
                    $SysCoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\SystemCore').GetValue('system_core_version')
                    #$VSEVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\Application Plugins\VIRUSCAN8800' -Name Version}).Version
                    $DLPVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\McAfee\DLP\Agent').GetValue('AgentVersion')
                    #$ScanEng = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\Application Plugins\VIRUSCAN8800' -Name EngineVersion}).EngineVersion
    
                    [int]$pct = (3 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    $EndPointAV = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\McAfee\Endpoint\AV').GetValue('ProductVersion')
                    #$DateVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\Application Plugins\VIRUSCAN8800' -Name DATVersion}).DATVersion
                    $ENSAMCoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\McAfee\Endpoint\AV\ENSAMCoreVersionTrack').GetValue('LatestAMCoreAvailable')
                    #$DateDate = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\Application Plugins\VIRUSCAN8800' -Name DATDate}).DATDate
                    $HIPS = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\McAfee\Endpoint\Ips\HIP').GetValue('VERSION')
                    #$DLPVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\DLP\Agent -Name AgentVersion}).AgentVersion
                    $HIPSCore = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\HIP').GetValue('HipsCoreVersion')
    
                    [int]$pct = (4 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    #$PolTime = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\McAfee\DLP\Agent\Properties\General -Name PolicyReceiveTime}).PolicyReceiveTime
                    $NIPS = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\HIP').GetValue('NipsVersion')
                    #$HIPS = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\McAfee\HIP -Name VERSION}).VERSION
                    $PolicyAgent = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\ePolicy Orchestrator\Application Plugins\PHCONTEN6000').GetValue('Version')
                    $ACCMVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\ePolicy Orchestrator\Application Plugins\S_USAF021001').GetValue('Version')
                    $EPOSer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\agent').GetValue('eposerverlist') -split (";") | Select-Object -First 1
                    #$EPOSer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\agent' -Name eposerverlist}).eposerverlist -split (";") | Select-Object -First 1
    
                    [int]$pct = (5 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    # SCCM Info #
                    $SCCMVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\Microsoft\SMS\Mobile Client').GetValue('SmsClientVersion')
                    #$SCCMVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client' -Name SmsClientVersion}).SmsClientVersion
                    $MngPoint = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\Microsoft\SMS\DP').GetValue('ManagementPoints')
                    #$MngPoint = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\SMS\DP -Name ManagementPoints}).ManagementPoints
                    $SiteCode = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\Microsoft\SMS\Mobile Client').GetValue('AssignedSiteCode')
                    #$SiteCode = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client' -Name AssignedSiteCode}).AssignedSiteCode
                    $SCCMDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\Microsoft\CCM\CcmEval').GetValue('LastEvalTime')
                    #$SCCMDate = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmEval -Name LastEvalTime}).LastEvalTime
    
                    [int]$pct = (6 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    # Tanium Info #
                    $TanVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('Version')
                    #$TanVer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient' -Name Version}).Version
                    $StartDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('First Start')
                    #$StartDate = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient' -Name 'First Start'}).'First Start'
                    $TanDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('LastStatUpdate')
                    #$TanDate = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient' -Name LastStatUpdate}).LastStatUpdate
    
                    #$UpdateSer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$rComp.name).OpenSubKey('Software\Policies\Microsoft\Windows\WindowsUpdate').GetValue('WUServer')
                    #$UpdateSer = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Name WUServer}).WUServer
                    $UpdateSer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('Software\Policies\Microsoft\Windows\WindowsUpdate').GetValue('WUServer')
                    $rUpdate = Get-WmiObject win32_quickfixengineering -computername $computername | Sort-Object installedon -Descending | Select-Object -First 10 | Out-String
                    $rOS = Get-WmiObject win32_operatingsystem -computername $computername
    
                    # SDC Version #
                    $SDC = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $rComp.name).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation').GetValue('Model')
                    #$SDC = (invoke-command -ComputerName $computername -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name Model}).Model
    
                    # SCCM Run Status #
                    $SCCMStat = Get-Service -ComputerName $computername -Name "CcmExec"
    
                    # Tanium Run Status #
                    $TanStat = Get-Service -ComputerName $computername -Name "Tanium Client"
    
                    [int]$pct = (7 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    # McAfee Run Status #
                    $McAfeeStat = Get-Service -ComputerName $computername -Name "masvc"
    
                    # Write query results #
                    $lbl2.text += "`t`t`t`t`t Computer Health Information for " + $rComp.name + "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "Computer Name:`t " + $rComp.name + "`n"
                    $lbl2.text += "Operating System:`t " + $rOS.Caption + "`n"
                    $lbl2.text += "SDC Version:`t`t " + $SDC + "`n`n"
                    $lbl2.text += "Last Restart:`t`t " + (Compare-DateTime -TimeOfObject $rOS -Property "Lastbootuptime") + "`n`n"
                    $lbl2.text += "SCCM Installed:`t " + $IsInstalledCM + "`n"
                    $lbl2.text += "SCCM Status:`t`t " + $SCCMStat.Status + "`n"
                    $lbl2.text += "SCCM Version:`t`t " + $SCCMVer + "`n"
                    $lbl2.text += "Management Point:`t " + $MngPoint + "`n"
    
                    [int]$pct = (8 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    $lbl2.text += "Site Code:`t`t " + $SiteCode + "`n"
                    $lbl2.text += "Last Eval Date:`t`t " + $SCCMDate + "`n`n"
                    $lbl2.text += "Tanium Installed:`t " + $IsInstalledTa + "`n"
                    $lbl2.text += "Tanium Status:`t`t " + $TanStat.Status + "`n"
                    $lbl2.text += "Tanium Version:`t`t " + $TanVer + "`n"
                    $lbl2.text += "Start Date:`t`t " + $StartDate + "`n"
                    $lbl2.text += "Tanium Update:`t`t " + $TanDate + "`n`n"
                    $lbl2.text += "McAfee Installed:`t " + $IsInstalledMc + "`n"
                    $lbl2.text += "McAfee Status:`t`t " + $McAfeeStat.Status + "`n"
                    $lbl2.text += "McAfee Version:`t`t " + $McAfeeVer + "`n"
                    $lbl2.text += "Package Version:`t " + $PackVer + "`n"
                    $lbl2.text += "Policy Agent Version: `t " + $PolicyAgent + "`n"
                    $lbl2.text += "ACCM Version:`t`t " + $ACCMVer + "`n"
    
                    [int]$pct = (9 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    $lbl2.text += "Last Update Check: `t " + $LastCheck + "`n"
                    $lbl2.text += "System Core Version: `t " + $SysCoreVer + "`n"
                    $lbl2.text += "AM Core Version:`t " + $CoreVer + "`n"
                    $lbl2.text += "DLP Version:`t`t " + $DLPVer + "`n`n"
                    $lbl2.text += "EndPoint AV Version: `t " + $EndPointAV
                    $lbl2.text += "`n"
                    $lbl2.text += "ENSAMCore Version: `t " + $ENSAMCoreVer + "`n`n"
                    $lbl2.text += "HIPS Verion:`t`t " + $HIPS + "`n"
                    $lbl2.text += "HIPS Core Verion: `t " + $HIPSCore + "`n"
                    $lbl2.text += "NIPS Version:`t`t " + $NIPS + "`n`n"
                    $lbl2.text += "EPO Server:`t`t " + $EPOSer + "`n`n"
                    $lbl2.text += "Update Server:`t`t " + $UpdateSer + "`n`n"
                    $lbl2.text += "Last 10 Windows Updates:`t " + $rUpdate + "`n`n"
    
                    $stBar1.text = "Client Health Report For " + $computername.ToUpper()
                    [int]$pct = (10 / 10) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched " + $computername + " for health status" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
    
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ######################
    ## COMP MANAGEMENT ###
    ######################
    Function CompManage {
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        $stBar1.text = "Pinging " + $computername.ToUpper()
        if (Test-Connection $Computername -quiet -count 1) {
            compmgmt.msc /computer:$computername
            $stBar1.text = "Opened computer management for " + $computername.toupper()
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened computer management for " + $computername | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
    }
    
    #######################
    # REFRESH INSTALL LOG #
    #######################
    $btn18_OnClick = {
        HideUnusedItems
        $btn18.visible = $true
        $btn19.visible = $true
        $lbl2.text = ""
        $lbl2.visible = $true
        if ($stBar1.text -like "*copy*") {
            If ("$env:SystemDrive\Admin_Tool\Multi_Copy\Copy_Log.txt") {
                $lbl2.text = Get-Content -Raw "$env:SystemDrive\Admin_Tool\Multi_Copy\Copy_Log.txt"
                $stBar1.text = "Current copy status. Click 'Refresh Log' to refresh or 'Get Jobs' to see running jobs."
            }
            Else { $stBar1.text = "Copy log file can't be found..." }
        }
        elseif ($stBar1.text -like "*password*") {
            If ("$env:SystemDrive\Admin_Tool\Password_Change\PwdChange_Log.txt") {
                $lbl2.text = Get-Content -Raw "$env:SystemDrive\Admin_Tool\Password_Change\PwdChange_Log.txt"
                $stBar1.text = "Current password change status. Click 'Refresh Log' to refresh or 'Get Jobs' to see running jobs."
            }
            Else { $stBar1.text = "Password change log file can't be found..." }
        }
        else {
            If ("$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt") {
                $lbl2.text = Get-Content -Raw "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt"
                $stBar1.text = "Current install status. Click 'Refresh Log' to refresh or 'Get Jobs' to see running jobs."
            }
            Else { $stBar1.text = "Install log file can't be found..." }
        }
    }
    
    ######################
    #### APPLICATIONS ####
    ######################
    $btn3_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            $lbl2.text = ""
            ClearGrid
            HideUnusedItems
            $list1.visible = $true
            $lbl2.visible = $false
            [int]$pct = (0 / 1) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
    
            if (test-connection $computername -quiet -count 1) {
                $list1.Columns[2].text = "Uninstall String"
                $list1.Columns[2].width = 300
                $list1.Columns[1].text = "Install Date"
                $list1.Columns[1].width = 90
                $list1.Columns[0].text = "Name"
                $list1.Columns[0].width = ($list1.width - $list1.columns[2].width - 100)
    
                $stBar1.text = "Applications on " + $computername.ToUpper() + " (Loading...)"
                $List1.items.Clear()
                $systeminfoerror = $null
                $software = Invoke-Command -Computer $computername { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* } | Where-Object { ![string]::IsNullOrWhiteSpace($_.DisplayName) } | Select-Object DisplayName, installDate, UninstallString | Sort-Object DisplayName -ev systeminfoerror
                if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
                else {
                    $columnnames = "Name", "Install Date", "Uninstall String"
                    foreach ($app in $software) {
    
                        $i++
                        [int]$pct = ($i / $software.count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($app.DisplayName)
    
                        if ($null -eq $app.InstallDate) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($app.InstallDate) }
    
                        if ($null -eq $app.UninstallString) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($app.UninstallString) }
    
                        $item.Tag = $app
                        $list1.Items.Add($item) > $null
                    }
    
                    $btn11.Visible = $true
                    $btn22.Visible = $true
    
                    $stBar1.text = "Applications and Updates installed on " + $computername.ToUpper() + " (" + $software.count + ")"
                }
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed applications on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            } #End test connection
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End Applications
    
    ###########################
    #### SCCM APPLICATIONS ####
    ###########################
    Function SCCMApps {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            $lbl2.text = ""
            ClearGrid
            HideUnusedItems
            $list2.visible = $true
            $lbl2.visible = $false
            [int]$pct = (0 / 1) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            if (test-connection $computername -quiet -count 1) {
                #$stBar1.text = "Connecting to " + $computername.ToUpper()
    
                $list2.Columns[1].text = "Install Status"
                $list2.Columns[1].width = 129
                $list2.Columns[0].text = "Name"
                $list2.Columns[0].width = ($list2.width - $list2.columns[1].width - 25)
    
                $stBar1.text = "SCCM Applications on " + $computername.ToUpper() + " (Loading...)"
                $List2.items.Clear()
                $systeminfoerror = $null
                $software = get-ciminstance -classname ccm_application -namespace "root\ccm\clientsdk" -ComputerName $computername | Select-Object fullname, resolvedstate, Id, Revision | Sort-Object fullname -ev systeminfoerror
                if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
                else {
                    $columnproperties = "Name", "ResolvedState"
                    foreach ($app in $software) {
    
                        $i++
                        [int]$pct = ($i / $software.count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($app.FullName)
                        if ($null -eq $app.ResolvedState) {
                            $item.SubItems.Add($text)
                        }
                        else { $item.SubItems.Add($app.ResolvedState) }
                        $item.Tag = $app
                        $list2.Items.Add($item) > $null
                    }
    
                    $btn17.Visible = $true
    
                    $stBar1.text = "SCCM Applications installed or available for " + $computername.ToUpper() + " (" + $software.count + ")"
                }
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed SCCM applications for " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            } #Ping check
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End SCCM Applications
    
    ###########################
    ####### JOBS BUTTON #######
    ###########################
    $btn19_OnClick = 
    {
        $lbl2.text = ""
        HideUnusedItems
        $btn18.visible = $true
        $btn19.visible = $true
        $list3.visible = $true
        $lbl2.visible = $false
    
        $list3.Columns[1].text = "State"
        $list3.Columns[1].width = 129
        $list3.Columns[0].text = "Name"
        $list3.Columns[0].width = ($list3.width - $list3.columns[1].width - 25)
    
        if ($stBar1.text -like "*copy*") {
    
            $stBar1.text = "Getting job list (Loading...)"
            ClearGrid
            $jobs = Get-Job | Select-Object Name, State | Sort-Object State -ev systeminfoerror
            if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
            else {
                $columnproperties = "Name", "State"
                foreach ($job in $jobs) {
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($job.name)
                    if ($null -eq $job.State) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($job.state) }
                    $item.Tag = $job
                    $list3.Items.Add($item) > $null
                }
    
                $btn20.Visible = $true
                $stBar1.text = "Background copy jobs on this computer..."
            }
        }
    
        elseif ($stBar1.text -like "*password*") {
    
            $stBar1.text = "Getting job list (Loading...)"
            ClearGrid
            $jobs = Get-Job | Select-Object Name, State | Sort-Object State -ev systeminfoerror
            if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
            else {
                $columnproperties = "Name", "State"
                foreach ($job in $jobs) {
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($job.name)
                    if ($null -eq $job.State) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($job.state) }
                    $item.Tag = $job
                    $list3.Items.Add($item) > $null
                }
    
                $btn20.Visible = $true
                $stBar1.text = "Background password change jobs on this computer..."
            }
        }
    
        else {
    
            $stBar1.text = "Getting job list (Loading...)"
            ClearGrid
            $jobs = Get-Job | Select-Object Name, State | Sort-Object State -ev systeminfoerror
            if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
            else {
                $columnproperties = "Name", "State"
                foreach ($job in $jobs) {
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($job.name)
                    if ($null -eq $job.State) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($job.state) }
                    $item.Tag = $job
                    $list3.Items.Add($item) > $null
                }
    
                $btn20.Visible = $true
                $stBar1.text = "Background install jobs on this computer..."
            }
        }
    } #End Jobs Button
    
    #########################
    ####### END JOB #########
    #########################
    $btn20_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        if ($list3.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one job at a time.", 0, "Error", 0) }
        elseif ($list3.selecteditems.count -lt 1) { $vbmsg1 = $vbmsg.popup("Please select a job to end.", 0, "Error", 0) }
        else {
    
            $exprString = '$list3.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.Name}'
            $exprString2 = '$list3.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.State}'
    
            $JobName = Invoke-Expression $exprString
            $JobState = Invoke-Expression $exprString2
    
            if ($stBar1.text -like "*copy*") {
    
                If ($JobState -eq "Running") {
                    $stBar1.text = "Stopping job " + $JobName + ". Please wait..."
                    Stop-Job -Name $JobName
                    Start-Sleep 1
                    $stBar1.text = "Copy for $JobName has been stopped..."
                    Else {
                        $stBar1.text = "A copy for $JobName doesn't seem to be running. Refresh to see updated status."
                    }
    
                }
            }
            else {
    
                If ($JobState -eq "Running") {
                    $stBar1.text = "Stopping job " + $JobName + ". Please wait..."
                    Stop-Job -Name $JobName
                    Start-Sleep 1
                    $stBar1.text = "Install job for $JobName has been stopped..."
                    Else {
                        $stBar1.text = "An install job for $JobName doesn't seem to be running. Refresh to see updated status."
                    }
    
                }
            }
        }
    }
    
    #######################
    ##### SWITCH USER #####
    #######################
    $SwitchUser = {
        HideUnusedItems
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $lbl2.text = ""
            $lbl2.visible = $true
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Switching all users on " + $computername.ToUpper()
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                [int]$pct = (0 / 1) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $lbl2.text = "`n`n`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ######## Switching User(s) ######### " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ## This can take up to 30 seconds ## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
                $lbl2.text += "`t`t`t`t`t   ################################## " + "`n"
    
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 0 } -ErrorAction SilentlyContinue
                [int]$pct = (1 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 1 } -ErrorAction SilentlyContinue
                [int]$pct = (2 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 2 } -ErrorAction SilentlyContinue
                [int]$pct = (3 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 3 } -ErrorAction SilentlyContinue
                [int]$pct = (4 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 4 } -ErrorAction SilentlyContinue
                [int]$pct = (5 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { tsdiscon 5 } -ErrorAction SilentlyContinue
                [int]$pct = (6 / 6) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $vbmsg.popup("Done! User is still logged in, but the session is not active.", 0, "Notice", 0)
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Switched users on computer " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    
    } #End function Switch User
    
    # OPENS POWERSHELL #
    Function PShellLocal {
        Start-Process Powershell.exe
    }
    
    #####################################
    #### Input Box for User Accounts ####
    #####################################
    
    Function UserAccountInputBox {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Password Updater'
        $msg = ' There are 3 steps...
    
    1. Enter the account name that needs
    the password change (exactly) and
    click OK.
    
    Example:
    USAF_Admin
    
    2. In the second popup enter the new
    password and click OK. Make sure the
    complexity meets the standards or it
    will fail.
    
    3. The last popup will ask for the computer
    list that requires a password change. Only
    select a .txt file.'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ################################
    #### Input Box for Password ####
    ################################
    <#
    Function PasswordInputBox{
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
    $title = 'Password Updater'
    $msg   = ' 2. Enter the new password and
    click OK. Make sure the complexity
    meets the standards or it will fail.
    
    3. The next popup will ask for the computer
    list that requires a password change. Only
    select a .txt file.
    '
    
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $text}
    ##############################################
    #>
    
    ################################ OPEN COMP LIST FILE DIALOG BOX ##################################
    Function Get-PasswordCompList($initialDirectory) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "txt (*.txt)| *.txt"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
    }
    
    #####################################
    ##### Multiple Password Changer #####
    #####################################
    Function PasswordChanger {
        # Input user name
        $stBar1.text = "Requesting user account name..."
        $username = UserAccountInputBox
        if ($username -ne "") {
            # Input password
            $stBar1.text = "Requesting password..."
            $Ppassword = Read-Host -Prompt "Enter a new password." -AsSecureString -ErrorAction SilentlyContinue
            #$Ppassword = PasswordInputBox
            if ($Ppassword -ne "") {
                # Path to the computer list
                $stBar1.text = "Requesting computer list (.txt only)..."
                $comp = Get-PasswordCompList
                $computers = Get-Content $comp
                if ($null -ne $computers) {
    
                    $lbl2.visible = $True
                    $lbl2.text = ""
                    [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                    $LogPath = "$env:SystemDrive\Admin_Tool\Password_Change\PwdChange_Log.txt"
                    If (Test-Path $LogPath) { Remove-Item $LogPath -Force | Out-Null }
                    Start-Sleep -Seconds 1
                    If (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType File -Force | Out-Null }
                    Start-Sleep -Seconds 1
                    Add-Content -Path "$LogPath" -Value "`n`t`t`t`t`t Password change log for $($computers.Count) computers... `n"
     
                    $decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Ppassword))
    
                    Foreach ($Computer in $Computers) {
    
                        $running = @(Get-Job -State Running)
                        if ($running.Count -ge 50) {
                            $null = $running | Wait-Job -Any
                        }
    
                        $i++
                        [int]$pct = ($i / $Computers.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $stBar1.text = "Changing password for user " + $username + " on " + $Computer + " ( " + $i + " of " + $Computers.count + " ) "
    
                        Start-Job -Name "$Computer" -ArgumentList $Computer, $Computers, $username, $Ppassword, $decodedpassword, $LogPath -ScriptBlock {
                            Param($Computer, $Computers, $username, [SecureString] $Ppassword, [SecureString] $decodedpassword, $LogPath)
                       
                            $mutex = New-Object System.Threading.Mutex($false, "LogMutex")
    
                            #If $Computer IS NOT null or only whitespace
                            if (!([string]::IsNullOrWhiteSpace($Computer))) {
    
                                # Tests the connection via ping
                                If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
        
                                ([adsi]"WinNT://$computer/$username,user").SetPassword($decodedpassword)
    
                                    If ($? -eq $True) {
                                        $mutex.WaitOne()
                                        Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - Password reset for $username successful"
                                        $mutex.ReleaseMutex()
                                    }
    
                                    Else {
                                        $mutex.WaitOne()
                                        Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - Error: password reset for $username failed."
                                        $mutex.ReleaseMutex()
                                    }
                                                                  
                                } #End test connection
    
                                Else {
                                    $ComputersOFF += $Computer
                                    $mutex.WaitOne()
                                    Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - Offline"
                                    $mutex.ReleaseMutex()
                                }
                            }
                        } # End start-job
                        Start-Sleep -Seconds 1
                    } #End foreach loop
                    $btn18.Visible = $true
                    $btn19.Visible = $true
                    $stBar1.text = "Done starting password reset jobs for " + $Computers.Count + " computers. Refresh the log to get updated status..."
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Changed the password " + $username + " on " + $Computers.Count + " computers" | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                Else { $stBar1.text = "No computer list selected or action cancelled" }
            }
            Else { $stBar1.text = "No password entered or action cancelled" }
        }
        Else { $stBar1.text = "No user name entered or action cancelled" }
    } #End function
    
    ##################################
    #### Input Box for Messengers ####
    ##################################
    
    Function CopyInputBox {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Mass Copier'
        $msg = '1. Enter a destination for the file to be copied to:
    Example (enter --> C$ <-- and NOT C:):
    C$\Users\Public\Desktop
    C$\NewFolder1\NewFolder2
    
    2. After clicking ok, the next popup will ask for 
    the list of computers that are saved in a .txt file. 
    Browse to the file and click ok or double click.
    
    3. The last popup will ask for the file to be 
    copied. Browse to the file and click ok or 
    double click.
    
    Note: This copier will overwrite any files with the
    same name in the same location.
    '
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ################################ OPEN COPY FILE DIALOG BOX ##################################
    Function Get-FileCopy($initialDirectory) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
    }
    
    ################################ OPEN COMP LIST FILE DIALOG BOX ##################################
    Function Get-CopyCompList($initialDirectory) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "txt (*.txt)| *.txt"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
    }
      
    #######################
    ##### MASS COPIER #####
    #######################
    Function MassCopy {
        # Get file path to copy to
        $stBar1.text = "Requesting 'copy to' location..."
        $RemotePath = CopyInputBox
        if ($RemotePath -ne "") {
            # Setup computer list
            $stBar1.text = "Requesting computer list (.txt only)..."
            $ComputersList = Get-CopyCompList
            $Computers = Get-Content $ComputersList
            if ($null -ne $Computers) {
                # Path to the file to be installed
                $stBar1.text = "Requesting file to be copied..."
                $LocalPath = Get-FileCopy
                if ($null -ne $LocalPath) {
                    # Gets the file name for reporting
                    $File = Get-ChildItem -Name $LocalPath
    
                    $stBar1.text = "Checking settings..."
    
                    $lbl2.visible = $True
                    $lbl2.text = ""
                    [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                    $LogPath = "$env:SystemDrive\Admin_Tool\Multi_Copy\Copy_Log.txt"
                    If (Test-Path $LogPath) { Remove-Item $LogPath -Force | Out-Null }
                    Start-Sleep -Seconds 1
                    If (!(Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType File -Force | Out-Null }
                    Start-Sleep -Seconds 1
                    Add-Content -Path "$LogPath" -Value "`n`t`t`t`t Copy log for $($Computers.Count) computers copying file $($File)... `n"
     
                    Foreach ($Computer in $Computers) {
    
                        $running = @(Get-Job -State Running)
                        if ($running.Count -ge 10) {
                            $null = $running | Wait-Job -Any
                        }
    
                        $i++
                        [int]$pct = ($i / $Computers.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $stBar1.text = "Starting copy job for " + $Computer + " ( " + $i + " of " + $Computers.count + " ) "
    
                        Start-Job -Name "$Computer" -ArgumentList $Computer, $Computers, $File, $LocalPath, $RemotePath, $LogPath -ScriptBlock {
                            Param($Computer, $Computers, $File, $LocalPath, $RemotePath, $LogPath)
                       
                            $mutex = New-Object System.Threading.Mutex($false, "LogMutex")
    
                            #If $Computer IS NOT null or only whitespace
                            if (!([string]::IsNullOrWhiteSpace($Computer))) {
    
                                # Tests the connection via ping
                                If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
    
                                    if (!(Test-Path -Path "\\$Computer\$RemotePath")) { New-Item "\\$Computer\$RemotePath" -ItemType Directory }
                                                              
                                    Copy-Item -Path "$LocalPath" -Destination "\\$Computer\$RemotePath" -Force -Recurse -ErrorVariable SomeError
                                    Start-Sleep -Milliseconds 10
    
                                    $TestFileCopy = Get-ChildItem -Path "\\$Computer\$RemotePath\$File" -Force
                                    # If the file was copied, then perform the installation.
                                    If (($TestFileCopy) -and (!($SomeError))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - Copied $File successfully"
                                        $mutex.ReleaseMutex()
                                    }
    
                                    Else {
                                        $mutex.WaitOne()
                                        Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - $File did NOT copy. Make sure you have the appropriate permissions."
                                        $mutex.ReleaseMutex()
                                        Remove-PSSession -Session $Session
                                    }
                                                                  
                                } #End test connection
    
                                Else {
                                    $ComputersOFF += $Computer
                                    $mutex.WaitOne()
                                    Add-Content -Path $LogPath -Value "$(get-date -Format g): $Computer - Offline"
                                    $mutex.ReleaseMutex()
                                }
                            }
                            else { $stBar1.text = "The computer space is blank..." }
                        } # End start-job
                        Start-Sleep -Seconds 1
                    } #End foreach loop
                    $btn18.Visible = $true
                    $btn19.Visible = $true
                    $stBar1.text = "Done starting copy jobs for " + $Computers.Count + " computers. Refresh the log to get updated status..."
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Copied file " + $File + " to " + $Computers.Count + " computers" | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                Else { $stBar1.text = "No file selected to copy or action cancelled" }
            }
            Else { $stBar1.text = "No computer list selected or action cancelled" }
        }
        Else { $stBar1.text = "No input given or action cancelled" }
    } #End function
    
    ##########################
    ##### REMOTE GPEDIT ######
    ##########################
    Function GPEDIT {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Opening Remote GPEdit on " + $computername.ToUpper()
                gpedit.msc /gpcomputer: $computername
                $stBar1.text = "Opening Remote GPEdit on " + $computername.ToUpper() + " (DONE!)"
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened GPEdit on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ######################## 
    #### LOCAL GPRESULT ####
    ########################
    Function GPREPORT {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\GPResult")) {
            New-Item "$env:SystemDrive\Admin_Tool\GPResult" -ItemType Directory -Force
        }
        Invoke-Item $env:SystemDrive\Admin_Tool\GPResult
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran GPResult on " + $env:computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ##########################
    ##### REMOTE GPRESULT ####
    ##########################
    Function GPRESULT {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\GPResult")) {
            [int]$pct = (0 / 1) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            New-Item "$env:SystemDrive\Admin_Tool\GPResult" -ItemType Directory -Force
        }
        HideUnusedItems
        $lbl2.visible = $true
        $lbl2.text = ""
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            $systeminfoerror = $null
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Getting GPResult Info From " + $computername.ToUpper()
                gpresult.exe /s "$computername" /h "$env:SystemDrive\Admin_Tool\GPResult\GPResult-$computername.html" /f
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Start-Sleep 3
                if (Get-ChildItem -Name "$env:SystemDrive\Admin_Tool\GPResult\GPResult-$computername.html" -ErrorAction SilentlyContinue) {
                    $stBar1.text = "GPResult Info Has Been Exported to " + $env:SystemDrive + "\Admin_Tool\GPResult"
                }
                Else {
                    $stBar1.text = "Unable to Generate GPResult for " + $computername.ToUpper() + " ($env:username doesn't have RSoP data loaded)"
                }
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran GPResult on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ##########################
    ##### REGISTRY EDIT ######
    ##########################
    Function REGEDIT {
        $stBar1.text = "Opening regedit on this PC"
        [int]$pct = (1 / 2) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        regedit.exe
        [int]$pct = (2 / 2) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $stBar1.text = "Opening regedit on this PC (DONE!)"
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran remote registry on " + $computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ###############################
    ### OPENS REMOTE POWERSHELL ###
    ###############################
    Function PShellRemote {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Opening Remote Powershell on " + $computername.ToUpper()
                [int]$pct = (1 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                cmd /c start powershell -noexit -command "enter-pssession $computername"
                [int]$pct = (2 / 2) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Closed Remote Powershell on " + $computername.ToUpper()
        
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened a remote PowerShell session on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }       
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ####################
    ## List Printers  ##
    ####################
    function PrinterStat {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            ClearGrid
            HideUnusedItems
            $list12.visible = $true
            $lbl2.Visible = $false
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            if (test-connection $computername -quiet -count 1) {
    
                $list12.Columns[0].text = "Name"
                $list12.Columns[0].width = 150
                $list12.Columns[1].text = "DriverName"
                $list12.Columns[1].width = 150
                $list12.Columns[2].text = "Default"
                $list12.Columns[2].width = 150
                $list12.Columns[3].text = "PortName"
                $list12.Columns[3].width = 150
                $list12.Columns[4].text = "Queued"
                $list12.Columns[4].width = 150
                $list12.Columns[5].text = "SpoolEnabled"
                $list12.Columns[5].width = 150
                $list12.Columns[6].text = "Shared"
                $list12.Columns[6].width = 150
    
                $systeminfoerror = $null
    
                $stBar1.text = "Getting a list of printers from " + $computername.ToUpper() + "..."
                $printers = Get-WmiObject -class Win32_printer -ComputerName $computername -Property * | Select-Object -ev systeminfoerror
    
                if (!($systeminfoerror)) {
                    $AllInfo = foreach ($printer in $printers) {
    
                        $i++
                        [int]$pct = ($i / $printers.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
                        start-sleep -Milliseconds 15
            
                        $PSObject = New-Object PSObject -Property @{
                            Name         = [string]$printer.Name
                            DriverName   = [string]$printer.DriverName
                            Default      = [string]$printer.Default
                            PortName     = [string]$printer.PortName
                            Queued       = [string]$printer.Queued
                            SpoolEnabled = [string]$printer.SpoolEnabled
                            Shared       = [string]$printer.Shared
                        }
                        $PSObject | Select-Object Name, DriverName, Default, PortName, Queued, SpoolEnabled, Shared
                    }
    
                    $columnproperties = "Name", "DriverName", "Default", "PortName", "Queued,SpoolEnabled,Shared"
                    foreach ($d in $AllInfo) {
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($d.Name)
    
                        if ($null -eq $d.DriverName) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.DriverName) }
        
                        if ($null -eq $d.Default) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Default) }
    
                        if ($null -eq $d.PortName) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.PortName) }
    
                        if ($null -eq $d.Queued) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Queued) }
    
                        if ($null -eq $d.SpoolEnabled) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.SpoolEnabled) }
    
                        if ($null -eq $d.Shared) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Shared) }
    
                        $item.Tag = $d
                        $list12.Items.Add($item) > $null
                    }
    
                    $stBar1.text = "Printers on " + $computername.ToUpper() + " (" + $Printers.count + ")"
                }
                else { $stBar1.text = "There was an issue getting a list of printers from " + $computername.ToUpper() }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed printers on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #############################
    ### OPENS EXPLORER/NOTEPAD ##
    #############################
    Function AdminExp {
        $vbmsg.popup("When Notepad Opens, click 'File' then 'Open' and enter the host name of the computer. Example: '\\computer-123456\C$\'. Make sure you select 'All Files' from the dropdown to view all file extentions.", 0, "Notice", 0)
        Start-Process Notepad.exe
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran Notepad as admin on " + $env:computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ##########################
    ## Opens Print Management#
    ##########################
    Function PrintMan {
        Start-Process printmanagement.msc
        $vbmsg.popup("Manage another computers printers by right-clicking the 'Print Servers' icon in the left pane and clicking 'Add/Remove Servers'.", 0, "Notice", 0)
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened Print Management" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ########################
    #### REMOTE DESKTOP ####
    ########################
    $btn4_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        $stBar1.text = "Pinging " + $computername.ToUpper()
        if (Test-Connection $Computername -quiet -count 1) {
            $remote = "mstsc.exe /v:" + $computername
            Invoke-Expression $remote
            $stBar1.text = "Launched Remote Desktop"
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran Remote Desktop on " + $computername | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
    }
    
    #######################
    ### Local Run As Fix ##
    #######################
    Function RunAsLocal {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar  
        $stBar1.text = "Setting 'Run-As' registry values on this computer..."
        [int]$pct = (1 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser -Value 1
        Start-Sleep 1
        [int]$pct = (2 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 2
        Start-Sleep 1 
        [int]$pct = (3 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if (((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser).ConsentPromptBehaviorUser -eq 1) -and ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin).ConsentPromptBehaviorAdmin -eq 2)) {
            $vbmsg.popup("'Run As' is active on --> this PC <-- until next GPO push!", 0, "Notice", 0)
            $stBar1.text = "Setting 'Run-As' registry values on this computer... (COMPLETE!)"
        }
        Else { $vbmsg.popup("Failed to set the 'Run-As' values...", 0, "Notice", 0) }
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran run-as fix on " + $env:computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    } #End Run As Fix scriptblock
    
    ########################
    ## REMOTE RUN AS FIX ###
    ########################
    Function RunAsRemote {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $lbl2.Visible = $true
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Sending 'Run As' Fix to " + $computername.ToUpper()
                Invoke-Command -ComputerName $computername -ScriptBlock {        
                    Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser -Value 1
                    Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 2
                }
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Start-Sleep 1
                if (invoke-command -ComputerName $computername -ScriptBlock { (((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorUser).ConsentPromptBehaviorUser -eq 1) -and ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin).ConsentPromptBehaviorAdmin -eq 2)) }) {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "'Run As' fixed on " + $computername.ToUpper()
                    $vbmsg.popup("'Run As' is active on " + $computername.ToUpper() + " until next GPO push!", 0, "Notice", 0)
                }
                Else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Failed to set the 'Run-As' values..."
                }
        
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran remote run-as fix on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }        
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End of 'Run As' Fix
    
    ###################################################
    #### Input Box for Remove User Profile by Days ####
    ###################################################
    
    Function ProInputBox {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Remove Profiles'
        $msg = 'Enter the number of days the users will be remove after:
    Example: 30 (for 30 days) or 90 (for 90 days)'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    
    ##################################
    ## Remove User Profiles By Days ##
    ##################################
    Function ProRemoveDate {
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $ExemptUsers = "SDC_Admin", "Administrator", "USAF_Admin", "Public", "Default", "ACE_Admin"
                $stBar1.text = "Requesting number of days..."
                $Days = ProInputBox
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                if ($Days -ne "") {
    
                    # For WMI Accounts
                    $Profiles_to_remove = Get-ChildItem "\\$Computername\c$\Users" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Days) } | Select-Object -ExpandProperty Name
                    $Profiles = Get-WMIObject -class Win32_UserProfile -ComputerName $Computername | Where-Object { (!$_.Special) -and ((Split-Path $_.localpath -Leaf) -notin $ExemptUsers) -and ((Split-Path $_.localpath -Leaf) -in $Profiles_to_remove) }
                    $ProfileList = $Profiles.LocalPath | Out-String
    
                    # For Orphand Accounts
                    $Profiles2 = Get-WMIObject -class Win32_UserProfile -ComputerName $Computername | Where-Object { (!$_.Special) -and ((Split-Path $_.localpath -Leaf) -notin $ExemptUsers) }
                    $Folders_to_remove = Get-ChildItem "\\$Computername\c$\Users" | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddDays(-$Days)) -and ($_.Name -notin $ExemptUsers) -and ($_.Name -notin (Split-Path $Profiles2.localpath -Leaf)) }
                    $FolderList = $Folders_to_remove.Name | Out-String
    
                    $stBar1.text = "Gathering profiles to remove..."
                    Start-Sleep 1
    
                    $lbl2.text += "`t`t`t`t`t Profiles to be removed " + $Days + " days and older."
                    $lbl2.text += "`n"
                    $lbl2.text += "`t`t`t`t`t                    Number of profiles: " + $profiles.count
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "$ProfileList"
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "`t`t`t`t          Orphand profiles to be removed " + $Days + " days and older."
                    $lbl2.text += "`n"
                    $lbl2.text += "`t`t`t`t                            Number of orphand profiles: " + $Folders_to_remove.count
                    $lbl2.text += "`n"
                    $lbl2.text += "`n"
                    $lbl2.text += "$FolderList"
                    start-sleep 1
                    # Remove WMI Objects
                    if ($Null -ne $Profiles) { 
                        foreach ($P in $Profiles) {
    
                            $i++
                            [int]$pct = ($i / $Profiles.count) * 100
                            #update the progress bar
                            $progress1.Value = $pct
    
                            if ($Null -ne $P) {
                                $stBar1.text = "Removing " + ($P | Select-Object -ExpandProperty localpath) + " (" + $i + " of " + $Profiles.count + ")"
                                $P | Remove-WmiObject -ErrorVariable errorness
                                If ($errorness) { $stBar1.text = "There was an error removing " + ($P | Select-Object -ExpandProperty localpath) }
                                Start-Sleep 2
                            }
                            Else {
                                $stBar1.text = "Issue removing " + ($P | Select-Object -ExpandProperty localpath) + " (" + $i + " of " + $Profiles.count + ")"
                            }
                            Start-Sleep 1
                        }
                        $stBar1.text = "Done removing " + $profiles.count + " profile(s) and deleting " + $Folders_to_remove.count + " orphand folder(s) on " + $computername.ToUpper()
                    }
    
                    # Remove Orphand Profiles
                    if ($Null -ne $Folders_to_remove) {
                        foreach ($N in $Folders_to_remove) {
    
                            $b++
                            [int]$pct = ($b / $Folders_to_remove.count) * 100
                            #update the progress bar
                            $progress1.Value = $pct        
            
                            if ($Null -ne $N) {
                                $stBar1.text = "Deleting orphand folder: " + $N + " (" + $b + " of " + $Folders_to_remove.count + ")"
                                Remove-Item -path "\\$computername\C$\Users\$N" -Recurse -Force -ErrorVariable errorness2
                                If ($errorness2) { $stBar1.text = "There was an issue deleting orphand folder " + $N }
                                Start-Sleep 2
                            }
                            Else {
                                $stBar1.text = "Issue deleting orphand folder: " + $N + " (" + $b + " of " + $Folders_to_remove.count + ")"
                                Start-Sleep 1
                            }
                        }
                        $stBar1.text = "Done removing " + $profiles.count + " profile(s) and deleting " + $Folders_to_remove.count + " orphand folder(s) on " + $computername.ToUpper()
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Removed " + $profiles.count + " profile(s) and deleted " + $Folders_to_remove.count + " orphand folder(s) on " + $computername + " based on " + $Days + " days." | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else { $stBar1.text = "No days were entered or action was cancelled..." }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ###################################################
    #### Input Box for Remove User Profile by User ####
    ###################################################
    Function ProRegInput {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Remove Profiles'
        $msg = 'Enter the users to remove (EDIPIs):
    NOTE: Dont put spaces between the commas...
    Example: 1234567890A,9876543210V,7418529630C'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ##################################
    #### Delete user via registry ####
    ##################################
    $btn24_OnClick =
    {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Requesting users..."
                $UserList = ProRegInput
                $Profiles_to_remove = $UserList.Split(",").Trim()
    
                if ($UserList -ne "") {
    
                    ###### Delete reg entry and folder #######
                    foreach ($Profile in $Profiles_to_remove) {
                        $FullPro = "C:\Users\$Profile"
    
                        $m++
                        [int]$pct = ($m / $Profiles_to_remove.count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $stBar1.text = "Removing profile " + $Profile + " (" + $m + " of " + $Profiles_to_remove.count + ")"
    
                        if (((Invoke-Command -ComputerName $computername -ArgumentList $FullPro -ScriptBlock { Param($FullPro); Get-ItemProperty -Path 'HKLM:\software\Microsoft\Windows NT\CurrentVersion\ProfileList\*' -ErrorAction SilentlyContinue | Where-Object { $_.ProfileImagePath -eq $FullPro } }).pspath).count -gt 0) {
                            $t++
                            $GetProPath = (Invoke-Command -ComputerName $computername -ArgumentList $FullPro -ScriptBlock { Param($FullPro); Get-ItemProperty -Path 'HKLM:\software\Microsoft\Windows NT\CurrentVersion\ProfileList\*' -ErrorAction SilentlyContinue | Where-Object { $_.ProfileImagePath -eq $FullPro } }).PSPath -Split ("\\") | Select-Object -Index 7
                            Invoke-Command -ComputerName $computername -ArgumentList $GetProPath -ScriptBlock { Param($GetProPath); Remove-Item -Path "HKLM:\software\Microsoft\Windows NT\CurrentVersion\ProfileList\$GetProPath" -Recurse -Force -ErrorAction SilentlyContinue }
                            Start-Sleep 1
                        }
                        if ((Get-ItemProperty -Path "\\$computername\C$\Users\$Profile" -ErrorAction SilentlyContinue).count -gt 0) {
                            $k++
                            #Invoke-Command -ComputerName $computername -ArgumentList $FullPro -ScriptBlock {Param($FullPro); Get-Item $FullPro | Remove-Item -Force -Recurse}
                            Remove-Item -Path "\\$computername\C$\Users\$Profile" -Recurse -Force
                            Start-Sleep 1
                        }
                    }
                    if ($Null -eq $t) { $t = "0" }
                    if ($Null -eq $k) { $k = "0" }
                    $stBar1.text = "Removed " + $t + " registry value(s) and " + $k + " user folder(s) for " + $Profiles_to_remove.count + " profile(s)."
                    Start-Sleep 1
                    Clear-Variable k, t -ErrorAction SilentlyContinue
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Removed " + $profiles.count + " profile(s) and deleted " + $Folders_to_remove.count + " orphand folder(s) on " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else { $stBar1.text = "Profile names/EDIPIs were not entered or action was cancelled..." }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #################################
    ## List Profiles by User Cell  ##
    #################################
    function ProRemoveUser {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            ClearGrid
            HideUnusedItems
            $list10.visible = $true
            $lbl2.Visible = $false
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            if (test-connection $computername -quiet -count 1) {
    
                $list10.Columns[0].text = "User"
                $list10.Columns[0].width = 150
                $list10.Columns[1].text = "Size (MB)"
                $list10.Columns[1].width = 100
                $list10.Columns[2].text = "Last Accessed"
                $list10.Columns[2].width = 200
                $list10.Columns[3].text = "Last Written"
                $list10.Columns[3].width = ($list10.width - $list10.columns[0].width - 25)
    
                $systeminfoerror = $null
    
                ########## Folder Pull ##########
                $stBar1.text = "Getting profiles from " + $computername.ToUpper() + "'s users folder..."
                Start-Sleep 1
                $Users = Get-Childitem "\\$ComputerName\c$\Users"
                $Pull1 = foreach ($user in $Users) {
    
                    $i++
                    [int]$pct = ($i / $Users.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $Sizer = "{0:N1}" -f ((Get-ChildItem $user.fullname -Recurse | Measure-Object -Property length -Sum -Maximum -ErrorAction SilentlyContinue).sum / 1MB)
                    $PSObject = New-Object PSObject -Property @{
                        User         = [string]$User.Name
                        Size         = [string]$Sizer
                        LastAccessed = [string]$user.LastAccessTime
                        LastWritten  = [string]$user.LastWriteTime
                    }
                    $PSObject | Select-Object User, Size, LastAccessed, LastWritten | Sort-Object User
                }
    
                ########## WMI Pull ##########
                $stBar1.text = "Getting profiles from " + $computername.ToUpper() + "'s WMI entries..."
                Start-Sleep 1
                $Users2 = Get-WMIObject -class Win32_UserProfile -ComputerName $computername
                $Pull2 = foreach ($user2 in $Users2) {
    
                    $h++
                    [int]$pct = ($h / $Users2.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $PSObject = New-Object PSObject -Property @{
                        User         = $user2.LocalPath -Split ("\\") | Select-Object -Index 2 | Out-String
                        Size         = "System Entry"
                        LastAccessed = $user2.LastUseTime | Out-String
                        LastWritten  = "System Entry"
                    }
                    $PSObject | Select-Object User, Size, LastAccessed, LastWritten | Sort-Object LastAccessed
                }
    
                $Both = $Pull1 + $Pull2
    
                $columnproperties = "User", "Size", "LastAccessed", "LastWritten"
                foreach ($d in $Both) {
    
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($d.user)
    
                    if ($null -eq $d.Size) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.Size) }
        
                    if ($null -eq $d.LastAccessed) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LastAccessed) }
    
                    if ($null -eq $d.LastWritten) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LastWritten) }
    
                    $item.Tag = $d
                    $list10.Items.Add($item) > $null
                }
                $stBar1.text = "User profiles on " + $computername.ToUpper() + " (" + $Users.count + "). Select profiles to remove with Ctrl + click."
                $btn23.Visible = $true
                $btn24.Visible = $true
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed " + $Users.count + " profile(s) on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #################
    ## Remove User ##
    #################
    $btn23_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if ($list10.selecteditems.count -lt 1) { $vbmsg1 = $vbmsg.popup("Please select a profile to remove.", 0, "Error", 0) }
        else {
            $stBar1.text = "Looking up user(s)..."
            $exprString2 = '$list10.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.user}'
            $Profiles_to_remove2 = invoke-expression $exprString2
            [pscustomobject]$Profiles_to_remove = $Profiles_to_remove2.trim()
    
            # Get and remove WMI Profiles
            $Profiles = Get-WmiObject -Class Win32_UserProfile -ComputerName $Computername | Where-Object { (Split-Path $_.localpath -Leaf) -in $Profiles_to_remove }
            $Count = $profiles | Select-Object -ExpandProperty localpath
    
            # For Orphand Accounts
            $Profiles3 = Get-WmiObject -Class Win32_UserProfile -ComputerName $Computername | Where-Object { Split-Path $_.localpath -Leaf }
            $Folders_to_remove = Get-ChildItem "\\$Computername\c$\Users" | Where-Object { ($_.Name -in $Profiles_to_remove) -and ($_.Name -notin (Split-Path $Profiles3.localpath -Leaf)) }
    
            if ($Null -ne $Profiles) {
                foreach ($P in $Profiles) {
                    # Removing WMI Profiles
    
                    $t++
                    [int]$pct = ($t / $Count.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $stBar1.text = "Removing " + ($P | Select-Object -ExpandProperty localpath) + " (" + $t + " of " + $Count.count + ")"
    
                    if ($Null -ne $P) {
                        $P | Remove-WmiObject -ev errorness
                        If ($errorness) {
                            $stBar1.text = "There was an error removing " + ($P | Select-Object -ExpandProperty localpath)
                            Start-Sleep 3
                        }
                    }
                }
                Start-Sleep -Milliseconds 500
            }
            if ($Null -ne $Folders_to_remove) {
                # Remove Orphand Profiles
                foreach ($J in $Folders_to_remove) {
    
                    $z++
                    [int]$pct = ($z / $Folders_to_remove.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $stBar1.text = "Removing orphand profile " + $J + " (" + $z + " of " + $Folders_to_remove.count + ")"
    
                    if ($Null -ne $J) {
                        #Invoke-Command -ComputerName $computername -ArgumentList $J -ScriptBlock {Param($J); Remove-Item -Path "C:\Users\$J" -Recurse -Force -ErrorAction SilentlyContinue}
                        Remove-Item -Path "\\$computername\C$\Users\$J" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            $stBar1.text = "Done removing " + $Profiles_to_remove.count + " profile(s)"
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Removed " + $Profiles_to_remove.count + " profile(s) on " + $computername | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        Clear-Variable Profiles_to_remove -ErrorAction SilentlyContinue
    }
    
    
    
    ##################
    # FILE STRUCTURE #
    ##################
    $btn6_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $files = "\\" + $computername + "\c$"
                Start-Process explorer $files -Verb runAs
                $stBar1.text = "Opened file explore on " + $computername.ToUpper() + "'s root C: drive."
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened C$ share on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ######################
    # Open Computer List #
    ######################
    $btn15_OnClick = 
    {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\ComputerList\computers.txt")) {
            New-Item "$env:SystemDrive\Admin_Tool\ComputerList\computers.txt" -ItemType File -Force
        }
        Notepad.exe $env:SystemDrive\Admin_Tool\ComputerList\computers.txt
    }
    
    # Open Folder for Files to be Installed #
    $btn5_OnClick =
    {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\InstallFile")) {
            New-Item "$env:SystemDrive\Admin_Tool\InstallFile" -ItemType Directory -Force
        }
        Invoke-Item $env:SystemDrive\Admin_Tool\InstallFile
    }
    
    ####################
    # RESTART COMPUTER #
    ####################
    $btn7_OnClick = 
    {
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (2 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $vbrestart = $vbmsg.popup("Are you sure you want to restart " + $computername.ToUpper() + "?", 0, "Restart " + $computername.ToUpper() + "?", 4)
                [int]$pct = (3 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                switch ($vbrestart) {
                    6 {
                        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                        restart-computer -force -computername $computername
                        $stBar1.text = "Restarted " + $computername.ToUpper()
                    }
                    7 { $stBar1.text = "Cancelled restart of " + $computername.ToUpper() }
                }
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Remotely restarted computer " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #######################
    #### Multi Restart ####
    #######################
    Function MultiRestart {
        $stBar1.text = "Launching 'Shutdown.exe' program..."
        If (!([System.IO.File]::Exists("C:\Windows\system32\shutdown.exe"))) { $stBar1.text = "The file 'shutdown.exe' doesn't exist in the system32 folder..." }
        else {
            shutdown.exe /i
            $stBar1.text = "Done launching 'Shutdown.exe' program..."
        }
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened Windows shutdown utility" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ##############################
    ###### SHOW CONNECTIONS ######
    ##############################
    Function Connections {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            ClearGrid
            HideUnusedItems
            $list6.visible = $true
            $lbl2.Visible = $false
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            if (test-connection $computername -quiet -count 1) {
                $stBar1.text = "Connections on " + $computername.ToUpper() + " (Loading...)"
    
    
                $list6.Columns[0].text = "ComputerName"
                $list6.Columns[0].width = 150
                $list6.Columns[1].text = "Protocol"
                $list6.Columns[1].width = 150
                $list6.Columns[2].text = "State"
                $list6.Columns[2].width = 150
                $list6.Columns[3].text = "LocalAddress"
                $list6.Columns[3].width = 150
                $list6.Columns[4].text = "LocalPort"
                $list6.Columns[4].width = 150
                $list6.Columns[5].text = "RemoteAddress"
                $list6.Columns[5].width = 150
                $list6.Columns[6].text = "RemoteHostName"
                $list6.Columns[6].width = 150
                $list6.Columns[7].text = "RemotePort"
                $list6.Columns[7].width = 150
                $list6.Columns[8].text = "CreationTime"
                $list6.Columns[8].width = 150
                $list6.Columns[9].text = "Processname"
                $list6.Columns[9].width = 150
                $list6.Columns[10].text = "UserName"
                $list6.Columns[10].width = 150
                $list6.Columns[11].text = "OwningProcess"
                $list6.Columns[11].width = ($list6.width - $list6.columns[0].width - 25)
    
                $systeminfoerror = $null
    
                $procs = Invoke-Command -ComputerName $computername -ScriptBlock {
                    $Processes = @{}
                    Get-Process -IncludeUserName | ForEach-Object { $Processes[$_.Id] = $_ }
    
                    $TCP = Get-NetTCPConnection | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "TCP" } }, State, LocalAddress, LocalPort, RemoteAddress, @{Name = "RemoteHostName"; Expression = { ([System.Net.Dns]::GetHostEntry($_.RemoteAddress)).HostName } }, RemotePort, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
                    $UDP = Get-NetUDPEndpoint | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "UDP" } }, @{Name = "State"; Expression = { "" } }, LocalAddress, LocalPort, @{Name = "RemoteAddress"; Expression = { "" } }, @{Name = "RemoteHostName"; Expression = { "" } }, @{Name = "RemotePort"; Expression = { "" } }, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
    
                    $Both = $TCP + $UDP
                    $Both | Select-Object ComputerName, Protocol, State, LocalAddress, LocalPort, RemoteAddress, RemoteHostName, RemotePort, CreationTime, ProcessName, UserName, OwningProcess | Sort-Object LocalPort
                } -ev systeminfoerror
    
                if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
                else {
                    $columnproperties = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
                    foreach ($d in $procs) {
         
                        $i++
                        [int]$pct = ($i / $procs.count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($d.ComputerName)
    
                        if ($null -eq $d.Protocol) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Protocol) }
        
                        if ($null -eq $d.State) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.State) }
    
                        if ($null -eq $d.LocalAddress) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.LocalAddress) }
    
                        if ($null -eq $d.LocalPort) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.LocalPort) }
    
                        if ($null -eq $d.RemoteAddress) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.RemoteAddress) }
    
                        if ($null -eq $d.RemoteHostName) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.RemoteHostName) }
    
                        if ($null -eq $d.RemotePort) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.RemotePort) }
    
                        if ($null -eq $d.CreationTime) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.CreationTime) }
    
                        if ($null -eq $d.ProcessName) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.ProcessName) }
    
                        if ($null -eq $d.UserName) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.UserName) }
    
                        if ($null -eq $d.OwningProcess) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.OwningProcess) }
    
                        $item.Tag = $d
                        $list6.Items.Add($item) > $null
                    }
                    $stBar1.text = "Connections on " + $computername.ToUpper()
                    $btn21.Visible = $true
                }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed all connections on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper() 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End show connections
    
    #########################
    ### INPUT PORT NUMBER ###
    #########################
    Function Get-Port {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Port Scanner'
        $msg = 'Enter a port number (only one):
    Example: 23, 80, 123, or 2701
    
    After clicking OK, you will be prompted to select 
    a text file with computer names (.txt only).'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    ####################
    ### PORT SCANNER ###
    ####################
    Function PortScan {
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        ClearGrid
        HideUnusedItems
        $list7.visible = $true
        $lbl2.Visible = $false
    
        $stBar1.text = "Enter the port number..."
        $Port = Get-Port
    
        if (!("$Port" -eq "")) {
    
            $stBar1.text = "Select a List of Computers (text file only)"
            $Computernames = Get-FileName
            $ComputerName = Get-Content $ComputerNames -ErrorAction SilentlyContinue
            if ($null -ne $ComputerName) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
                $stBar1.text = "Checking Computer List..."
                Start-Sleep 1
    
                $list7.Columns[0].text = "ComputerName"
                $list7.Columns[0].width = 150
                $list7.Columns[1].text = "Protocol"
                $list7.Columns[1].width = 150
                $list7.Columns[2].text = "State"
                $list7.Columns[2].width = 150
                $list7.Columns[3].text = "LocalAddress"
                $list7.Columns[3].width = 150
                $list7.Columns[4].text = "LocalPort"
                $list7.Columns[4].width = 150
                $list7.Columns[5].text = "RemoteAddress"
                $list7.Columns[5].width = 150
                $list7.Columns[6].text = "RemoteHostName"
                $list7.Columns[6].width = 150
                $list7.Columns[7].text = "RemotePort"
                $list7.Columns[7].width = 150
                $list7.Columns[8].text = "CreationTime"
                $list7.Columns[8].width = 150
                $list7.Columns[9].text = "Processname"
                $list7.Columns[9].width = 150
                $list7.Columns[10].text = "UserName"
                $list7.Columns[10].width = 150
                $list7.Columns[11].text = "OwningProcess"
                $list7.Columns[11].width = ($list7.width - $list7.columns[0].width - 25)
    
                function Scanner {
                    $PCData = foreach ($PC in $ComputerName) {
    
                        $running = @(Get-Job -State Running)
                        if ($running.Count -ge 25) {
                            $null = $running | Wait-Job -Any
                        }
    
                        $i++
                        [int]$pct = ($i / $ComputerName.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $stBar1.text = "Starting service scan job for " + $PC + " (" + $i + " of " + $ComputerName.count + ")"
    
                        Start-Job -Name "$PC" -ArgumentList $PC, $ComputerName, $PCData, $Port -ScriptBlock {
                            param($PC, $ComputerName, $PCData, $Port)
    
                            if (Invoke-Command -ComputerName $PC -ArgumentList $Port -ScriptBlock {
                                    param($Port)
        
        (Get-NetTCPConnection | where-object { $_.LocalPort -eq $port }) -or (Get-NetUDPEndpoint | where-object { $_.LocalPort -eq $port })
                                } -ErrorAction SilentlyContinue
                            ) {
                                Invoke-Command -ComputerName $PC -ArgumentList $Port -ScriptBlock {
                                    param($Port)
    
                                    $Processes = @{}
                                    Get-Process -IncludeUserName | ForEach-Object { $Processes[$_.Id] = $_ }
            
                                    $TCP = Get-NetTCPConnection | where-object { $_.LocalPort -eq $port } | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "TCP" } }, State, LocalAddress, LocalPort, RemoteAddress, @{Name = "RemoteHostName"; Expression = { ([System.Net.Dns]::GetHostEntry($_.RemoteAddress)).HostName } }, RemotePort, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
                                    $UDP = Get-NetUDPEndpoint | where-object { $_.LocalPort -eq $port } | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "UDP" } }, @{Name = "State"; Expression = { "" } }, LocalAddress, LocalPort, @{Name = "RemoteAddress"; Expression = { "" } }, @{Name = "RemoteHostName"; Expression = { "" } }, @{Name = "RemotePort"; Expression = { "" } }, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
                                    $Both = $TCP + $UDP
                                    $Both | Select-Object ComputerName, Protocol, State, LocalAddress, LocalPort, RemoteAddress, RemoteHostName, RemotePort, CreationTime, ProcessName, UserName, OwningProcess
                                }
                            }
                            elseif (Test-Connection -ComputerName $PC -Count 1 -BufferSize 32 -ErrorAction SilentlyContinue) { 
                                # Port doesn't exist
                                $Props = @{
                                    ComputerName   = [string]$PC.ToUpper()
                                    Protocol       = 'Non-existent Port'
                                    State          = ''
                                    LocalAddress   = ''
                                    LocalPort      = ''
                                    RemoteAddress  = ''
                                    RemoteHostName = ''
                                    RemotePort     = ''
                                    CreationTime   = ''
                                    Processname    = ''
                                    UserName       = ''
                                    OwningProcess  = ''
                                }
                                New-Object -TypeName PSObject -Property $Props            
                            }
                            else {
                                # ping failed
                                $Props = @{
                                    ComputerName   = [string]$PC.ToUpper()
                                    Protocol       = 'Offline'
                                    State          = ''
                                    LocalAddress   = ''
                                    LocalPort      = ''
                                    RemoteAddress  = ''
                                    RemoteHostName = ''
                                    RemotePort     = ''
                                    CreationTime   = ''
                                    Processname    = ''
                                    UserName       = ''
                                    OwningProcess  = ''
                                }
                                New-Object -TypeName PSObject -Property $Props
                            }           
                        }
                    }
                    $stBar1.text = "Collecting Info From PCs in List (Please Wait...)"
                    $PCData | Wait-Job | Receive-Job
                    $stBar1.text = "Cleaning Up and Reporting Results..."
                    $PCData | Remove-Job
                }
    
                $procs = Scanner | Select-Object ComputerName, Protocol, State, LocalAddress, LocalPort, RemoteAddress, RemoteHostName, RemotePort, CreationTime, ProcessName, UserName, OwningProcess
    
                [int]$pct = (0 / 1) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $columnproperties = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
                foreach ($d in $procs) {
         
                    $i++
                    [int]$pct = ($i / $procs.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($d.ComputerName)
    
                    if ($null -eq $d.Protocol) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.Protocol) }
        
                    if ($null -eq $d.State) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.State) }
    
                    if ($null -eq $d.LocalAddress) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LocalAddress) }
    
                    if ($null -eq $d.LocalPort) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LocalPort) }
    
                    if ($null -eq $d.RemoteAddress) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemoteAddress) }
    
                    if ($null -eq $d.RemoteHostName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemoteHostName) }
    
                    if ($null -eq $d.RemotePort) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemotePort) }
    
                    if ($null -eq $d.CreationTime) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.CreationTime) }
    
                    if ($null -eq $d.ProcessName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.ProcessName) }
    
                    if ($null -eq $d.UserName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.UserName) }
    
                    if ($null -eq $d.OwningProcess) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.OwningProcess) }
    
                    $item.Tag = $d
                    $list7.Items.Add($item) | Out-Null
                }
                $stBar1.text = "Scanned port " + $Port + " for " + $ComputerName.Count + " computers."
                $btn21.Visible = $true
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched port " + $Port + " on " + $ComputerName.Count + " computers" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Action cancelled or no file selected..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    } #End show connections
    
    ##########################
    ### INPUT SERVICE NAME ###
    ##########################
    Function Get-Svc {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Service Scanner'
        $msg = 'Enter a service name (only one):
    Example: Chrome, AdHoc, or Firefox
    
    After clicking OK, you will be prompted to select 
    a text file with computer names (.txt only).'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    ########################
    ### SERVICE SCANNER  ###
    ########################
    Function ServiceScanner {
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        ClearGrid
        HideUnusedItems
        $list9.visible = $true
        $lbl2.Visible = $false
    
        $stBar1.text = "Enter the service name..."
        $svc = Get-Svc
    
        if (!("$svc" -eq "")) {
    
            $stBar1.text = "Select a List of Computers (text file only)"
            $Computernames = Get-FileName
            $ComputerName = Get-Content $ComputerNames -ErrorAction SilentlyContinue
            if ($null -ne $ComputerName) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
                $stBar1.text = "Checking Computer List..."
                Start-Sleep 1
    
                $list9.Columns[0].text = "ComputerName"
                $list9.Columns[0].width = 150
                $list9.Columns[1].text = "Protocol"
                $list9.Columns[1].width = 150
                $list9.Columns[2].text = "State"
                $list9.Columns[2].width = 150
                $list9.Columns[3].text = "LocalAddress"
                $list9.Columns[3].width = 150
                $list9.Columns[4].text = "LocalPort"
                $list9.Columns[4].width = 150
                $list9.Columns[5].text = "RemoteAddress"
                $list9.Columns[5].width = 150
                $list9.Columns[6].text = "RemoteHostName"
                $list9.Columns[6].width = 150
                $list9.Columns[7].text = "RemotePort"
                $list9.Columns[7].width = 150
                $list9.Columns[8].text = "CreationTime"
                $list9.Columns[8].width = 150
                $list9.Columns[9].text = "Processname"
                $list9.Columns[9].width = 150
                $list9.Columns[10].text = "UserName"
                $list9.Columns[10].width = 150
                $list9.Columns[11].text = "OwningProcess"
                $list9.Columns[11].width = ($list9.width - $list9.columns[0].width - 25)
    
                function Scanner {
                    $PCData = foreach ($PC in $ComputerName) {
    
                        $running = @(Get-Job -State Running)
                        if ($running.Count -ge 25) {
                            $null = $running | Wait-Job -Any
                        }
    
                        $i++
                        [int]$pct = ($i / $ComputerName.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $stBar1.text = "Starting service scan job for " + $PC + " (" + $i + " of " + $ComputerName.count + ")"
    
                        Start-Job -Name "$PC" -ArgumentList $PC, $ComputerName, $PCData, $svc -ScriptBlock {
                            param($PC, $ComputerName, $PCData, $svc)
    
                            if (Invoke-Command -ComputerName $PC -ArgumentList $svc -ScriptBlock {
                                    param($svc)
                                    $Processes = @{}
                                    Get-Process -IncludeUserName | ForEach-Object { $Processes[$_.Id] = $_ }
        
        (Get-NetTCPConnection | where-object { $Processes[[int]$_.OwningProcess].ProcessName -eq $svc }) -or (Get-NetUDPEndpoint | where-object { $Processes[[int]$_.OwningProcess].ProcessName -eq $svc })
                                } -ErrorAction SilentlyContinue
                            ) {
    
                                Invoke-Command -ComputerName $PC -ArgumentList $svc -ScriptBlock {
                                    param($svc)
                                    $Processes = @{}
                                    Get-Process -IncludeUserName | ForEach-Object { $Processes[$_.Id] = $_ }
            
                                    $TCP = Get-NetTCPConnection | where-object { $Processes[[int]$_.OwningProcess].ProcessName -eq $svc } | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "TCP" } }, State, LocalAddress, LocalPort, RemoteAddress, @{Name = "RemoteHostName"; Expression = { ([System.Net.Dns]::GetHostEntry($_.RemoteAddress)).HostName } }, RemotePort, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
                                    $UDP = Get-NetUDPEndpoint | where-object { $Processes[[int]$_.OwningProcess].ProcessName -eq $svc } | Select-Object @{Name = "ComputerName"; Expression = { $env:COMPUTERNAME } }, @{Name = "Protocol"; Expression = { "UDP" } }, @{Name = "State"; Expression = { "" } }, LocalAddress, LocalPort, @{Name = "RemoteAddress"; Expression = { "" } }, @{Name = "RemotePort"; Expression = { "" } }, @{Name = "Creationtime"; Expression = { $_.CreationTime | Out-String } }, @{Name = "ProcessName"; Expression = { $Processes[[int]$_.OwningProcess].ProcessName } }, @{Name = "UserName"; Expression = { $Processes[[int]$_.OwningProcess].UserName } }, OwningProcess
    
                                    $Both = $TCP + $UDP
                                    $Both | Select-Object ComputerName, Protocol, State, LocalAddress, LocalPort, RemoteAddress, RemoteHostName, RemotePort, CreationTime, ProcessName, UserName, OwningProcess
                                }
                            }
                            elseif (Test-Connection -ComputerName $PC -Count 1 -BufferSize 32 -ErrorAction SilentlyContinue) { 
                                # Port doesn't exist
                                $Props = @{
                                    ComputerName   = $PC.ToUpper()
                                    Protocol       = 'Non-existent Service'
                                    State          = ''
                                    LocalAddress   = ''
                                    LocalPort      = ''
                                    RemoteAddress  = ''
                                    RemoteHostName = ''
                                    RemotePort     = ''
                                    CreationTime   = ''
                                    Processname    = ''
                                    UserName       = ''
                                    OwningProcess  = ''
                                }
                                New-Object -TypeName PSObject -Property $Props            
                            }
                            else {
                                # ping failed
                                $Props = @{
                                    ComputerName   = $PC.ToUpper()
                                    Protocol       = 'Offline'
                                    State          = ''
                                    LocalAddress   = ''
                                    LocalPort      = ''
                                    RemoteAddress  = ''
                                    RemoteHostName = ''
                                    RemotePort     = ''
                                    CreationTime   = ''
                                    Processname    = ''
                                    UserName       = ''
                                    OwningProcess  = ''
                                }
                                New-Object -TypeName PSObject -Property $Props
                            }           
                        }
                    }
                    [int]$pct = (1 / 1) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Collecting Info From PCs in List. Please Wait..."
                    $PCData | Wait-Job | Receive-Job
                    $stBar1.text = "Cleaning Up & Reporting Results..."
                    $PCData | Remove-Job
                }
    
                $procs = Scanner | Select-Object ComputerName, Protocol, State, LocalAddress, LocalPort, RemoteAddress, RemoteHostName, RemotePort, CreationTime, ProcessName, UserName, OwningProcess
    
                $columnproperties = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
                foreach ($d in $procs) {
         
                    $i++
                    [int]$pct = ($i / $procs.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($d.ComputerName)
    
                    if ($null -eq $d.Protocol) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.Protocol) }
        
                    if ($null -eq $d.State) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.State) }
    
                    if ($null -eq $d.LocalAddress) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LocalAddress) }
    
                    if ($null -eq $d.LocalPort) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.LocalPort) }
    
                    if ($null -eq $d.RemoteAddress) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemoteAddress) }
    
                    if ($null -eq $d.RemoteHostName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemoteHostName) }
    
                    if ($null -eq $d.RemotePort) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.RemotePort) }
    
                    if ($null -eq $d.CreationTime) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.CreationTime) }
    
                    if ($null -eq $d.ProcessName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.ProcessName) }
    
                    if ($null -eq $d.UserName) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.UserName) }
    
                    if ($null -eq $d.OwningProcess) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($d.OwningProcess) }
    
                    $item.Tag = $d
                    $list9.Items.Add($item) > $null
                }
                $stBar1.text = "Scanned service " + $svc + " for " + $ComputerName.Count + " computers."
                $btn21.Visible = $true
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched service " + $svc + " on " + $ComputerName.Count + " computers" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Action cancelled or no file selected..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    } #End show connections
    
    ####################
    ## END CONNECTION ##
    ####################
    $btn21_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if ($list6.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one connection to terminate at a time.", 0, "Error", 0) }
        elseif ($list7.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one connection to terminate at a time.", 0, "Error", 0) }
        elseif ($list9.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one connection to terminate at a time.", 0, "Error", 0) }
        elseif (($list6.selecteditems.count -or $list7.selecteditems.count -or $list9.selecteditems.count) -lt 1) { $vbmsg1 = $vbmsg.popup("Please select a connection to terminate.", 0, "Error", 0) }
        else {
            if ($list6.selecteditems.count -eq 1) {
                $exprString2 = '$list6.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ProcessName}'
                $endproc2 = invoke-expression $exprString2
                $stBar1.text = "Stopping process " + $endproc2 + " (Please wait...)"
                $exprString = '$list6.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.OwningProcess}'
                $endproc = invoke-expression $exprString
                $process = Get-WmiObject -ComputerName $computername -Query "select * from win32_process where processID='$endproc'"
                $process.terminate()
                Start-Sleep 1
                $procs = Invoke-Command -ComputerName $computername -ScriptBlock {
                    $TCP = Get-NetTCPConnection | Select-Object -ExpandProperty OwningProcess
                    $UDP = Get-NetUDPEndpoint | Select-Object -ExpandProperty OwningProcess
                    $Both = $TCP + $UDP
                    $Both
                }
                Start-Sleep 1
                if (($? -eq $True) -and (!($endproc -in $procs))) {
                    $stBar1.text = "Process " + $endproc2 + " has been terminated"
                }
                else {
                    $stBar1.text = "Error: Issue terminating process: " + $endproc2
                }
            }
            elseif ($list7.selecteditems.count -eq 1) {
                $exprString3 = '$list7.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ComputerName}'
                $Comper = invoke-expression $exprString3
                $exprString2 = '$list7.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ProcessName}'
                $endproc2 = invoke-expression $exprString2
                $stBar1.text = "Stopping process " + $endproc2 + " on " + $Comper + " (Please wait...)"
                $exprString = '$list7.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.OwningProcess}'
                $endproc = invoke-expression $exprString
                $process = Get-WmiObject -ComputerName $Comper -Query "select * from win32_process where processID='$endproc'"
                $process.terminate()
                Start-Sleep 1
                $procs = Invoke-Command -ComputerName $Comper -ScriptBlock {
                    $TCP = Get-NetTCPConnection | Select-Object -ExpandProperty OwningProcess
                    $UDP = Get-NetUDPEndpoint | Select-Object -ExpandProperty OwningProcess
                    $Both = $TCP + $UDP
                    $Both
                }
                Start-Sleep 1
                if (($? -eq $True) -and (!($endproc -in $procs))) {
                    $stBar1.text = "Process " + $endproc2 + " has been terminated on " + $Comper
                }
                else {
                    $stBar1.text = "Error: Issue terminating process " + $endproc2 + " on " + $Comper
                }
            }
            elseif ($list9.selecteditems.count -eq 1) {
                $exprString3 = '$list9.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ComputerName}'
                $Comper = invoke-expression $exprString3
                $exprString2 = '$list9.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ProcessName}'
                $endproc2 = invoke-expression $exprString2
                $stBar1.text = "Stopping process " + $endproc2 + " on " + $Comper + " (Please wait...)"
                $exprString = '$list9.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.OwningProcess}'
                $endproc = invoke-expression $exprString
                $process = Get-WmiObject -ComputerName $Comper -Query "select * from win32_process where processID='$endproc'"
                $process.terminate()
                Start-Sleep 2
                $procs = Invoke-Command -ComputerName $Comper -ScriptBlock {
                    $TCP = Get-NetTCPConnection | Select-Object -ExpandProperty OwningProcess
                    $UDP = Get-NetUDPEndpoint | Select-Object -ExpandProperty OwningProcess
                    $Both = $TCP + $UDP
                    $Both
                }
                Start-Sleep 1
                if (($? -eq $True) -and (!($endproc -in $procs))) {
                    $stBar1.text = "Process " + $endproc2 + " has been terminated on " + $Comper
                }
                else {
                    $stBar1.text = "Error: Issue terminating process " + $endproc2 + " on " + $Comper
                }
            }
            else { $stBar1.text = "An internal error has occured..." }
        }
        if ($null -ne $endproc2) {
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Killed process " + $endproc2 + " on " + $Comper | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
    }
    
    ######################
    #### SHOW-PROCESS ####
    ######################
    Function Processes {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            ClearGrid
            HideUnusedItems
            $list5.visible = $true
            $lbl2.Visible = $false
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            if (test-connection $computername -quiet -count 1) {
                $stBar1.text = "Processes on " + $computername.ToUpper() + " (Loading...)"
    
                $list5.Columns[0].text = "Name"
                $list5.Columns[0].width = 150
                $list5.Columns[1].text = "ExecutablePath"
                $list5.Columns[1].width = ($list5.width - $list5.columns[0].width - 25)
    
                $systeminfoerror = $null
                $procs = Get-WmiObject win32_process -computername $computername -ev systeminfoerror | sort-object -property name
                if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
                else {
                    $columnproperties = "Name", "ExecutablePath"
                    foreach ($d in $procs) {
    
                        $i++
                        [int]$pct = ($i / $procs.count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($d.name)
                        if ($null -eq $d.executablepath) {
                            $item.SubItems.Add($text)
                        }
                        else { $item.SubItems.Add($d.executablepath) }
                        $item.Tag = $d
                        $list5.Items.Add($item) > $null
                    }
                    $stBar1.text = "Processes on " + $computername.ToUpper()
                    $btn10.visible = $true
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Listed processes on " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
            } #End wmi error check
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper() 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End show processs
    
    #################
    ## END PROCESS ##
    #################
    $btn10_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if ($list5.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one process to end at a time.", 0, "Error", 0) }
        elseif ($list5.selecteditems.count -lt 1) { $vbmsg1 = $vbmsg.popup("Please select a process to end.", 0, "Error", 0) }
        else {
            $exprString2 = '$list5.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.name}'
            $endproc2 = invoke-expression $exprString2
            $stBar1.text = "Stopping process " + $endproc2 + " (Please wait...)"
            Start-Sleep 2
            $exprString = '$list5.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.processid}'
            $endproc = invoke-expression $exprString
            $process = Get-WmiObject -ComputerName $computername -Query "select * from win32_process where processID='$endproc'"
            $process.terminate()
            start-sleep 1
            $List5.items.Clear()
            $stBar1.text = "Processes on " + $computername.ToUpper() + " (Reloading...)"
            start-sleep 2
            $procs = Get-WmiObject win32_process -computername $computername | sort-object -property name
            $columnproperties = "Name", "ExecutablePath"
            foreach ($d in $procs) {
                $text = ""
                $item = new-object System.Windows.Forms.ListViewItem($d.name)
                if ($null -eq $d.executablepath) {
                    $item.SubItems.Add($text)
                }
                else { $item.SubItems.Add($d.executablepath) }
                $item.Tag = $d
                $list5.Items.Add($item) > $null
            }
            $stBar1.text = "Processes on " + $computername.ToUpper()
        }
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ended process " + $endproc2 + " on " + $computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ###################
    ## UNINSTALL APP ##
    ###################
    $btn11_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $list1.Columns[2].text = "Uninstall String"
        $list1.Columns[2].width = 300
        $list1.Columns[1].text = "Install Date"
        $list1.Columns[1].width = 90
        $list1.Columns[0].text = "Name"
        $list1.Columns[0].width = ($list1.width - $list1.columns[2].width - 100)
    
        if ($list1.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one application to uninstall at a time.", 0, "Error", 0) }
        elseif ($list1.selecteditems.count -lt 1) { $vbmsg1 = $vbmsg.popup("Please select an application to uninstall.", 0, "Error", 0) }
        else {
            [int]$pct = (1 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $computername = $txt1.text
            $AppNameString = '$list1.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.Displayname}'
            $AppName = Invoke-Expression $AppNameString
            $exprString = '$list1.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.UninstallString}'
            $endapp = Invoke-Expression $exprString
    
            if ($endapp -like 'msiexec.exe*') {
                $stBar1.text = "Getting uninstall string for '" + $AppName + "' (Please wait...)"
                Start-Sleep 2
                [int]$pct = (2 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $String = $endapp -Replace "msiexec.exe", "" -Replace "/I", "" -Replace "/X", ""
                $String = $String.Trim()
                $UninstallSyntax = "MsiExec.exe /X $String /qn"
                $stBar1.text = "Uninstalling using syntax: " + $UninstallSyntax
                Start-Sleep 2
                [int]$pct = (3 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $Result = Invoke-Command -ComputerName $computername -ArgumentList $UninstallSyntax -ScriptBlock {
                    Param($UninstallSyntax)
                    $Exitness = Start-Process cmd.exe -ArgumentList "/c $UninstallSyntax" -Wait -PassThru
                    $Exitness.ExitCode
                }
                if (($? -eq $True) -and ($result -eq 0)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = $AppName + " was successfully uninstalled on " + $computername.ToUpper() + ". (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1641)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "$AppName uninstalled successfully, but the computer needs to restart. (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1603)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error 1603: A fatal error occurred during the uninstall. (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1618)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error 1618: Another uninstall process is in progress. (Reloading app list...)"
                }
                else {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar                    
                    $stBar1.text = "Error: Issue uninstalling " + $AppName + " (Reloading app list...)" + "Exit codes: " + $? + " and " + $Result
                }
                Start-Sleep 4                    
            }
    
            elseif ($endapp -like '"C:\*"') {
                [int]$pct = (3 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Getting uninstall method for '" + $AppName + "' (Please wait...)"
                Start-Sleep 2
                $stBar1.text = "Uninstalling using method: " + $endapp + " on " + $Computername
                Start-Sleep 2
    
                $Result = Invoke-Command -ComputerName $computername -ArgumentList $endapp -ScriptBlock {
                    Param($endapp)
                    $Exitness = Start-Process cmd.exe -ArgumentList "/c $endapp" -Wait -PassThru -WindowStyle Hidden
                    $Exitness.ExitCode
                }
                if (($? -eq $True) -and ($result -eq 0)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = $AppName + " was successfully uninstalled on " + $computername.ToUpper() + ". (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1641)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "$AppName uninstalled successfully, but the computer needs to restart. (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1603)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error 1603: A fatal error occurred during the uninstall. (Reloading app list...)"
                }
                elseif (($? -eq $True) -and ($result -eq 1618)) {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error 1618: Another uninstall process is in progress. (Reloading app list...)"
                }
                else {
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar                    
                    $stBar1.text = "Error: Issue uninstalling " + $AppName + " (Reloading app list...)" + "Exit codes: " + $? + " and " + $Result
                }
                Start-Sleep 4
            }
    
            else {
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Error: No uninstall method to call so no action was taken. (Reloading app list...)"; Start-Sleep 4
            }
    
            clearGrid
            $systeminfoerror = $null
            $software = Invoke-Command -Computer $computername { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* } | Where-Object { ![string]::IsNullOrWhiteSpace($_.DisplayName) } | Select-Object DisplayName, installDate, UninstallString | Sort-Object DisplayName -ev systeminfoerror
            if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
            else {
                $columnnames = "Name", "Install Date", "Uninstall String"
                foreach ($app in $software) {
    
                    $i++
                    [int]$pct = ($i / $software.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($app.DisplayName)
    
                    if ($null -eq $app.InstallDate) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($app.InstallDate) }
    
                    if ($null -eq $app.UninstallString) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($app.UninstallString) }
    
                    $item.Tag = $app
                    $list1.Items.Add($item) > $null
                }
    
                $btn11.Visible = $true
    
                $stBar1.text = "Applications and Updates installed on " + $computername.ToUpper() + " (" + $software.count + ")"
            }
        }
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Removed application " + $AppName + " on " + $computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ######################################
    ####### Custom Uninstall Input #######
    ######################################
    Function UninstallString {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Uninstall String'
        $msg = 'Enter an uninstall string:
    -> Examples...
    Firefox 22.0: 
    msiexec /x {E3928BC3-402E-419F-9946-FAB625322914} /q
    
    Java 8 Update 73 x64:
    msiexec /x {26A24AE4-039D-4CA4-87B4-2F86418073F0} /q
    
    Adobe Reader 8.0:
    msiexec /x {AC76BA86-7AD7-1033-7B44-A80000000002} /q
    
    NOTE: This option is for uninstalling programs
    that arent listed in the application list. 
    You will have to Google the uninstall
    string for the program and version you are 
    looking for when using this option'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ############################################################
    
    #############################
    ## MANUAL UNINSTALL STRING ##
    #############################
    $btn22_OnClick = 
    {
        $list1.Columns[2].text = "Uninstall String"
        $list1.Columns[2].width = 300
        $list1.Columns[1].text = "Install Date"
        $list1.Columns[1].width = 90
        $list1.Columns[0].text = "Name"
        $list1.Columns[0].width = ($list1.width - $list1.columns[2].width - 100)
    
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        $stBar1.text = "Enter the uninstall string..."
        $UninstallSyntax = UninstallString
    
        if (!("$UninstallSyntax" -eq "")) {
            [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $computername = $txt1.text
    
            $stBar1.text = "Uninstalling using syntax: " + $UninstallSyntax
            Start-Sleep 2
            [int]$pct = (2 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $Result = Invoke-Command -ComputerName $computername -ArgumentList $UninstallSyntax -ScriptBlock {
                Param($UninstallSyntax)
                $Exitness = Start-Process cmd.exe -ArgumentList "/c $UninstallSyntax" -Wait -PassThru
                $Exitness.ExitCode
            }
            if (($? -eq $True) -and ($result -eq 0)) {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "The app was successfully uninstalled on " + $computername.ToUpper() + ". (Reloading app list...)"
            }
            elseif (($? -eq $True) -and ($result -eq 1641)) {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "The app uninstalled successfully, but the computer needs to restart. (Reloading app list...)"
            }
            elseif (($? -eq $True) -and ($result -eq 1603)) {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Error 1603: A fatal error occurred during the uninstall. (Reloading app list...)"
            }
            elseif (($? -eq $True) -and ($result -eq 1618)) {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Error 1618: Another uninstall process is in progress. (Reloading app list...)"
            }
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar                    
                $stBar1.text = "Error: Issue uninstalling the app (Reloading app list...)" + "Exit codes: " + $? + " and " + $Result
            }
            Start-Sleep 3                    
    
            clearGrid
            $systeminfoerror = $null
            $software = Invoke-Command -Computer $computername { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* } | Where-Object { ![string]::IsNullOrWhiteSpace($_.DisplayName) } | Select-Object DisplayName, installDate, UninstallString | Sort-Object DisplayName -ev systeminfoerror
            if ($systeminfoerror) { $stBar1.text = "Error retrieving info from " + $computername.ToUpper() }
            else {
                $columnnames = "Name", "Install Date", "Uninstall String"
                foreach ($app in $software) {
    
                    $i++
                    [int]$pct = ($i / $software.count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
    
                    $text = ""
                    $item = new-object System.Windows.Forms.ListViewItem($app.DisplayName)
    
                    if ($null -eq $app.InstallDate) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($app.InstallDate) }
    
                    if ($null -eq $app.UninstallString) {
                        $item.SubItems.Add($text)
                    }
                    Else { $item.SubItems.Add($app.UninstallString) }
    
                    $item.Tag = $app
                    $list1.Items.Add($item) > $null
                }
            }
    
            $btn11.Visible = $true
            $stBar1.text = "Applications and Updates installed on " + $computername.ToUpper() + " (" + $software.count + ")"
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Performed a manual uninstall on " + $computername + " with string " + $UninstallSyntax | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else {
            [int]$pct = (3 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Error: No uninstall method to call or action was cancelled."
        }
    }
    
    #########################
    ### INSTALL SCCM APP ####
    #########################
    $btn17_OnClick = 
    {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        if ($list2.selecteditems.count -gt 1) { $vbmsg1 = $vbmsg.popup("You may only select one application to uninstall at a time.", 0, "Error", 0) }
        elseif ($list2.selecteditems.count -lt 1) { $vbmsg1 = $vbmsg.popup("Please select an application to uninstall.", 0, "Error", 0) }
        else {
            $computername = $txt1.text
    
            $exprString = '$list2.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.FullName}'
            $exprString2 = '$list2.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.Id}'
            $exprString4 = '$list2.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.Revision}'
            $exprString5 = '$list2.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.ResolvedState}'
    
            $AppName = Invoke-Expression $exprString
            $AppID = Invoke-Expression $exprString2
            $AppRevision = Invoke-Expression $exprString4
            $ResolvedState = Invoke-Expression $exprString5
    
            $Args = @{EnforcePreference = [UINT32] 0
                Id                      = "$($AppID)"
                IsMachineTarget         = $True
                IsRebootIfNeeded        = $False
                Priority                = 'High'
                Revision                = "$($AppRevision)"
            }
    
    
            If ($ResolvedState -eq "NotInstalled") {
                $stBar1.text = "Sending SCCM Command to " + $computername.ToUpper() + " (Installing $($AppName))"
                $Result = Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName Install -Arguments $Args
    
                If ($Result.ReturnValue -eq "0") {
                    $stBar1.text = "SCCM Command Sent to " + $computername.ToUpper() + " for " + $AppName
                }
                Else {
                    $stBar1.text = "Unable to Send SCCM Command to " + $computername.ToUpper() + " for " + $AppName
                }
            }
            Elseif ($ResolvedState -eq "Available") {
                $stBar1.text = "Sending SCCM Command to " + $computername.ToUpper() + " (Installing $($AppName))"
                $Result = Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName Install -Arguments $Args
    
                If ($Result.ReturnValue -eq "0") {
                    $stBar1.text = "SCCM Command Sent to " + $computername.ToUpper() + " for " + $AppName
                }
                Else {
                    $stBar1.text = "Unable to Send SCCM Command to " + $computername.ToUpper() + " for " + $AppName
                }
            }
            Elseif ($ResolvedState -eq "Installed") {
                $stBar1.text = "Sending SCCM Command to " + $computername.ToUpper() + " (Uninstalling $($AppName))"
                $Result = Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -ComputerName $Computername -MethodName Uninstall -Arguments $Args
    
                If ($Result.ReturnValue -eq "0") {
                    $stBar1.text = "SCCM Command Sent to " + $computername.ToUpper() + " for " + $AppName
                }
                Else {
                    $stBar1.text = "Unable to Send SCCM Command to " + $computername.ToUpper() + " for " + $AppName
                }
            }
            Else {
                $stBar1.text = "Only Able to Uninstall or Install Available Apps From SCCM..."
            }
    
        }
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Performed a Software Center action: " + $AppName + " on " + $computername | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    ####################################
    ####### Custom Install Input #######
    ####################################
    Function CustInstall {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Custom Install'
        $msg = 'Enter install switches:
    -> Examples...
    Firefox: -ms
    Java: /s
    Adobe Flash: /Install
    VPN: /quiet /norestart
    HBSS: /Agent=Install /ForceInstall /Silent /norestart
    MSI File: /i owasmime.msi /qn
    PS1 File: test.ps1 -windowstyle hidden
    VBS File: cscript.exe
    
    NOTE: Only put switches for executables...
    Not the file and switches. For other file
    types include the file name.'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ############################################################
    
    ####################################
    ####### Custom Install Input #######
    ####################################
    Function CustInstall2 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'PsExec Custom Install'
        $msg = 'Enter install switches:
    -> Examples...
    Firefox: -ms
    Java: /s
    Adobe Flash: /Install
    VPN: /quiet /norestart
    HBSS: /Agent=Install /ForceInstall /Silent /norestart
    MSI File: msiexec.exe /i file.msi /qn
    PS1 File: PowerShell.exe -windowstyle hidden
    VBS File: cscript.exe'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ############################################################
    
    ################################# 'RUN THE INSTALL' BUTTON ####################################
    $btn16_OnClick =
    {
        HideUnusedItems
        $computername = $txt1.text
        $DropDownBox = $DropDownBox.SelectedItem
    
        if ((Get-ChildItem "$env:SystemDrive\Admin_Tool\InstallFile\").Count -eq 1) {
    
            if ($RadioButton1.Checked -eq $True -and $RadioButton2.Checked -eq $False) {
                if ($Computername -eq "") { $stBar1.text = "Error: Enter a Computer Name"; $vbmsg.popup("Enter a Computer Name", 0, "Error", 0) }
                elseif ($null -eq $DropDownBox) { $stBar1.text = "Error: Select a program from the dropdown list."; $vbmsg.popup("Select a program from the dropdown list.", 0, "Error", 0) }
                elseif ($computername -like "*.*.*.*") { $stBar1.text = "Error: Enter a Computer Name. No IP Addresses."; $vbmsg.popup("Enter a Computer Name. No IPs!", 0, "Error", 0) }
                else { SingleInstall }
            }
            elseif ($RadioButton2.Checked -eq $True -and $RadioButton1.Checked -eq $False) {
                # Setup computer list
                $Computers = @(Get-Content $env:SystemDrive\Admin_Tool\ComputerList\computers.txt)
                # Path to the file to be installed
                $File = Get-ChildItem -Name "$env:SystemDrive\Admin_Tool\InstallFile\"
                if (!(Test-Path "$env:SystemDrive\Admin_Tool\ComputerList\computers.txt")) { $stBar1.text = "Error: No computer list to pull from."; $vbmsg.popup("No computer list to pull from. Click the '...' button to input computers. Make sure to save the list!", 0, "Error", 0) }
                elseif ($null -eq $DropDownBox) { $stBar1.text = "Error: Select a program from the dropdown list."; $vbmsg.popup("Select a program from the dropdown list.", 0, "Error", 0) }
                else {
                    $lbl2.visible = $True
                    $lbl2.text = ""
                    $stBar1.text = "Starting install on " + $Computers.Count + " computers (Please wait...)"
                    If (Test-Path $env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt) { Remove-Item $env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt -Force }
                    Start-Sleep -Seconds 1
                    If (!(Test-Path $env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt)) { New-Item -Path $env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt -ItemType File -Force }
                    Start-Sleep -Seconds 1
                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "`n`t`t`t`t Install log for $($Computers.Count) computers installing $($File)... `n"
                    if ($DropDownBox.Contains("Custom Install") -and ($RadioButton2.Checked -eq $True)) {
                        $CustomIn = CustInstall
                        Start-Sleep 1
                        if (!($CustomIn -eq "")) {
                            If ($File -like "*.exe") { Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "`t`t`t`t      Custom install syntax: $($File) $($CustomIn) `n`n`n" }
                            Else { Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "`t`t`t`t      Custom install syntax: $($CustomIn) `n`n`n" }
                            MultipleInstall -Computers $Computers -File $File -CustomIn $CustomIn
                        }
                        Else { $stBar1.text = "No switches entered or task cancelled. No action was taken..." }
                    }
                    Else { MultipleInstall -Computers $Computers -File $File }
                }
            }                      
            else { $stBar1.text = "It seems no options were selected..." }
        }
        else { $vbmsg1 = $vbmsg.popup("Make Sure Only One File is in the 'Install Folder'.", 0, "Error", 0) }
    
    }
    
    #############################################################################################
    
    
    ################################ Single Install Function ####################################
    Function SingleInstall {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        HideUnusedItems
        $lbl2.visible = $True
        $lbl2.text = ""
        [int]$pct = (0 / 7) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        $filename = Get-ChildItem -Name "$env:SystemDrive\Admin_Tool\InstallFile\"
    
        $stBar1.text = "Pinging " + $computername.ToUpper()
        if (test-connection $computername -quiet -count 1) {
    
            [int]$pct = (1 / 7) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $stBar1.text = "Connecting to " + $computername.ToUpper()
            $Session = New-PSSession -ComputerName $Computername
    
            [int]$pct = (2 / 7) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $stBar1.text = "Checking Remote File Path on " + $computername.ToUpper()
            if (Test-Path "\\$computername\C$\Temps") { Remove-Item -Force -Recurse "\\$computername\C$\Temps" }
    
            [int]$pct = (3 / 7) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $stBar1.text = "Copying $filename to " + $computername.ToUpper()
            Copy-Item "$env:SystemDrive\Admin_Tool\InstallFile\" -Recurse -Destination "\\$computername\C$\Temps\" -Force
    
            $TestFileCopy = Test-Path -Path "\\$computername\C$\Temps\$filename"
            # If the file was copied, then perform the installation.
            If ($TestFileCopy -eq $True) {
    
                [int]$pct = (4 / 7) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $stBar1.text = "Installing " + $filename + " on " + $computername.ToUpper()
    
                ###################################### JAVA INSTALL ##########################################
                if ($DropDownBox.Contains("Java") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /qn /log c:\Temps\JavaInstall.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR JAVA INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\JavaInstall.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "Java was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "Java was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing Java on " + $computername.ToUpper()
                        }
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        Remove-PSSession -Session $Session
                    }
    
                    ElseIf ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "/s /L c:\Temps\JavaInstall.log" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR JAVA INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\JavaInstall.log" | Out-String)
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $stBar1.text = "Issue installing Java on " + $computername.ToUpper()
                        }
                        else {
                            $stBar1.text = "Java was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.msi or .exe only)"
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### ADOBE PRO INSTALL #####################################
                elseif ($DropDownBox.Contains("Adobe Pro") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n" 
                            $stBar1.text = "Issue installing Adobe on " + $computername.ToUpper()
                        }
                        else {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "Adobe was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session 
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.exe only)."
                        Remove-PSSession -Session $Session
                    } 
                }
                ##############################################################################################
    
                ###################################### ADOBE FLASH INSTALL ###################################
                elseif ($DropDownBox.Contains("Adobe Flash") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "-install" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                            $stBar1.text = "Issue installing Adobe Flash on " + $computername.ToUpper()
                        }
                        else {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "Adobe Flash was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.exe only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### FIREFOX INSTALL #######################################
                elseif ($DropDownBox.Contains("Firefox") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /qn /log c:\Temps\FirefoxInstall.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR FIREFOX INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\FirefoxInstall.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "Firefox was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "Firefox was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing Firefox on " + $computername.ToUpper()
                        }
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        Remove-PSSession -Session $Session
                    }
    
                    Elseif ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "C:\Temps\$filename" -ArgumentList "-ms" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                            $stBar1.text = "Issue installing Firefox on " + $computername.ToUpper()
                        }
                        else {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "Firefox was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.msi and .exe only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### CHROME INSTALL ########################################
                elseif ($DropDownBox.Contains("Chrome") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /qn /log c:\Temps\ChromeInstall.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR CHROME INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\JavaInstall.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "Chrome was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "Chrome was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing Chrome on " + $computername.ToUpper()
                        }
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        Remove-PSSession -Session $Session
                    }
    
                    Elseif ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "/silent /install" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                            $stBar1.text = "Issue installing Chrome on " + $computername.ToUpper()
                        }
                        else {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "Chrome was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.msi and .exe only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### SMIME INSTALL #########################################
                elseif ($DropDownBox.Contains("SMIME") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /qn /log c:\Temps\SMIMEInstall.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR SMIME INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\SMIMEInstall.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "SMIME was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing SMIME on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.msi only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### VPN INSTALL ###########################################
                elseif ($DropDownBox.Contains("VPN") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "/quiet /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $False) -and (!($result -eq 0))) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                            $stBar1.text = "Issue installing VPN on " + $computername.ToUpper()
                        }
                        else {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "VPN was successfully installed on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.exe only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### ATHOC INSTALL #########################################
                elseif ($DropDownBox.Contains("AtHoc (PACAF)") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /quiet /passive /log c:\Temps\ATHOCInstall.log /norestart BASEURL=https://alerts.osan.af.mil/config/baseurl.asp PID=2010110 RUNAFTERINSTALL=N DESKBAR=N TOOLBAR=N SILENT=Y VALIDATECERT=N MANDATESSL=N UNINSTALLOPTION=N" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR ATHOC INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\ATHOCInstall.log" | Out-String)
                        if (($? -eq $True) -and ($Result -eq 0)) {
                            $stBar1.text = "ATHOC was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($Result -eq 1641)) {
                            $stBar1.text = "ATHOC was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($Result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($Result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {
                            $stBar1.text = "Issue installing ATHOC on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.msi only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### MSI, MSU, MSP INSTALL ###################################
                elseif ($DropDownBox.Contains("MSI/MSU/MSP File") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.msi") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$filename /qn /log c:\Temps\MSI.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR .MSI INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\MSI.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing the MSI file on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    ElseIf ($filename -like "*.msu") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        Invoke-Command -Session $Session -ScriptBlock {
                            expand -f:* "C:\Temps\*.msu" "C:\Temps\"
                            $File = Get-ChildItem "C:\Temps\Windows*.cab" | Sort-Object Name | Select-Object -ExpandProperty Name
                            foreach ($cab in $File) {
                                Start-Process dism.exe -ArgumentList "/online /add-package /packagepath:C:\Temps\$cab /norestart /quiet /loglevel:3 /logpath:C:\Temps\MSU.log" -Wait -PassThru
                            }
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR .MSU INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\MSU.log" | Out-String)
                        if ($? -eq $True) {
                            $stBar1.text = "The MSU file was successfully installed on " + $computername.ToUpper()
                            #$vbmsg1 = $vbmsg.popup("It's recommended that you restart the PC since MSU files aren't fully installed until after that happens.",0,"Info",0)
                            # Shutdown /r /t 1800 /c "Your computer requires a restart to finish applying updates. The reboot will occur in 30 minutes"
                        }
                        else {                    
                            $stBar1.text = "Issue installing the MSU file on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    ElseIf ($filename -like "*.msp") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process msiexec.exe -ArgumentList "/p c:\Temps\$filename /qn /log c:\Temps\MSP.log /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $lbl2.text += "`t`t`t`t`t LOG FILE FOR .MSP INSTALL `n`n"
                        $lbl2.text += (Get-Content "\\$computername\C$\Temps\MSP.log" | Out-String)
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $stBar1.text = "The MSP file was successfully installed on " + $computername.ToUpper()
                        }
                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                            $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                            $stBar1.text = "Error 1603: A fatal error occurred during installation"
                        }
                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                            $stBar1.text = "Error 1618: Another installation is likely in progress"
                        }
                        else {                    
                            $stBar1.text = "Issue installing the MSP file on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + "; .msi, .msu or .msp only."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### HBSS INSTALL ##########################################
                elseif ($DropDownBox.Contains("HBSS") -and ($RadioButton1.Checked -eq $True)) {
                    If ($filename -like "*.exe") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process "c:\Temps\$filename"  -ArgumentList "/Agent=Install /ForceInstall /Silent /norestart" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                            $stBar1.text = "HBSS was successfully installed on " + $computername.ToUpper()
                        }
                        else {                    
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                            $stBar1.text = "Issue installing HBSS on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error Installing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.exe only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### PS1/VBS/CMD INSTALL ##########################################
                elseif ($DropDownBox.Contains("PS1/VBS/CMD Script") -and ($RadioButton1.Checked -eq $True)) {
                    $stBar1.text = "Running " + $filename + " on " + $computername.ToUpper()
    
                    If ($filename -like "*.ps1") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process powershell.exe -ArgumentList "-file C:\Temps\$filename -windowstyle hidden" -Wait -PassThru -WindowStyle Minimized
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                            $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                        }
                        else {                    
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                            $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    ElseIf ($filename -like "*.vbs") {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process cscript.exe -ArgumentList "C:\Temps\$filename" -Wait -PassThru
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                            $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                        }
                        else {                    
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                            $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    ElseIf (($filename -like "*.cmd") -or ($filename -like "*.bat")) {
                        [int]$pct = (5 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $Result = Invoke-Command -Session $Session -ScriptBlock {
                            $filename = Get-ChildItem -Name "C:\Temps\"
                            $Exitness = Start-Process cmd.exe -ArgumentList "/c C:\Temps\$filename" -Wait -PassThru -WindowStyle Minimized
                            $Exitness.ExitCode
                        }
                        [int]$pct = (6 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (($? -eq $True) -and ($result -eq 0)) {
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                            $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                        }
                        else {                    
                            $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                            $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                        }
                        Remove-PSSession -Session $Session
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
    
                    Else {
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error executing $filename on " + $computername.ToUpper() + ". File Type Not Supported (.ps1 or .vbs only)."
                        Remove-PSSession -Session $Session
                    }
                }
                ##############################################################################################
    
                ###################################### CUSTOM INSTALL ###########################################
                elseif ($DropDownBox.Contains("Custom Install") -and ($RadioButton1.Checked -eq $True)) {
                    $CustomIn = CustInstall
                    Start-Sleep 1
                    if (!("$CustomIn" -eq "")) {
    
                        If ($filename -like "*.exe") {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $filename + " " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                $filename = Get-ChildItem -Name "C:\Temps\"
                                $Exitness = Start-Process "C:\Temps\$filename" -ArgumentList "$CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $False) -and (!($result -eq 0))) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                                $stBar1.text = "Issue installing app on " + $computername.ToUpper() + "Exit Code: " + $Result
                            }
                            else {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                $stBar1.text = "The app was successfully installed on " + $computername.ToUpper() + "Exit Code: " + $Result
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        ElseIf ($filename -like "*.msi") {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                Set-Location -Path C:\Temps\
                                $Exitness = Start-Process msiexec.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $True) -and ($Result -eq 0)) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper()
                            }
                            elseif (($? -eq $True) -and ($result -eq 1641)) {
                                $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                            }
                            elseif (($? -eq $True) -and ($result -eq 1603)) {
                                $stBar1.text = "Error 1603: A fatal error occurred during installation"
                            }
                            elseif (($? -eq $True) -and ($result -eq 1618)) {
                                $stBar1.text = "Error 1618: Another installation is likely in progress"
                            }
                            else {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"                    
                                $stBar1.text = "Issue installing the MSI file on " + $computername.ToUpper()
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        ElseIf ($filename -like "*.msp") {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                Set-Location -Path C:\Temps\
                                $Exitness = Start-Process msiexec.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $True) -and ($result -eq 0)) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                $stBar1.text = "The MSP file was successfully installed on " + $computername.ToUpper()
                            }
                            elseif (($? -eq $True) -and ($result -eq 1641)) {
                                $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                            }
                            elseif (($? -eq $True) -and ($result -eq 1603)) {
                                $stBar1.text = "Error 1603: A fatal error occurred during installation"
                            }
                            elseif (($? -eq $True) -and ($result -eq 1618)) {
                                $stBar1.text = "Error 1618: Another installation is likely in progress"
                            }
                            else {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"                   
                                $stBar1.text = "Issue installing the MSP file on " + $computername.ToUpper()
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        ElseIf ($filename -like "*.ps1") {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                Set-Location -Path C:\Temps\
                                $Exitness = Start-Process powershell.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $True) -and ($result -eq 0)) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                            }
                            else {                    
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        ElseIf ($filename -like "*.vbs") {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                Set-Location -Path C:\Temps\
                                $Exitness = Start-Process cscript.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $True) -and ($result -eq 0)) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                            }
                            else {                    
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        ElseIf (($filename -like "*.cmd") -or ($filename -like "*.bat")) {
                            [int]$pct = (5 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Running: " + $CustomIn + " on " + $computername + " (Please wait...)"
                            $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                Param($CustomIn)
                                Set-Location -Path C:\Temps\
                                $Exitness = Start-Process cmd.exe -ArgumentList "/c $CustomIn" -Wait -PassThru
                                $Exitness.ExitCode
                            }
                            [int]$pct = (6 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            if (($? -eq $True) -and ($Result -eq 0)) {
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                            }
                            else {                    
                                $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper()
                            }
                            Remove-PSSession -Session $Session
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
    
                        Else {
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                            $stBar1.text = "Error installing/running " + $filename + ". Supported file types: msi, msp, exe, ps1, vbs, and cmd"
                            Remove-PSSession -Session $Session
                        }
                    }
                    else { $stBar1.text = "No switches entered or task cancelled. No action was taken..." }
                }
                ###################################### PSEXEC INSTALL ###########################################
                elseif ($DropDownBox.Contains("PsExec Install") -and ($RadioButton1.Checked -eq $True)) {
                    $CustomIn2 = CustInstall2
                    Start-Sleep 1
                    if (!("$CustomIn2" -eq "")) {
                        if (!(Test-Path "$env:SystemDrive\Admin_Tool\PsExec\")) {
                            New-Item "$env:SystemDrive\Admin_Tool\PsExec\" -ItemType Directory -Force
                        }
                        if ((Get-ChildItem "$env:SystemDrive\Admin_Tool\PsExec\").Count -eq 1) {
                            $FileCheck = Get-ChildItem $env:SystemDrive\Admin_Tool\PsExec\ | Select-Object -ExpandProperty Name
                            If ($FileCheck -eq "PsExec64.exe" -or $FileCheck -eq "PsExec.exe") {
                                $LASTEXITCODE = $null
                                $filename = Get-ChildItem -Name "\\$computername\C$\Temps\"
    
                                If ($filename -like "*.exe") {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
    
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
    
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"
                                        $stBar1.text = "Issue installing app on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    else {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                        $stBar1.text = "The app was successfully installed on " + $computername.ToUpper()
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                ElseIf ($filename -like "*.msi") {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    if (($? -eq $True) -and ($Result -eq 0)) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                        $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $stBar1.text = "Error 1603: A fatal error occurred during installation"
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $stBar1.text = "Error 1618: Another installation is likely in progress"
                                    }
                                    else {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"                    
                                        $stBar1.text = "Issue installing the MSI file on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                ElseIf ($filename -like "*.msp") {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Installed Successfully! `n`n"
                                        $stBar1.text = "The MSP file was successfully installed on " + $computername.ToUpper()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $stBar1.text = "The MSI file was successfully installed on " + $computername.ToUpper() + ", but needs to restart"
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $stBar1.text = "Error 1603: A fatal error occurred during installation"
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $stBar1.text = "Error 1618: Another installation is likely in progress"
                                    }
                                    else {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Installed Successfully... `n`n"                   
                                        $stBar1.text = "Issue installing the MSP file on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                ElseIf ($filename -like "*.ps1") {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                        $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                                    }
                                    else {                    
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                        $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                ElseIf ($filename -like "*.vbs") {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                        $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                                    }
                                    else {                    
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                        $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                ElseIf (($filename -like "*.cmd") -or ($filename -like "*.bat")) {
                                    [int]$pct = (5 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Running: $FileCheck \\" + $computername + " " + $CustomIn2 + " " + $filename + " (Please wait...)"
                                    $Result = C:\Admin_Tool\PsExec\$FileCheck -nobanner -accepteula \\$computername $CustomIn2 "\\$computername\C$\Temps\$filename"
                                    [int]$pct = (6 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    if (($? -eq $True) -and ($Result -eq 0)) {
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t`t`t" + $filename.ToUpper() + " Executed Successfully! `n`n"
                                        $stBar1.text = $filename + " executed successfully on " + $computername.ToUpper()
                                    }
                                    else {                    
                                        $lbl2.text += "`n`n`n`n`n`n`n`t`t" + $filename.ToUpper() + " Was Not Executed Successfully... `n`n"
                                        $stBar1.text = "Issue executing " + $filename + " on " + $computername.ToUpper() + " Exit Code: " + $Result + ", " + $? + ", and " + $LASTEXITCODE
                                    }
                                    Remove-PSSession -Session $Session
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                }
    
                                Else {
                                    [int]$pct = (7 / 7) * 100        #set percentage
                                    $progress1.Value = $pct        #update the progress bar
                                    $stBar1.text = "Error installing/running " + $filename + ". Supported file types: msi, msp, exe, ps1, vbs, and cmd"
                                    Remove-PSSession -Session $Session
                                }
                            }
                            Else {
                                $vbmsg1 = $vbmsg.popup("There doens't seem to be a file named 'PsExec.exe' or 'PsExec64.exe'. Make sure the PsExec.exe or PsExec64.exe file is in the 'C:\Admin_Tool\PsExec' folder.", 0, "Error", 0)
                                [int]$pct = (7 / 7) * 100        #set percentage
                                $progress1.Value = $pct        #update the progress bar
                            }
                        }
                        else {
                            $vbmsg1 = $vbmsg.popup("Make Sure Only One File is in the 'PsExec Folder'.", 0, "Error", 0)
                            [int]$pct = (7 / 7) * 100        #set percentage
                            $progress1.Value = $pct        #update the progress bar
                        }
                    }
                    else {
                        $stBar1.text = "No switches entered or task cancelled. No action was taken..."
                        [int]$pct = (7 / 7) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                    }
                }
                ##############################################################################################
                else {
                    [int]$pct = (7 / 7) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "An unexpected error has occured. No action was taken..."
                }
            }
            Else {
                # Report if there were any issues copying the file to the remote workstation
                [int]$pct = (7 / 7) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "There was an error copying the file to " + $computername.ToUpper()
            }
            Remove-PSSession -Session $Session
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran " + $filename + " on " + $computername | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else {
            [int]$pct = (7 / 7) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Could not contact " + $computername.ToUpper()
        }
    } #End SingleInstall Function
    
    #############################################################################################
    ################################ Multiple Install Function ##################################
    #############################################################################################
    
    Function MultipleInstall {
        param(
    
            [Parameter(Mandatory = $true)]        
            [string[]]$Computers,
            
            [Parameter(Mandatory = $true)]        
            [string]$File,
    
            [Parameter(Mandatory = $false)]        
            [string]$CustomIn
                
        )
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
        Foreach ($Computer in $Computers) {
            $running = @(Get-Job -State Running)
            if ($running.Count -ge 15) {
                $null = $running | Wait-Job -Any
            }
    
            $i++
            [int]$pct = ($i / $Computers.Count) * 100
            #update the progress bar
            $progress1.Value = $pct
    
            $stBar1.text = "Starting install job for " + $Computer + " ( " + $i + " of " + $Computers.Count + " ) "
            Start-Sleep -Milliseconds 50
    
            Start-Job -Name "$Computer" -ArgumentList $Computer, $Computers, $File, $CustomIn, $DropDownBox, $RadioButton2, $lbl2 -ScriptBlock {
                Param($Computer, $Computers, $File, $CustomIn, $DropDownBox, $RadioButton2, $lbl2)
                       
                $mutex = New-Object System.Threading.Mutex($false, "LogMutex")
                #$extn = [System.IO.Path]::GetExtension("$file")
    
                #If $Computer IS NOT null or only whitespace
                if (!([string]::IsNullOrWhiteSpace($Computer))) {
    
                    # Tests the connection via ping
                    If (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                        $Session = New-PSSession -ComputerName $Computer
                                
                        if (Test-Path "\\$Computer\C$\Temps\") { Remove-Item -Force -Recurse "\\$Computer\C$\Temps\" }
                        Start-Sleep 1                                                           
                        Copy-Item "$env:SystemDrive\Admin_Tool\InstallFile\" -Recurse -Destination "\\$Computer\C$\Temps\" -Force
    
                        $TestFileCopy = Test-Path -Path "\\$Computer\C$\Temps\$File"
                        # If the file was copied, then perform the installation.
                        If ($TestFileCopy -eq $True) {
    
                            # If Java is selected from dropdown
                            If ($DropDownBox.Contains("Java") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.msi") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$file /qn /log c:\Temps\JavaInstall.log /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Java install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Java was successfully installed, but computer needs to restart"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {                    
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Java"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }                                           
    
                                Elseif ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "/s /L c:\Temps\JavaInstall.log" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Java"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Java install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session                                        
                                }
    
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                                                        
                            }
                            
    
                            # If Adobe Pro is selected from dropdown
                            Elseif ($DropDownBox.Contains("Adobe Pro") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Adobe Pro"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Adobe Pro install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session                                                
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                            
                            }
    
                            # If Adobe Flash is selected from dropdown
                            Elseif ($DropDownBox.Contains("Adobe Flash") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "-install" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Adobe Flash"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Adobe Flash install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session                                                
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            # If Firefox is selected from dropdown
                            Elseif ($DropDownBox.Contains("Firefox") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "-ms" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Firefox"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Firefox install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session                                                
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            # If Chrome is selected from dropdown
                            Elseif ($DropDownBox.Contains("Chrome") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "-ms" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing Chrome"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Chrome install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session                                                
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            # If SMIME is selected from dropdown
                            Elseif ($DropDownBox.Contains("SMIME") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.msi") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$file /qn /log c:\Temps\SMIMEInstall.log /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - SMIME install successful"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file was successfully installed, but needs to restart"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing SMIME"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            # If VPN is selected from dropdown
                            Elseif ($DropDownBox.Contains("VPN") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "/quiet /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing VPN"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - VPN install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            # If ATHOC is selected from dropdown
                            Elseif ($DropDownBox.Contains("AtHoc (PACAF)") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.msi") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$file /quiet /passive /log c:\Temps\ATHOCInstall.log /norestart BASEURL=https://alerts.osan.af.mil/config/baseurl.asp PID=2010110 RUNAFTERINSTALL=N DESKBAR=N TOOLBAR=N SILENT=Y VALIDATECERT=N MANDATESSL=N UNINSTALLOPTION=N" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - ATHOC install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - ATHOC was successfully installed, but computer needs to restart"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {                    
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing ATHOC"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
                                         
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }
                                                                                                        
                            }
    
                            # If MSI/MSU/MSP is selected from dropdown
                            Elseif ($DropDownBox.Contains("MSI/MSU/MSP File") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.msi") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process msiexec.exe -ArgumentList "/i c:\Temps\$file /qn /log c:\Temps\MSI.log /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file install was successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file was successfully installed, but needs to restart"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing the MSI file"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                Elseif ($file -like "*.msu") {
                                    Invoke-Command -Session $Session -ScriptBlock {
                                        expand -f:* "C:\Temps\*.msu" "C:\Temps\"
                                        $File = Get-ChildItem "C:\Temps\Windows*.cab" | Sort-Object Name | Select-Object -ExpandProperty Name
                                        foreach ($cab in $File) {
                                            Start-Process dism.exe -ArgumentList "/online /add-package /packagepath:C:\Temps\$cab /norestart /quiet /loglevel:3 /logpath:C:\Temps\MSU.log" -Wait -PassThru
                                            # Shutdown /r /t 1800 /c "Your computer requires a restart to finish applying updates. The reboot will occur in 30 minutes"
                                        }
                                        Start-Sleep 1
                                    }
                                    if ($? -eq $True) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSU file install was successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing the MSU file"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                ElseIf ($file -like "*.msp") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process msiexec.exe -ArgumentList "/p c:\Temps\$filename /qn /log c:\Temps\MSP.log /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $True) -and ($result -eq 0)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSP file install was successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1641)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file was successfully installed, but needs to restart"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1603)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    elseif (($? -eq $True) -and ($result -eq 1618)) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                        $mutex.ReleaseMutex()                                                
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing the MSP file"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                                        
                            }
                            
    
                            # If HBSS is selected from dropdown
                            Elseif ($DropDownBox.Contains("HBSS") -and ($RadioButton2.Checked -eq $True)) {
    
                                If ($file -like "*.exe") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $file = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "/Agent=Install /ForceInstall /Silent /norestart" -Wait -PassThru
                                        $Exitness.ExitCode
                                        Start-Sleep 1
                                    }
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing HBSS"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - HBSS install successful"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - File type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }                                                             
                            }
    
                            #If Powershell or VisualBasic Script is Selected
                            Elseif ($DropDownBox.Contains("PS1/VBS/CMD Script") -and ($RadioButton2.Checked -eq $True)) {
                                        
                                If ($file -like "*.ps1") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $filename = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process powershell.exe -ArgumentList "-file C:\Temps\$filename -windowstyle hidden" -Wait -PassThru -WindowStyle Minimized
                                        $Exitness.ExitCode
                                    }
                                    Start-Sleep 1
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue Running PowerShell Script"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - PowerShell Script Executed successfully"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                ElseIf ($file -like "*.vbs") {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $filename = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process cscript.exe -ArgumentList "C:\Temps\$filename" -Wait -PassThru -WindowStyle Minimized
                                        $Exitness.ExitCode
                                    }
                                    Start-Sleep 1                                            
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue Running VisualBasic Script"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - VisualBasic Script Executed successfully"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                ElseIf (($file -like "*.cmd") -or ($file -like "*.bat")) {
                                    $Result = Invoke-Command -Session $Session -ScriptBlock {
                                        $filename = Get-ChildItem -Name "C:\Temps\"
                                        $Exitness = Start-Process cmd.exe -ArgumentList "/c C:\Temps\$filename" -Wait -PassThru -WindowStyle Minimized
                                        $Exitness.ExitCode
                                    }
                                    Start-Sleep 1                                            
                                    if (($? -eq $False) -and (!($result -eq 0))) {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue Running Script"
                                        $mutex.ReleaseMutex()
                                    }
                                    else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Script Executed Successfully"
                                        $mutex.ReleaseMutex()
                                    }
                                    Remove-PSSession -Session $Session
                                }
    
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Script file type not supported"
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }
                            }
    
                            # If Custom Install is selected from dropdown
                            Elseif ($DropDownBox.Contains("Custom Install") -and ($RadioButton2.Checked -eq $True)) {
                                if (!($CustomIn -eq "")) {
    
                                    If ($file -like "*.exe") {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            $file = Get-ChildItem -Name "C:\Temps\"
                                            $Exitness = Start-Process "c:\Temps\$file"  -ArgumentList "$CustomIn" -Wait -PassThru
                                            $Exitness.ExitCode
                                            Start-Sleep 1
                                        }
                                        if (($? -eq $False) -and (!($result -eq 0))) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing executable"
                                            $mutex.ReleaseMutex()
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Executable install successful"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session                                                
                                    }
    
                                    ElseIf ($file -like "*.msi") {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            Set-Location -Path C:\Temps\
                                            $Exitness = Start-Process msiexec.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                            $Exitness.ExitCode
                                            Start-Sleep 1
                                        }
                                        if (($? -eq $True) -and ($result -eq 0)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file install was successful"
                                            $mutex.ReleaseMutex()
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file was successfully installed, but needs to restart"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing the MSI file"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session
                                    }
    
    
                                    ElseIf ($file -like "*.msp") {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            Set-Location -Path C:\Temps\
                                            $Exitness = Start-Process msiexec.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                            $Exitness.ExitCode
                                            Start-Sleep 1
                                        }
                                        if (($? -eq $True) -and ($result -eq 0)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSP file install was successful"
                                            $mutex.ReleaseMutex()
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1641)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - The MSI file was successfully installed, but needs to restart"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1603)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1603: A fatal error occurred during installation"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        elseif (($? -eq $True) -and ($result -eq 1618)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error 1618: Another installation is likely in progress"
                                            $mutex.ReleaseMutex()                                                
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue installing the MSP file"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session
                                    }
                                                                      
    
                                    ElseIf ($file -like "*.ps1") {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            Set-Location -Path C:\Temps\
                                            $Exitness = Start-Process powershell.exe -ArgumentList "$CustomIn" -Wait -PassThru -WindowStyle Minimized
                                            $Exitness.ExitCode
                                        }
                                        Start-Sleep 1
                                        if (($? -eq $True) -and ($result -eq 0)) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - PowerShell script executed successfully"
                                            $mutex.ReleaseMutex()
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue running PowerShell script"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session
                                    }
    
                                    ElseIf ($file -like "*.vbs") {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            Set-Location -Path C:\Temps\
                                            $Exitness = Start-Process cscript.exe -ArgumentList "$CustomIn" -Wait -PassThru
                                            $Exitness.ExitCode
                                        }
                                        Start-Sleep 1                                            
                                        if (($? -eq $False) -and (!($result -eq 0))) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue running VisualBasic script"
                                            $mutex.ReleaseMutex()
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - VisualBasic script executed successfully"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session
                                    }
    
                                    ElseIf (($file -like "*.cmd") -or ($file -like "*.bat")) {
                                        $Result = Invoke-Command -Session $Session -ArgumentList $CustomIn -ScriptBlock {
                                            Param($CustomIn)
                                            Set-Location -Path C:\Temps\
                                            $Exitness = Start-Process cmd.exe -ArgumentList "/c $CustomIn" -Wait -PassThru -WindowStyle Minimized
                                            $Exitness.ExitCode
                                        }
                                        Start-Sleep 1                                            
                                        if (($? -eq $False) -and (!($result -eq 0))) {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Issue running script"
                                            $mutex.ReleaseMutex()
                                        }
                                        else {
                                            $mutex.WaitOne()
                                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Script executed successfully"
                                            $mutex.ReleaseMutex()
                                        }
                                        Remove-PSSession -Session $Session
                                    }
    
                                    Else {
                                        $mutex.WaitOne()
                                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Error: File type not supported. Supported files: msi, msp, exe, ps1, vbs, and cmd"
                                        $mutex.ReleaseMutex()
                                        Remove-PSSession -Session $Session
                                    }
                                }
                                Else {
                                    $mutex.WaitOne()
                                    Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - No switches entered or task cancelled. No action was taken..."
                                    $mutex.ReleaseMutex()
                                    Remove-PSSession -Session $Session
                                }
                            }
    
                            # Catch errors
                            Else {
                                $mutex.WaitOne()
                                Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - An unexpected error occured. No action was taken..."
                                $mutex.ReleaseMutex()
                                Remove-PSSession -Session $Session
                            }
                                             
    
                        } #End copy check
                        Else {
                            $mutex.WaitOne()
                            Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - No file to install. It didn't copy..."
                            $mutex.ReleaseMutex()
                            Remove-PSSession -Session $Session
                        }
                                                                  
                    } #End test connection
    
                    Else {
                        $ComputersOFF += $Computer
                        $mutex.WaitOne()
                        Add-Content -Path "$env:SystemDrive\Admin_Tool\Multi_Install\Install_Log.txt" -Value "$(get-date -Format g): $Computer - Offline"
                        $mutex.ReleaseMutex()
                    }
                        
                } #End test for white/blank spaces
            } # End start-job
            Start-Sleep -Milliseconds 500
        } #End foreach loop
        $btn18.Visible = $true
        $btn19.Visible = $true
        $stBar1.text = "Done starting install for " + $Computers.Count + " computers. Refresh the log to get updated status..."
    
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran " + $File + " on " + $Computers.Count + " computers" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    
    } #End function
    
    Function HideUnusedItems {
        $btn10.Visible = $false
        $btn11.Visible = $false
        $btn17.Visible = $false
        $btn19.Visible = $false
        $btn18.Visible = $false
        $btn20.Visible = $false
        $btn21.Visible = $false
        $btn22.Visible = $false
        $btn23.Visible = $false
        $btn24.Visible = $false
        $btn25.Visible = $false
        $btn26.Visible = $false
    
        $list1.visible = $False
        $list2.visible = $False
        $list3.visible = $False
        $list5.visible = $false
        $list6.visible = $false
        $list7.visible = $false
        $list9.visible = $false
        $list10.visible = $false
        $list11.visible = $false
        $list12.visible = $false
    } #End Function HideUnusedItems
    
    Function ClearGrid {
        $List1.items.Clear()
        $List2.items.Clear()
        $List3.items.Clear()
        $List5.items.Clear()
        $List6.items.Clear()
        $List7.items.Clear()
        $List9.items.Clear()
        $List10.items.Clear()
        $List11.items.Clear()
        $List12.items.Clear()
    }
    
    ####################
    ### MCAFEE TOOLS ###
    ####################
    function CheckPolicies {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $cmdagentpath1 = "\\$computername\C$\Program Files\McAfee\Agent\cmdagent.exe"
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $cmdagentpath1) {
                    $stBar1.text = "Sending 'check for new policies' command to " + $computername.ToUpper()
                    $Result1 = Invoke-Command -ComputerName $computername -ScriptBlock {
                        $Result = Start-Process .\cmdagent.exe -WorkingDirectory "C:\Program Files\McAfee\Agent\" -ArgumentList "-c" -Wait -PassThru -WindowStyle Hidden
                        $Result.exitcode
                    }
                    if (($? -eq $True) -and ($result1 -eq 0)) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Successfully sent command 'check for new policies' to " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue sending the 'check policy' command to " + $computername.ToUpper()
                    }
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Sent 'check for new policies' McAfee command to " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
    
                }
                else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error: Unable to find file 'cmdagent.exe' on " + $computername.ToUpper()
                }
    
            }
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #########################################
    function collectprops {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $cmdagentpath1 = "\\$computername\C$\Program Files\McAfee\Agent\cmdagent.exe"
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $cmdagentpath1) {
                    $stBar1.text = "Sending 'collect and send properties' command to " + $computername.ToUpper()
                    $Result1 = Invoke-Command -ComputerName $computername -ScriptBlock {
                        $Result = Start-Process .\cmdagent.exe -WorkingDirectory "C:\Program Files\McAfee\Agent\" -ArgumentList "-p" -Wait -PassThru -WindowStyle Hidden
                        $Result.exitcode
                    }
                    if (($? -eq $True) -and ($result1 -eq 0)) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Successfully sent command 'collect and send properties' to " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue sending the 'collect and send properties' command to " + $computername.ToUpper()
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Sent 'collect and send properties' McAfee command to " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error: Unable to find file 'cmdagent.exe' on " + $computername.ToUpper()
                }
    
            }
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    ################################
    function sendevents {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $cmdagentpath1 = "\\$computername\C$\Program Files\McAfee\Agent\cmdagent.exe"
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $cmdagentpath1) {
                    $stBar1.text = "Sending 'send events' command to " + $computername.ToUpper()
                    $Result1 = Invoke-Command -ComputerName $computername -ScriptBlock {
                        $Result = Start-Process .\cmdagent.exe -WorkingDirectory "C:\Program Files\McAfee\Agent\" -ArgumentList "-f" -Wait -PassThru -WindowStyle Hidden
                        $Result.exitcode
                    }
                    if (($? -eq $True) -and ($result1 -eq 0)) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Successfully sent command 'send events' to " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue sending the 'send events' command to " + $computername.ToUpper()
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Sent 'send events' McAfee command to " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error: Unable to find file 'cmdagent.exe' on " + $computername.ToUpper()
                }
    
            }
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ############################################
    function McAfeeLog {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (test-connection $computername -quiet -count 1) {
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $stBar1.text = "Getting McAfee log file from " + $computername.ToUpper() + " Please wait..."
    
                $LogSort = Get-ChildItem -Path "\\$computername\C$\ProgramData\McAfee\Agent\logs\masvc*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                if ($null -ne $LogSort) {
                    $Log = Get-Content -Path $LogSort -Tail 8000 -ErrorAction SilentlyContinue
                    [array]::Reverse($Log)
                    $lbl2.text += "`t`t`t`t`t    McAfee log file from " + $computername + "`n`n"
                    $lbl2.text += $Log | Out-String
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Done getting McAfee log file from " + $computername.ToUpper()
                }
                else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error: unable to find the McAfee Agent Service log file."
                }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Viewed McAfee log file from " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            } #End Test-Connection
    
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End Function McAfeeLog
    
    ############################################
    function WSUSLogs {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        $lbl2.text = ""
        $lbl2.visible = $true
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (test-connection $computername -quiet -count 1) {
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $stBar1.text = "Getting WSUS log file from " + $computername.ToUpper() + " Please wait..."
    
                $LogSort = Get-ChildItem -Path "\\$computername\C$\Windows\SoftwareDistribution\ReportingEvent*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
                if ($null -ne $LogSort) {
                    $Log = Get-Content -Path $LogSort -Tail 8000 -ErrorAction SilentlyContinue
                    [array]::Reverse($Log)
                    $lbl2.text = "`t`t`t`t`t    WSUS log file from " + $computername + "`n`n"
                    $lbl2.text += $Log | Out-String
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Done getting WSUS log file from " + $computername.ToUpper()
                }
                else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Error: unable to find the WSUS log file."
                }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Viewed WSUS log file from " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            } #End Test-Connection
    
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End Function WSUSLog
    
    function EventViewer {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $eventvwr = "eventvwr.exe $computername"
                Invoke-Expression $eventvwr
                $stBar1.text = "Event viewer opened from " + $computername.ToUpper()
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened Event Viewer on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    function UsersGroups {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $UserGrps = "lusrmgr.msc -a /computer=$computername"
                Invoke-Expression $UserGrps
                $stBar1.text = "User and groups opened from " + $computername.ToUpper()
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened Users and Groups on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    function Services {
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $Services = "services.msc /computer=$computername"
                Invoke-Expression $Services
                $stBar1.text = "Services opened from " + $computername.ToUpper()
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Opened Services.msc on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    function Compare-DateTime($TimeOfObject, $Property) {
        $TimeOfObject = $TimeOfObject.converttodatetime($TimeOfObject.$Property)
        $TimeOfObject = (get-date) - $TimeOfObject
        $days = " Day "
        if ($TimeOfObject.days -ne 1) { $days = $days.replace('Day ', 'Days ') }
        $hours = " Hour "
        if ($TimeOfObject.hours -ne 1) { $hours = $hours.replace('Hour ', 'Hours ') }
        $minutes = " Minute "
        if ($TimeOfObject.minutes -ne 1) { $minutes = $minutes.replace('Minute ', 'Minutes ') }
        $TimeComparison = $TimeOfObject.days.tostring() + $days + $TimeOfObject.hours.tostring() + $hours + $TimeOfObject.minutes.tostring() + $minutes
        if ($TimeOfObject.days -eq 0) { $TimeComparison = $TimeComparison.Replace('0 Days ', '') }
        if ($TimeOfObject.days -eq 0 -AND $TimeOfObject.hours -eq 0) { $TimeComparison = $TimeComparison.Replace('0 Hours ', '') }
        return $TimeComparison
    }
    
    
    function SCCMRepair {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Sending SCCM repair command to " + $computername.ToUpper()
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process WMIC -ArgumentList "/namespace:\\root\ccm path sms_client CALL RepairClient" -Wait }
                #   cmd.exe WMIC /node:$computername /namespace:\\root\ccm path sms_client CALL RepairClient
                #   $oSCCM = ([wmiclass] '\\$computername\root\ccm:sms_client').RepairClient()
                #   $cmd = "cmd.exe /c psexec.exe \\$computername -d WMIC /namespace:\\root\ccm path sms_client CALL RepairClient"
                #   $SCCMRepair = Invoke-Expression $cmd
    
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "SCCM repair command sent to " + $computername.ToUpper()
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran an SCCM repair on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End function SCCM Repair
    
    function SCCMAuto {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                If (!(((Get-WmiObject -ComputerName $computername Win32_Service -filter "Name='CcmExec'").StartMode) -match "Auto")) {
                    $stBar1.text = "Setting SCCM Service to Auto on " + $computername.ToUpper()
                    Set-Service -ComputerName $computername 'CcmExec' -StartupType Automatic
                }
    
                Else { $stBar1.text = "Looks like it's already set to automatic start" }
    
                If (!(((Get-Service -ComputerName $computername 'CcmExec').status) -notmatch "Stopped")) {
                    $stBar1.text = "Restarting SCCM Service on " + $computername.ToUpper()
                    Restart-Service -InputObject $(Get-Service -ComputerName $computername -Name 'CcmExec')
                    $stBar1.text = "SCCM has been restarted on " + $computername.ToUpper()
                }
    
                Elseif (!(((Get-Service -ComputerName $computername 'CcmExec').status) -notmatch "Running"))
                { $stBar1.text = "SCCM Service is already running on " + $computername.ToUpper() }
    
                Else { $stBar1.text = "ERROR: Unable to restart SCCM because the service doesn't exist." }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Restarted SCCM on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End function SCCM Auto Start
    
    function RemoteAdmin {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 4) * 100
                $progress1.Value = $pct       #update the progress bar
                $stBar1.text = "Enabling Remote Admin on " + $computername.ToUpper()
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process netsh -ArgumentList "advfirewall firewall set rule group='remote administration' new enable=yes" -Wait }
                [int]$pct = (2 / 4) * 100
                $progress1.Value = $pct       #update the progress bar
                $stBar1.text = "Enabling Remote Desktop on " + $computername.ToUpper()
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process netsh -ArgumentList "advfirewall firewall set rule group='remote desktop' new enable=yes" -Wait }
                [int]$pct = (3 / 4) * 100
                $progress1.Value = $pct       #update the progress bar
                $stBar1.text = "Enabling Remote Management on " + $computername.ToUpper()
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process netsh -ArgumentList "advfirewall firewall set rule group='windows remote management' new enable=yes" -Wait }
                [int]$pct = (4 / 4) * 100
                $progress1.Value = $pct       #update the progress bar
                $stBar1.text = "Remote Admin and Desktop Enabled on " + $computername.ToUpper()
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Enabled remote admin on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End function remote admin and desktop
    
    function SCCMInstall {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        $stBar1.text = "Pinging " + $computername.ToUpper()
        if (Test-Connection $Computername -quiet -count 1) {
            $stBar1.text = "Checking SCCM Status on " + $computername.ToUpper()
            If (Get-Service -ComputerName $computername -Name CcmExec -ErrorAction SilentlyContinue)
            { $stBar1.text = "SCCM is already installed and running on " + $computername.ToUpper() }
            Else {
                if (Test-Path "\\$computername\C$\Windows\Temps\*") { Remove-Item -Force "\\$computername\C$\Windows\Temps\*" -Recurse }
                $stBar1.text = "Copying the SCCM Script from the DC to " + $computername.ToUpper()
                Copy-Item -Path "\\area52.afnoapps.usaf.mil\SYSVOL\AREA52.AFNOAPPS.USAF.MIL\Policies\{50DB100A-6FC0-423E-9D36-2B3252A638FB}\Machine\Scripts\Startup\SCCMCBScript.ps1" -Recurse -Destination "\\$computername\C$\Windows\Temps\" -Force -ErrorAction SilentlyContinue
                $TestFileCopy = Test-Path -Path "\\$computername\C$\Windows\Temps\SCCMCBScript.ps1" # Test if the file was successfully copied to the remote workstation.
                If ($TestFileCopy -eq $True) {
                    # If the file was copied, then perform the installation.
                    $stBar1.text = "Running the SCCM Script on " + $computername.ToUpper()
                    Invoke-Command -ComputerName $computername -ScriptBlock {
                        Start-Process powershell.exe -ArgumentList "-File C:\Windows\Temps\SCCMCBScript.ps1 -windowstyle hidden" -WindowStyle Minimized }
                    $stBar1.text = "SCCM Script Started on " + $computername.ToUpper()
                }
                Else {
                    # if the file wasn't copied, notify in the status bar.
                    $stBar1.text = "Failed to copy SCCM script to " + $computername.ToUpper()
                }
            }
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran SCCM install on " + $computername | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            } 
        }
        else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
    }
    
    function SCCMUnin {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                If (Test-Path "\\$computername\C$\Windows\CCMSetup\CCMSetup.exe") {
                    [int]$pct = (2 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Uninstalling SCCM on " + $computername.ToUpper() + "... This'll take a few minutes..."
                    Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process "C:\Windows\CcmSetup\CCMSetup.exe" -ArgumentList "/uninstall" -Wait }
    
                    if ($? -eq $True) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "The SCCM Client has been removed on " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue uninstalling SCCM on " + $computername.ToUpper()
                    }
                }
                Else {
                    [int]$pct = (3 / 3) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Unable to find the CcmSetup Uninstall file on " + $computername.ToUpper()
                }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Uninstalled SCCM on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
    
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End function SCCM Uninstall
    
    function Update-FormTitle {
        $form1.Text = "Admin Tool $Version - Logged in as $user on $userdomain"
    }
    
    ################################# INPUT BOX ##################################
    <#
    Function InputBox1{
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
    $title = 'Searcher'
    $msg   = 'Enter an OU that falls under the Osan OU (Must be exact!):
    Example: Osan AFB Computers'
    
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    $text}
    #>
    
    Function InputBox2 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter the name of the security group (Must be exact!):
    Example: GLS_Osan_SCCMTest'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox3 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter the name of the security group (Must be exact!):
    Example: GLS_607 SPTS_SCOCC'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox4 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter users name starting with last name (Like the GAL):
    Example: Presley, Elvis 52 CS...'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox5 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter a DSN number:
    
    Example: 784-1234'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox6 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter organization or unit:
    Wild card is optional before or after
    Example: 607 ACOMS or 607*'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox7 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter section or office symbol:
    Wild card is optional before or after
    Example: SCOCC or SCO*'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox10 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter duty title:
    Example: Unit Deployment Manager'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox11 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter the number of days to search for inactivity:
    Example: 30 (for 30 days) or 90 (for 90 days)'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    Function InputBox12 {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Searcher'
        $msg = 'Enter the number of days to search for inactivity:
    Example: 30 (for 30 days) or 90 (for 90 days)'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    ############################### Auto OU Detect (User) ##################################
    Function AutoOU {
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\BaseOU.txt")) {
            New-Item "$env:SystemDrive\Admin_Tool\Settings\BaseOU.txt" -ItemType File -Force
            if (IsAdmin) {
                $user = $env:USERNAME.Replace(".adm", "a")
                $ou = Get-ADUser $user -properties * | Select-Object -ExpandProperty DistinguishedName
                $result = $ou -Split (",", 3) | Select-Object -Index 2
                $result | Out-File $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt
            }
            Else {
                $ou = Get-ADUser $env:USERNAME -properties * | Select-Object -ExpandProperty DistinguishedName
                $result = $ou -Split (",", 3) | Select-Object -Index 2
                $result | Out-File $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt
            }
        }
    }
    
    ############################### Auto OU Detect (Admin) ##################################
    Function AutoOU2 {
        if (IsAdmin) {
            if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\AdminOU.txt")) {
                New-Item "$env:SystemDrive\Admin_Tool\Settings\AdminOU.txt" -ItemType File -Force
                $user = $env:USERNAME
                $ou = Get-ADUser $user -properties * | Select-Object -ExpandProperty DistinguishedName
                $result = $ou -Split (",", 2) | Select-Object -Index 1
                $result | Out-File $env:SystemDrive\Admin_Tool\Settings\AdminOU.txt
            }
        }
    }
    
    ############################### Auto OU Detect (MAJCOM) ##################################
    Function AutoOU3 {
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt")) {
            New-Item "$env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt" -ItemType File -Force
            if (!(IsAdmin)) {
                $user = $env:USERNAME.Replace(".adm", "a")
                $ou = Get-ADUser $user -properties * | Select-Object -ExpandProperty DistinguishedName
                $result = $ou -Split (",", 4) | Select-Object -Index 3
                $result | Out-File $env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt
            }
            Else {
                $ou = Get-ADUser $env:USERNAME -properties * | Select-Object -ExpandProperty DistinguishedName
                $result = $ou -Split (",", 4) | Select-Object -Index 3
                $result | Out-File $env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt
            }
        }
    }
    
    ################################# SEARCHER REPORTS FOLDER #########################
    Function SearchReport {
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Searcher")) {
            New-Item "$env:SystemDrive\Admin_Tool\Searcher" -ItemType Directory -Force
        }
        Invoke-Item $env:SystemDrive\Admin_Tool\Searcher
    }
    
    ############################# TEST IF SEARCHER FOLDER EXIST #############################
    Function SearchFolder {
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Searcher")) {
            New-Item "$env:SystemDrive\Admin_Tool\Searcher" -ItemType Directory -Force
        }
    }
    
    ################################# SEARCHER ##################################
    function OUList {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU3
        # Creates Folders if They Don't Exist #
        SearchFolder
        $stBar1.text = "Getting MAJCOM OU list... (Please wait...)"
        Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt) | Select-Object Name, DistinguishedName | Sort-Object -Property Name | Out-GridView -Title "List of OUs" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\MAJCOM OUs.csv"
        $stBar1.text = "Getting MAJCOM OU list... (COMPLETE)"
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran 'MAJCOM OU' list query" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    function UserOUList {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        $stBar1.text = "Getting users in base OU... (Please wait...)"
        Get-ADUser -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Filter * -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Out-GridView -Title "Users in base OU" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Users in base OU.csv"
        $stBar1.text = "Getting users in base OU... (COMPLETE!)"
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran 'Users in Base OU' query" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    function PCOUList {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        $stBar1.text = "Getting PCs in base OU... (Please wait...)"
        Get-ADComputer -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Filter * -Properties * | Select-Object Name, OperatingSystem, OperatingSystemVersion, Created, IPv4Address, DistinguishedName, Description, SID, Location | Out-GridView -Title "Computers in Base OU" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Computers in Base OU.csv"
        $stBar1.text = "Getting PCs in base OU... (COMPLETE!)"
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran 'PCs in Base OU' query" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    function PCSecList {
        $SearcherInput = InputBox2
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            $stBar1.text = "Checking security group..."
            if (Get-ADGroupMember -Identity "$SearcherInput") {
                $stBar1.text = "Getting PCs in $SearcherInput... (Please wait...)"
                $Userss = Get-ADGroupMember -Identity “$SearcherInput” | Select-Object Name
                foreach ($Us in $Userss) {
                    $i++
                    [int]$pct = ($i / $Userss.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                Get-ADGroupMember -Identity “$SearcherInput” | Get-ADComputer -Properties * | Select-Object Name, OperatingSystem, OperatingSystemVersion, Created, IPv4Address, DistinguishedName, Description, SID, Location | Out-GridView -Title "Computers in $SearcherInput" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Computers in $SearcherInput.csv"
                $stBar1.text = "Getting PCs in $SearcherInput... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched PCs in " + $SearcherInput + " security group" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find security group with the name $SearcherInput..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function UserSecList {
        $SearcherInput = InputBox3
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            $stBar1.text = "Checking security group..."
            if (Get-ADGroupMember -Identity "$SearcherInput") {
                $stBar1.text = "Getting users in the $SearcherInput security group... (Please wait...)"
                $Userss = Get-ADGroupMember -Identity "$SearcherInput" | Select-Object Name
                foreach ($Us in $Userss) {
                    $i++
                    [int]$pct = ($i / $Userss.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                Get-ADGroupMember -Identity "$SearcherInput" | Get-ADUser -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName | Out-GridView -Title "Users in $SearcherInput" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Users in $SearcherInput.csv"
                $stBar1.text = "Getting users in the $SearcherInput security group... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched users in " + $SearcherInput + " security group" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find security group with the name $SearcherInput..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function UserSearchList {
        $SearcherInput = InputBox4
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            if (Get-ADUser -Filter "displayname -like '$SearcherInput*'") {
                $stBar1.text = "Searching $SearcherInput... (Please wait...)"
                $Userss = Get-ADUser -Filter "displayname -like '$SearcherInput*'"
                foreach ($Us in $Userss) {
                    $i++
                    [int]$pct = ($i / $Userss.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                Get-ADUser -Filter "displayname -like '$SearcherInput*'" -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName | Out-GridView -Title "Users with name of $SearcherInput" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\User List $SearcherInput.csv"
                $stBar1.text = "Searching $SearcherInput... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched user " + $SearcherInput | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find users with name $SearcherInput..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function PhoneList {
        $SearcherInput = InputBox5
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            if (Get-ADUser -Filter "OfficePhone -eq '$SearcherInput'" -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt)) {
                [int]$pct = (5 / 100) * 100
                $progress1.Value = $pct #update the progress bar
                $stBar1.text = "Searching users with $SearcherInput... (Please wait...)"
                $Query = Get-ADUser -Filter "OfficePhone -like '*$SearcherInput'" -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object  SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
                foreach ($Us in $Query) {
                    $i++
                    [int]$pct = ($i / $Query.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                $Query | Out-GridView -Title "Users with DSN of $SearcherInput" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Users With DSN $SearcherInput.csv"
                $stBar1.text = "Searching users with $SearcherInput... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched users with DSN " + $SearcherInput | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find users with DSN $SearcherInput..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function OrgnOffice {
        $SearcherInput = InputBox6
        $SearcherInput2 = InputBox7
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!(("$SearcherInput" -eq "") -or ("$SearcherInput2" -eq ""))) {
            if (Get-ADUser -Filter { Organization -like $SearcherInput -and Office -like $SearcherInput2 } -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt)) {
                [int]$pct = (5 / 100) * 100
                $progress1.Value = $pct #update the progress bar
                $stBar1.text = "Searching users in $SearcherInput $SearcherInput2... (Please wait...)"
                $Query = Get-ADUser -Filter { Organization -like $SearcherInput -and Office -like $SearcherInput2 } -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object  SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
                foreach ($Us in $Query) {
                    $i++
                    [int]$pct = ($i / $Query.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                $Query | Out-GridView -Title "Users In $SearcherInput $SearcherInput2" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Users In $SearcherInput $SearcherInput2.csv"
                $stBar1.text = "Searching users in $SearcherInput $SearcherInput2... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched users in unit " + $SearcherInput + " and office " + $SearcherInput2 | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find org and office: $SearcherInput $SearcherInput2... (The search is only base level)" }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function TitleList {
        $SearcherInput = InputBox10
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            if (Get-ADUser -Filter "Title -eq '$SearcherInput'" -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt)) {
                [int]$pct = (5 / 100) * 100
                $progress1.Value = $pct #update the progress bar
                $stBar1.text = "Searching users with title of $SearcherInput... (Please wait...)"
                $Query = Get-ADUser -Filter "Title -eq '$SearcherInput'" -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
                foreach ($Us in $Query) {
                    $i++
                    [int]$pct = ($i / $Query.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 10
                }
                $Query | Out-GridView -Title "Users With Title $SearcherInput" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Users Title $SearcherInput.csv"
                $stBar1.text = "Searching users with title of $SearcherInput... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched users with duty title " + $SearcherInput | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Unable to find users title of $SearcherInput..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function DisabledUsers {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        $stBar1.text = "Getting disabled base users... (Please wait...)"
        [int]$pct = (5 / 100) * 100
        $progress1.Value = $pct #update the progress bar
        $Query = Get-ADUser -Filter { Enabled -eq $false } -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, Description, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
        foreach ($Us in $Query) {
            $i++
            [int]$pct = ($i / $Query.Count) * 100
            #update the progress bar
            $progress1.Value = $pct
            Start-Sleep -Milliseconds 5
        }
        $Query | Out-GridView -Title "Base Disabled Users" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Base Disabled Users.csv"
        $stBar1.text = "Getting disabled base users... (COMPLETE!)"
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched 'Base Disabled Users'" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    function AdminUsers {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Creates Specific OU Path #
        AutoOU2
        # Creates Folders if They Don't Exist #
        SearchFolder
        $stBar1.text = "Getting adminstrative base users... this can take some time."
        [int]$pct = (5 / 100) * 100
        $progress1.Value = $pct #update the progress bar
        $Query = Get-ADUser -Filter * -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\AdminOU.txt) -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
        foreach ($Us in $Query) {
            $i++
            [int]$pct = ($i / $Query.Count) * 100
            #update the progress bar
            $progress1.Value = $pct
            Start-Sleep -Milliseconds 5
        }
        $Query | Out-GridView -Title "Base Admin Users" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Base Admin Users.csv"
        $stBar1.text = "Getting adminstrative base users... (COMPLETE!)"
        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched 'Base Admin Users'" | out-file -filepath $lfile -append }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
    }
    
    function StaleComputers {
        $SearcherInput = InputBox11
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Checks if a number was entered #
        $NumCheck = [Microsoft.VisualBasic.Information]::isnumeric($SearcherInput)
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            if ($NumCheck -eq $True) {
                [int]$pct = (5 / 100) * 100
                $progress1.Value = $pct #update the progress bar
                $stBar1.text = "Searching stale computers older than $SearcherInput days... this can take some time"
                $time = (Get-Date).AddDays( - ($SearcherInput)) #number of days from today since the last logon.
                $Query = Get-ADComputer -Filter { lastLogonDate -lt $time } -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object Name, OperatingSystem, OperatingSystemVersion, Created, LastLogonDate, Modified, IPv4Address, DistinguishedName, Description, SID, Location | Sort-Object -Property Name
                foreach ($Us in $Query) {
                    $i++
                    [int]$pct = ($i / $Query.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 5
                }
                $Query | Out-GridView -Title "Stale Computers" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Stale Computers.csv"
                $stBar1.text = "Searching stale computers older than $SearcherInput days... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched stale PC accounts older than " + $SearcherInput + " days" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Enter only numeric values..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    function StaleUsers {
        $SearcherInput = InputBox12
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        # Checks if a number was entered #
        $NumCheck = [Microsoft.VisualBasic.Information]::isnumeric($SearcherInput)
        # Creates Specific OU Path #
        AutoOU
        # Creates Folders if They Don't Exist #
        SearchFolder
        if (!("$SearcherInput" -eq "")) {
            if ($NumCheck -eq $True) {
                $stBar1.text = "Searching stale users older than $SearcherInput days... this can take some time"
                [int]$pct = (5 / 100) * 100
                $progress1.Value = $pct #update the progress bar
                $time = (Get-Date).AddDays( - ($SearcherInput)) #number of days from today since the last logon.
                $Query = Get-ADUser -Filter { LastLogonDate -lt $time } -SearchBase (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) -Properties * | Select-Object SurName, GivenName, personalTitle, title, SamAccountName, iaTrainingDate, Organization, Office, OfficePhone, EmailAddress, @{N = 'buildingName'; E = { $_.buildingName[0] } }, street, State, Country, City, LockedOut, Enabled, @{n = "MemberOf"; e = { $_.MemberOf -replace '^CN=([^,]+),OU=.+$', '$1' } } | Sort-Object -Property SurName
                foreach ($Us in $Query) {
                    $i++
                    [int]$pct = ($i / $Query.Count) * 100
                    #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 5
                }
                $Query | Out-GridView -Title "Stale Users" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Searcher\Stale Users.csv"
                $stBar1.text = "Searching Stale Users Older Than $SearcherInput Days... (COMPLETE!)"
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched stale user accounts older than " + $SearcherInput + " days" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Enter only numeric values..." }
        }
        else { $stBar1.text = "Action cancelled or no input given..." }
    }
    
    ################################ PING RECORDS ##################################
    Function PingQuery {
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Ping-Sweep")) {
            New-Item "$env:SystemDrive\Admin_Tool\Ping-Sweep" -ItemType Directory -Force
        }
        Invoke-Item $env:SystemDrive\Admin_Tool\Ping-Sweep
    }
    
    #######################################
    #### Input Box for IP Range Pinger ####
    #######################################
    Function IPPingerInputBox {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'IP Range Pinger'
        $msg = 'Enter the IP address range:
    Example: 192.168.1 or 132.61.80
    
    Note: Leave the last octet out. The
    tool will ping all 254 IPs in the IP
    range.'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ########################################
    
    ############################## IP RANGE PINGER #################################
    Function NetScanner {
    
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Ping-Sweep")) {
            New-Item "$env:SystemDrive\Admin_Tool\Ping-Sweep" -ItemType Directory -Force
        }
    
        $stBar1.text = "Requesting IP range..."
        $net = IPPingerInputBox
        $range = 1..254
        if (!($net -eq "")) {
            $stBar1.text = "Starting ping jobs for 254 IPs with range of " + $net + ".x (Please wait...)"
            Start-Sleep 1
            [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
            $PingStatus = foreach ($r in $range) {
                $ip = “{0}.{1}” -F $net, $r
    
                $running = @(Get-Job -State Running)
                if ($running.Count -ge 40) {
                    $null = $running | Wait-Job -Any
                }
    
                $i++
                [int]$pct = ($i / $range.Count) * 100
                #update the progress bar
                $progress1.Value = $pct
    
                Start-Job -Name "$ip" -ArgumentList $ip -ScriptBlock {
                    param($ip)
    
                    if (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip) {
                        try { $HostName = ([System.Net.Dns]::GetHostEntry([ipaddress]$ip)).HostName }
                        catch { $HostName = "Unknown" }
         
                        $PSObject = New-Object PSObject -Property @{
                            IPAddress = [string]$ip
                            HostName  = [string]$HostName
                        }
                        $PSObject | Select-Object IPAddress, HostName
         
                    }
                } -ErrorAction SilentlyContinue
            }
            $stBar1.text = "Collecting info from ping jobs (Please Wait...)"
            $PingStatus | Wait-Job | Receive-Job | Select-Object IPAddress, HostName | Out-GridView -Title "IP Range Pinger" -PassThru | Export-Csv -NoTypeInformation -Path $env:SystemDrive\Admin_Tool\Ping-Sweep\IP_Range_Pinger.csv
            $stBar1.text = "Cleaning up and reporting results..."
            $PingStatus | Remove-Job
            $stBar1.text = "Done pinging ip range for " + $net + ".x"
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran ping IP range for " + $net + ".x" | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else {
            [int]$pct = (10 / 10) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            $stBar1.text = "No input was given or action cancelled."
        }
    }
    
    ################################ OPEN FILE DIALOG BOX ##################################
    Function Get-FileName($initialDirectory) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $initialDirectory
        $OpenFileDialog.filter = "txt (*.txt)| *.txt"
        $OpenFileDialog.ShowDialog() | Out-Null
        $OpenFileDialog.filename
    }
    
    ################################ PING SWEEP - DETAILED ##################################
    Function DetailPing {
        [CmdletBinding(ConfirmImpact = 'Low')] 
        Param([Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
            [String[]]$ComputerNames)
    
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Ping-Sweep")) {
            New-Item "$env:SystemDrive\Admin_Tool\Ping-Sweep" -ItemType Directory -Force
        }
        $vbmsg1 = $vbmsg.popup("After clicking 'OK' on this message, select a text file with computer names. Once all details are collected, a grid window will pop-up with the results. You can save this output by selecting all of the entries and clicking 'OK'.", 0, "Info", 0)
        $stBar1.text = "Select a List of Computers (text file only)"
        $Computernames = Get-FileName
        $ComputerName = Get-Content $ComputerNames -ErrorAction SilentlyContinue
        if ($null -ne $ComputerName) {
            [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
            $stBar1.text = "Checking Computer List..."
            start-sleep -Milliseconds 500
            $PCData = foreach ($PC in $ComputerName) {
    
                $running = @(Get-Job -State Running)
                if ($running.Count -ge 40) {
                    $null = $running | Wait-Job -Any
                }
    
                $i++
                [int]$pct = ($i / $ComputerName.Count) * 100
                #update the progress bar
                $progress1.Value = $pct
    
                $stBar1.text = "Starting job for " + $PC + " (" + $i + " of " + $ComputerName.count + ")"
                Start-Sleep -Milliseconds 50
    
                Start-Job -Name "$PC" -ArgumentList $PC, $ComputerName, $PCData -ScriptBlock {
                    param($PC, $ComputerName, $PCData)
                    try {
                        Test-Connection -ComputerName $PC -Count 1 -ErrorAction Stop | Out-Null
                        $LastLoggedOn = Get-ChildItem -Path "\\$PC\c$\Users" -Filter "1*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Select-Object -expandProperty Name -ErrorAction SilentlyContinue
                        $OS = Get-WmiObject -ComputerName $PC -Class Win32_OperatingSystem -EA 0
                        $Mfg = Get-WmiObject -ComputerName $PC -Class Win32_ComputerSystem -EA 0
                        $SN = Get-WmiObject -ComputerName $PC -Class win32_bios -EA 0
                        try { $SDC = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation').GetValue('Model') }
                        catch { $SDC = "" }
                        #$SDC   = (Invoke-Command -ComputerName $PC -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation -Name Model}).Model
                        #$OSVersion   = (Invoke-Command -ComputerName $PC -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseId}).ReleaseId
                        try { $OSVersion = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion').GetValue('ReleaseId') }
                        catch { $OSVersion = "" }
                        #$OSBuild   = (Invoke-Command -ComputerName $PC -ScriptBlock {Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentBuildNumber}).CurrentBuildNumber
                        try { $Location = (([adsisearcher]"(&(objectCategory=computer)(name=$PC))").FindAll().properties.location) | Out-String }
                        catch { $Location = "" }
                        $software = (Invoke-Command -Computer $PC { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue } | Sort-Object DisplayName).DisplayName
            
                        try {
                            $IPs = @()
                            $MACs = @()
                            foreach ($IPAddress in ((Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" -EA 0 | 
                                        Where-Object { $_.IpEnabled -Match "True" }).IPAddress | Where-Object { $_ -match "\." })) {
                                $IPs += $IPAddress
                                $MACs += (Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" -EA 0 | 
                                    Where-Object { $_.IPAddress -eq $IPAddress }).MACAddress
                            }
                        }
                        catch { $IPs = ""; $MACs = "" }
    
                        #$stBar1.text   = "Reply From $PC"
                        $Props = @{
                            ComputerName  = $PC.ToUpper()
                            Status        = 'Up'
                            IPAddress     = $IPs -join ', '
                            MACAddress    = $MACs -join ', '
                            OSCaption     = $OS.Caption
                            SDCVersion    = $SDC
                            OSVersion     = $OSVersion
                            OSBuild       = $OS.Version
                            Model         = $Mfg.model
                            SerialNumber  = $SN.SerialNumber
                            LastLoggedOn  = (([adsisearcher]"(&(objectCategory=user)(sAMAccountName=$LastLoggedOn))").FindAll().Properties.displayname | Out-String)
                            Location      = $Location
                            InstalledApps = $software + "`n"
                        }
                        New-Object -TypeName PSObject -Property $Props
                    }
                    catch {
                        # either ping failed or access denied 
                        try {
                            Test-Connection -ComputerName $PC -Count 1 -ErrorAction Stop | Out-Null
                            #$stBar1.text   = "Issue Pinging $PC"
                            $Props = @{
                                ComputerName  = $PC.ToUpper()
                                Status        = $(if ($Error[0].Exception -match 'Access is denied') { 'Access is denied' } else { $Error[0].Exception })
                                IPAddress     = ''
                                MACAddress    = ''
                                OSCaption     = ''
                                SDCVersion    = ''
                                OSVersion     = ''
                                OSBuild       = ''
                                Model         = ''
                                SerialNumber  = ''
                                LastLoggedOn  = ''
                                Location      = ''
                                InstalledApps = ''
                            }
                            New-Object -TypeName PSObject -Property $Props            
                        }
                        catch {
                            #$stBar1.text   = "No Reply From $PC"
                            $Props = @{
                                ComputerName  = $PC.ToUpper()
                                Status        = 'Down'
                                IPAddress     = ''
                                MACAddress    = ''
                                OSCaption     = ''
                                SDCVersion    = ''
                                OSVersion     = ''
                                OSBuild       = ''
                                Model         = ''
                                SerialNumber  = ''
                                LastLoggedOn  = ''
                                Location      = ''
                                InstalledApps = ''
                            }
                            New-Object -TypeName PSObject -Property $Props              
                        }
                    }
                }
            }
            $stBar1.text = "Collecting Info From PCs in List. Please Wait..."
            $PCData | Wait-Job | Receive-Job | Select-Object ComputerName, Status, OSCaption, SDCVersion, OSVersion, OSbuild, IPAddress, MacAddress, Model, SerialNumber, LastLoggedOn, Location, InstalledApps | Sort-Object ComputerName | Out-GridView -Title "Ping Sweep" -PassThru | Export-Csv -NoTypeInformation -Path $env:SystemDrive\Admin_Tool\Ping-Sweep\Ping_Sweep_DETAILED.csv
            $stBar1.text = "Cleaning Up & Reporting Results..."
            $PCData | Remove-Job
            $stBar1.text = "Detailed Ping Sweep Complete!"
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran detailed ping sweep for " + $ComputerName.Count + " computers" | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else { $stBar1.text = "No file was selected or action cancelled." }
    }
    
    ################################ PING SWEEP - HEALTH STATS ##################################
    Function HealthPing {
        [CmdletBinding(ConfirmImpact = 'Low')] 
        Param([Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
            [String[]]$ComputerNames)
    
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Ping-Sweep")) {
            New-Item "$env:SystemDrive\Admin_Tool\Ping-Sweep" -ItemType Directory -Force
        }
        $vbmsg1 = $vbmsg.popup("After clicking 'OK' on this message, select a text file with computer names. Once all details are collected, a grid window will pop-up with the results. You can save this output by selecting all of the entries and clicking 'OK'.", 0, "Info", 0)
        $stBar1.text = "Select a List of Computers (text file only)"
        $Computernames = Get-FileName
        $ComputerName = Get-Content $ComputerNames -ErrorAction SilentlyContinue
        if ($null -ne $ComputerName) {
            [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
            $stBar1.text = "Checking Computer List..."
            start-sleep -Milliseconds 500
            $PCData = foreach ($PC in $ComputerName) {
    
                $running = @(Get-Job -State Running)
                if ($running.Count -ge 40) {
                    $null = $running | Wait-Job -Any
                }
    
                $i++
                [int]$pct = ($i / $ComputerName.Count) * 100
                #update the progress bar
                $progress1.Value = $pct
    
                $stBar1.text = "Starting job for " + $PC + " (" + $i + " of " + $ComputerName.count + ")"
                Start-Sleep -Milliseconds 50
    
                Start-Job -Name "$PC" -ArgumentList $PC -ScriptBlock {
                    param($PC)
                    try {
                        Test-Connection -ComputerName $PC -Count 1 -ErrorAction Stop | Out-Null
    
                        # Installed Software#
                        $software = Invoke-Command -Computer $PC { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* }
    
                        # McAfee Info #
                        if ($software.DisplayName -like "*McAfee*") { $IsInstalledMc = "Yes" } else { $IsInstalledMc = "No" }
                        try { $McAfeeVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\Agent').GetValue('AgentVersion') }
                        catch { $McAfeeVer = "" }
                        try { $PackVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\TVD\Shared Components\Framework').GetValue('certPkgVersion') }
                        catch { $PackVer = "" }
                        try { $LastCheck = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\TVD\Shared Components\Framework').GetValue('LastUpdateCheck') }
                        catch { $LastCheck = "" }
                        try { $SysCoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\SystemCore').GetValue('system_core_version') }
                        catch { $SysCoreVer = "" }
                        try { $CoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\McAfee\AVSolution\AVS\AVS').GetValue('szAMCoreVersion') }
                        catch { $CoreVer = "" }
                        try { $DLPVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\McAfee\DLP\Agent').GetValue('AgentVersion') }
                        catch { $DLPVer = "" }
                        try { $EndPointAV = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\McAfee\Endpoint\AV').GetValue('ProductVersion') }
                        catch { $EndPointAV = "" }
                        try { $ENSAMcoreVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\McAfee\Endpoint\AV\ENSAMCoreVersionTrack').GetValue('LatestAMCoreAvailable') }
                        catch { $ENSAMcoreVer = "" }
                        try { $HIPS = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\McAfee\Endpoint\Ips\HIP').GetValue('VERSION') }
                        catch { $HIPS = "" }
                        try { $HIPSCore = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\HIP').GetValue('HipsCoreVersion') }
                        catch { $HIPSCore = "" }
                        try { $NIPS = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\McAfee\HIP').GetValue('NipsVersion') }
                        catch { $NIPS = "" }
                        try { $PolicyAgent = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$PC").OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\ePolicy Orchestrator\Application Plugins\PHCONTEN6000').GetValue('Version') }
                        catch { $PolicyAgent = "" }
                        try { $ACCMVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$PC").OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\ePolicy Orchestrator\Application Plugins\S_USAF021001').GetValue('Version') }
                        catch { $ACCMVer = "" }
                        try { $EPOSer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', "$PC").OpenSubKey('SOFTWARE\WOW6432Node\Network Associates\epolicy orchestrator\agent').GetValue('eposerverlist') -split (";") | Select-Object -First 1 }
                        catch { $EPOSer = "" }
    
                        # SCCM Info #
                        if ($software.DisplayName -like "*Configuration*") { $IsInstalledCM = "Yes" } else { $IsInstalledCM = "No" }
                        try { $SCCMVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\SMS\Mobile Client').GetValue('SmsClientVersion') }
                        catch { $SCCMVer = "" }
                        try { $MngPoint = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\SMS\DP').GetValue('ManagementPoints') }
                        catch { $MngPoint = "" }
                        try { $SiteCode = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\SMS\Mobile Client').GetValue('AssignedSiteCode') }
                        catch { $SiteCode = "" }
                        try { $SCCMDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\CCM\CcmEval').GetValue('LastEvalTime') }
                        catch { $SCCMDate = "" }
    
                        # Tanium Info #
                        if ($software.DisplayName -like "*Tanium*") { $IsInstalledTa = "Yes" } else { $IsInstalledTa = "No" }
                        try { $TanVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('Version') }
                        catch { $TanVer = "" }
                        try { $StartDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('First Start') }
                        catch { $StartDate = "" }
                        try { $TanDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\WOW6432Node\Tanium\Tanium Client\Sensor Data\Applications\TaniumClient').GetValue('LastStatUpdate') }
                        catch { $TanDate = "" }
    
                        # Get Updates #
                        $UpdateSer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('Software\Policies\Microsoft\Windows\WindowsUpdate').GetValue('WUServer')
                        try { $rUpdates = Get-WmiObject win32_quickfixengineering -computername $PC | Sort-Object installedon -Descending | Select-Object -First 10 }
                        catch { $rUpdates = "" }
                        try { $rUpdate = $rUpdates | Select-Object -ExpandProperty InstalledOn }
                        catch { $rUpdate = "" }
                        try { $rUpdate2 = $rUpdates | Select-Object -ExpandProperty HotFixID }
                        catch { $rUpdate2 = "" }
                        try { $rUpdate3 = $rUpdates | Select-Object -ExpandProperty InstalledBy }
                        catch { $rUpdate3 = "" }
    
                        # SDC Version #
                        try { $SDC = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $PC).OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation').GetValue('Model') }
                        catch { $SDC = "" }
    
                        # SCCM Run Status #
                        $SCCMStat = Get-Service -ComputerName $PC -Name "CcmExec" -ErrorAction SilentlyContinue
    
                        # Tanium Run Status #
                        $TanStat = Get-Service -ComputerName $PC -Name "Tanium Client" -ErrorAction SilentlyContinue
    
                        # McAfee Run Status #
                        $McAfeeStat = Get-Service -ComputerName $PC -Name "masvc" -ErrorAction SilentlyContinue
    
                        # Queries Last Boot
                        try { $LastBoot = Get-WmiObject Win32_OperatingSystem -ComputerName $PC | Select-Object @{LABEL = 'LastBootUpTime'; EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } } | Select-Object -ExpandProperty LastBootUpTime }
                        catch { $LastBoot = "" }
    
                        try {
                            $IPs = @()
                            $MACs = @()
                            foreach ($IPAddress in ((Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" -EA 0 | 
                                        Where-Object { $_.IpEnabled -Match "True" }).IPAddress | Where-Object { $_ -match "\." })) {
                                $IPs += $IPAddress
                                $MACs += (Get-WmiObject -ComputerName $PC -Class "Win32_NetworkAdapterConfiguration" -EA 0 | 
                                    Where-Object { $_.IPAddress -eq $IPAddress }).MACAddress
                            }
                        }
                        catch { $IPs = ""; $MACs = "" }
    
                        #$stBar1.text   = "Reply From $PC"
                        $Props = @{
                            ComputerName             = [string]$PC.ToUpper()
                            Status                   = 'Up'
                            IPAddress                = [string]$IPs -join ', '
                            MACAddress               = [string]$MACs -join ', '
                            SDCVersion               = [string]$SDC
                            LastBoot                 = [string]$LastBoot
                            McAfeeInstalled          = [string]$IsInstalledMc
                            McAfeeStatus             = [string]$McAfeeStat.Status
                            McAfeeVersion            = [string]$McAfeeVer
                            LastCheck                = [string]$LastCheck
                            PackageVersion           = [string]$PackVer
                            PolicyAgent              = [string]$PolicyAgent
                            ACCMVersion              = [string]$ACCMVer
                            SystemCoreVersion        = [string]$SysCoreVer
                            CoreVersion              = [string]$CoreVer
                            DLPVersion               = [string]$DLPVer
                            EndPointAV               = [string]$EndPointAV
                            ENSAM_CoreVersion        = [string]$ENSAMcoreVer
                            HIPS                     = [string]$HIPS
                            HIPSCore                 = [string]$HIPSCore
                            NIPS                     = [string]$NIPS
                            EPOServer                = [string]$EPOSer
                            SCCMInstalled            = [string]$IsInstalledCM
                            SCCMStatus               = [string]$SCCMStat.Status
                            SCCMVersion              = [string]$SCCMVer
                            ManagementPoint          = [string]$MngPoint
                            SiteCode                 = [string]$SiteCode
                            SCCMUpdate               = [string]$SCCMDate
                            TaniumInstalled          = [string]$IsInstalledTa
                            TaniumStatus             = [string]$TanStat.Status
                            TaniumVersion            = [string]$TanVer
                            StartDate                = [string]$StartDate
                            TaniumUpdate             = [string]$TanDate
                            UpdateServer             = [string]$UpdateSer
                            Last10UpdatesDATE        = [string]$rUpdate + "`n"
                            Last10UpdatesKB          = [string]$rUpdate2 + "`n"
                            Last10UpdatesInstalledBy = [string]$rUpdate3 + "`n"
                        }
                        New-Object -TypeName PSObject -Property $Props
                    }
                    catch {
                        # either ping failed or access denied 
                        try {
                            Test-Connection -ComputerName $PC -Count 1 -ErrorAction Stop | Out-Null
                            #$stBar1.text   = "Issue Pinging $PC"
                            $Props = @{
                                ComputerName             = $PC.ToUpper()
                                Status                   = $(if ($Error[0].Exception -match 'Access is denied') { 'Access is denied' } else { $Error[0].Exception })
                                IPAddress                = ''
                                MACAddress               = ''
                                SDCVersion               = ''
                                LastBoot                 = ''
                                McAfeeInstalled          = ''
                                McAfeeStatus             = ''
                                McAfeeVersion            = ''
                                LastCheck                = ''
                                PackageVersion           = ''
                                PolicyAgent              = ''
                                ACCMVersion              = ''
                                SystemCoreVersion        = ''
                                CoreVersion              = ''
                                DLPVersion               = ''
                                EndPointAV               = ''
                                ENSAMCoreVersion         = ''
                                HIPS                     = ''
                                HIPSCore                 = ''
                                NIPS                     = ''
                                EPOServer                = ''
                                SCCMInstalled            = ''
                                SCCMStatus               = ''
                                SCCMVersion              = ''
                                ManagementPoint          = ''
                                SiteCode                 = ''
                                SCCMUpdate               = ''
                                TaniumInstalled          = ''
                                TaniumStatus             = ''
                                TaniumVersion            = ''
                                StartDate                = ''
                                TaniumUpdate             = ''
                                UpdateServer             = ''
                                Last10UpdatesDATE        = ''
                                Last10UpdatesKB          = ''
                                Last10UpdatesInstalledBy = ''
                            }
                            New-Object -TypeName PSObject -Property $Props            
                        }
                        catch {
                            #$stBar1.text   = "No Reply From $PC"
                            $Props = @{
                                ComputerName             = $PC.ToUpper()
                                Status                   = 'Down'
                                IPAddress                = ''
                                MACAddress               = ''
                                SDCVersion               = ''
                                LastBoot                 = ''
                                McAfeeInstalled          = ''
                                McAfeeStatus             = ''
                                McAfeeVersion            = ''
                                LastCheck                = ''
                                PackageVersion           = ''
                                PolicyAgent              = ''
                                ACCMVersion              = ''
                                SystemCoreVersion        = ''
                                CoreVersion              = ''
                                DLPVersion               = ''
                                EndPointAV               = ''
                                ENSAMCoreVersion         = ''
                                HIPS                     = ''
                                HIPSCore                 = ''
                                NIPS                     = ''
                                EPOServer                = ''
                                SCCMInstalled            = ''
                                SCCMStatus               = ''
                                SCCMVersion              = ''
                                ManagementPoint          = ''
                                SiteCode                 = ''
                                SCCMUpdate               = ''
                                TaniumInstalled          = ''
                                TaniumStatus             = ''
                                TaniumVersion            = ''
                                StartDate                = ''
                                TaniumUpdate             = ''
                                UpdateServer             = ''
                                Last10UpdatesDATE        = ''
                                Last10UpdatesKB          = ''
                                Last10UpdatesInstalledBy = ''
                            }
                            New-Object -TypeName PSObject -Property $Props              
                        }
                    }
                }
            }
            $stBar1.text = "Collecting Info From PCs in List. Please Wait..."
            $PCData | Wait-Job | Receive-Job | Select-Object ComputerName, Status, IPAddress, MacAddress, SDCVersion, LastBoot, McAfeeInstalled, McAfeeStatus, McAfeeVersion, PackageVersion, LastCheck, PolicyAgent, ACCMVersion, SystemCoreVersion, CoreVersion, DLPVersion, EndPointAV, ENSAMCoreVersion, HIPS, HIPS_Core, NIPS, EPOServer, SCCMInstalled, SCCMStatus, SCCMVersion, ManagementPoint, SiteCode, SCCMUpdate, TaniumInstalled, TaniumStatus, TaniumVersion, StartDate, TaniumUpdate, UpdateServer, Last10UpdatesDATE, Last10UpdatesKB, Last10UpdatesInstalledBy | Sort-Object ComputerName | Out-GridView -Title "Ping Sweep" -PassThru | Export-Csv -NoTypeInformation -Path $env:SystemDrive\Admin_Tool\Ping-Sweep\Ping_Sweep_HEALTH.csv
            $stBar1.text = "Cleaning Up & Reporting Results..."
            $PCData | Remove-Job
            $stBar1.text = "Detailed Ping Sweep Complete!"
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran health ping sweep for " + $ComputerName.Count + " computers" | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else { $stBar1.text = "No file was selected or action cancelled." }
    }
    
    ################################ PING SWEEP - FAST ##################################
    Function FastPinger {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Ping-Sweep")) {
            New-Item "$env:SystemDrive\Admin_Tool\Ping-Sweep" -ItemType Directory -Force
        }
        $vbmsg1 = $vbmsg.popup("After clicking 'OK' on this message, select a text file with computer names. Once all pings are done, a grid window will pop-up with the results. You can save this output by selecting all of the entries and clicking 'OK'.", 0, "Info", 0)
        $stBar1.text = "Select a List of Computers (text file only)"
        $Computernames = Get-FileName
        $FileCheck = Get-Content $Computernames -ErrorAction SilentlyContinue
        if ($null -ne $FileCheck) {
            [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
            $counter = $(Get-Content $Computernames).count
            $job = Get-Content $Computernames | 
            ForEach-Object {
                $running = @(Get-Job -State Running)
                if ($running.Count -ge 40) {
                    $null = $running | Wait-Job -Any
                }
    
                $i++
                [int]$pct = ($i / $Counter) * 100
                #update the progress bar
                $progress1.Value = $pct
    
                $stBar1.text = "Starting ping job for " + $_ + " (" + $i + " of " + $Counter + ")"
                Start-Sleep -Milliseconds 50
    
                Start-Job -Name $_  -ArgumentList $_ -ScriptBlock { 
                    param ($ComputerName)
                    $Online = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
                    New-Object -TypeName psObject -Property @{ComputerName = $ComputerName ; Status = $Online }
                }
            }
            $stBar1.text = "Collecting Ping Replies From PCs in List. Please Wait..."
            $job | Wait-Job | Receive-Job | Select-Object Computername, Status | Out-GridView -Title "Ping Sweep" -PassThru | Export-Csv -NoTypeInformation -Path $env:SystemDrive\Admin_Tool\Ping-Sweep\Ping_Sweep_FAST.csv
            $stBar1.text = "Cleaning Up & Reporting Results..."
            $job | Remove-Job
            $stBar1.text = "Ping Sweep Complete!"
    
            if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran fast ping sweep for " + $counter + " computers" | out-file -filepath $lfile -append }
            Else {
                New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
            }
        }
        else { $stBar1.text = "No file was selected or action cancelled." }
    }
    
    ################################## 
    #### OPEN FOLDER SIZES FOLDER ####
    ##################################
    Function FolderSizesFolder {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Folder Size")) {
            New-Item "$env:SystemDrive\Admin_Tool\Folder Size" -ItemType Directory -Force
        }
        Invoke-Item "$env:SystemDrive\Admin_Tool\Folder Size"
    }
    
    ####################################
    #### Input Box for Folder Sizes ####
    ####################################
    Function FolderSizeInput {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Destination Input'
        $msg = 'Enter the full file path:
    Example: 
    \\Server\ShareDrive\UnitFolder\WorkCenter
    \\Computer\C$\Users\EDIPI
    C:\Users\EDIPI\Documents
    
    Note: once the action is complete, a grid view
    will popup. Select all the entries (Ctrl+Shift+Click)
    and click OK.'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ####################### Get Folder Sizes ########################
    Function FolderSize {
    
        #### Change Destination ####
        $Dest = FolderSizeInput
    
        $stBar1.text = "Checking location..."
        if (!($Dest -eq "")) {
            If (Test-Path $Dest) {
                if (!(Test-Path "$env:SystemDrive\Admin_Tool\Folder Size")) {
                    New-Item "$env:SystemDrive\Admin_Tool\Folder Size" -ItemType Directory -Force
                }
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                $colItems = Get-ChildItem $Dest -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object -Property FullName
                #$TotSize = Get-ChildItem $Dest -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object sum
                #$TotFiles = Get-ChildItem $Dest -Recurse -Force -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $false}
                $Results = foreach ($Item in $colItems) {
    
                    $subFolderItems = Get-ChildItem $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $false } | Measure-Object -property Length -sum | Select-Object sum
                    $size = "{0:N1}" -f ($subFolderItems.sum / 1MB)
                    $subFileCount = Get-ChildItem $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $false }
                    $subFolderAccess = $Item.LastAccessTime
                    $subFolderWrite = $Item.LastWriteTime
    
                    $h++
                    [int]$pct = ($h / $colItems.count) * 100         #update the progress bar
                    $progress1.Value = $pct
    
                    $stBar1.text = "Processing folder " + $h + " of " + $colItems.count + " --> " + $Item
    
                    $PSObject = New-Object PSObject -Property @{
                        Folder       = [string]$Item.FullName
                        FileCount    = [string]$subFileCount.Count
                        SizeInMBs    = [string]$size
                        LastAccessed = [string]$subFolderAccess
                        LastWritten  = [string]$subFolderWrite
                    }
                    $PSObject | Select-Object Folder, FileCount, SizeInMBs, LastAccessed, LastWritten
                    Start-Sleep -Milliseconds 20
                }
                $stBar1.text = "Generating Report..."
                $Results | Select-Object Folder, FileCount, SizeInMBs, LastAccessed, LastWritten | Out-GridView -Title "Folder sizes for $Dest" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\Folder Size\Folder Size.csv"
                $stBar1.text = "Done getting folder sizes for " + $colItems.count + " folders with path " + $Dest
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Got " + $colItems.count + " folder sizes for " + $Dest | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Can't find location or you don't have rights." }
        }
        else { $stBar1.text = "No input was given or action was cancelled." }
    }
    
    
    ################################ GP UPDATE ##################################
    function Update-GroupPolicy {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Updating Group Policy on " + $computername.ToUpper()
                Invoke-GPUpdate -Computer $computername -RandomDelayInMinutes 0 -AsJob -Target Computer -Force
                Invoke-GPUpdate -Computer $computername -RandomDelayInMinutes 0 -AsJob -Target User -Force
                #   Invoke-Command -ComputerName $computername -ScriptBlock {Start-Process cmd.exe -ArgumentList "gpupdate /force" -Wait}
                $stBar1.text = "Group policy for user & computer has been updated on " + $computername.ToUpper()
        
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran GPUpdate on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                } 
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } #End function Update-GroupPolicy
    
    
    function Invoke-WSUSReport {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                if (Test-Path C:\Windows\System32\wuauclt.exe) {
                    $stBar1.text = "Reporting WSUS on " + $computername.ToUpper()
                    Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process wuauclt.exe -ArgumentList "/reportnow" -Wait }
                    $stBar1.text = "WSUS reporting started on " + $computername.ToUpper()
                }
                Else { $stBar1.text = "Unable to start WSUS reporting on " + $computername.ToUpper() }
        
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran WSUS report on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                } 
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } # End function Invoke-WSUSReport
    
    
    function Invoke-WSUSDetect {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                $stBar1.text = "Checking WSUS on " + $computername.ToUpper()
                If (Test-Path C:\Windows\System32\wuauclt.exe) {
                    Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process wuauclt.exe -ArgumentList "/detectnow" -Wait }
                    $stBar1.text = "WSUS detect started on " + $computername.ToUpper()
                }
                Else { $stBar1.text = "Unable to detect WSUS on " + $computername.ToUpper() }
        
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran WSUS detect on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }  
            }
            else { $stBar1.text = "Could not contact to " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    } # End function Invoke-WSUSReport
    
    ######################### 
    #### OPEN PII FOLDER ####
    #########################
    Function PIIScanFolder {
        # Creates Folders if They Don't Exist #
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\PII Scan")) {
            New-Item "$env:SystemDrive\Admin_Tool\PII Scan" -ItemType Directory -Force
        }
        Invoke-Item "$env:SystemDrive\Admin_Tool\PII Scan"
    }
    
    ####################################
    #### Input Box for PII Scanner ####
    ####################################
    Function PIIInput {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'PII Destination Input'
        $msg = 'This scanner searches for SSNs with
    a format of 123-45-6789, 123 45 6789,
    xxx-xx-6789, xxx xx 6789, 45-6789, 
    45 6789, xx-6789, and xx 6789. Also,
    it searches for words date of birth,
    social security number, and SSN.
    
    Enter the path to scan for PII:
    Example: 
    \\Server\ShareDrive\UnitFolder\WorkCenter
    \\Computer\C$\Users\EDIPI
    C:\Users\EDIPI\Documents
    
    Note: once the action is complete, a grid view
    will popup. Select all the entries (Shift+Click)
    and click OK.'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ####################
    #### PII SCANNER ###
    ####################
    function PII_Scanner {
        $stBar1.text = "Requesting folder to scan for PII..."
        $Dest = PIIInput
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $stBar1.text = "Checking location..."
        if (!($Dest -eq "")) {
            If (Test-Path $Dest) {
                if (!(Test-Path "$env:SystemDrive\Admin_Tool\PII Scan")) {
                    New-Item "$env:SystemDrive\Admin_Tool\PII Scan" -ItemType Directory -Force
                }
    
                $pattern1 = '(\d{3}[-| ]\d{2}[-| ]\d{4})'
                $pattern2 = '([\s](\w{3}[-| ]\w{2}[-| ]\d{4})[\s])'
                $pattern3 = '([\s](\d{2}-\d{4})[\s])'
                $pattern4 = '([\s](\w{2}-\d{4})[\s])'
                $pattern5 = 'date of birth'
                $pattern6 = 'social security number'
                $pattern7 = 'SSN'
                #$pattern5 = '^(?!000)(?!666)(?<SSN3>[0-6]\d{2}|7(?:[0-6]\d|7[012]))([- ]?)(?!00)(?<SSN2>\d\d)\1(?!0000)(?<SSN4>\d{4})$'
                #$pattern6 = '([\s](?!000)(?!666)(?<SSN3>[0-6]\d{2}|7(?:[0-6]\d|7[012]))([- ]?)(?!00)(?<SSN2>\d\d)\1(?!0000)(?<SSN4>\d{4})[\s])'
    
                $Files = Get-ChildItem -Path $Dest -Recurse -Force -Include *.txt, *.doc, *.docx, *.odt, *.html, *.htm, *.xhtml, *.wpd, *.csv, *.zip, *.xps, *.msg, *.pdf, *.bmp, *.xfdl, *.ppt, *.pps, *.pptx, *.xml, *.xls, *.xlsx, *.xlr -ErrorAction SilentlyContinue
                #$stBar1.text = "Scanning " + $Files.count + " files. Please wait..."
                #Start-Sleep -Milliseconds 500
                $output = foreach ($File in $Files) {
    
                    $i++
                    [int]$pct = ($i / $Files.count) * 100         #update the progress bar
                    $progress1.Value = $pct
                    Start-Sleep -Milliseconds 20
    
                    $stBar1.text = "Processing file " + $i + " of " + $Files.count + " --> " + $File.Name
    
                    $File | Select-String -Pattern $pattern1, $pattern2, $pattern3, $pattern4, $pattern5, $pattern6, $pattern7 | Select-Object Path, Line, LineNumber
                }
    
                if ($null -ne $output) {
                    $stBar1.text = "Generating Report..."
                    $output | Out-GridView -Title "PII results for $Dest" -PassThru | Export-Csv -NoTypeInformation -Path "$env:SystemDrive\Admin_Tool\PII Scan\PII Report.csv"
                    $stBar1.text = "Flagged " + $output.count + " entries with PII while scanning " + $Files.count + " files with path " + $Dest
                }
                else { $stBar1.text = "No PII found while scanning " + $Files.count + " files" }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Scanned " + $Files.count + " files for PII with path " + $Dest + " (Flagged " + $output.count + " entries)" | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Can't find location or you don't have rights." }
        }
        else { $stBar1.text = "No input was given or action was cancelled." }
    } # End function Invoke-WSUSReport
    
    ###############################
    #### Input Box for Messengers #
    ###############################
    
    Function MessengerBox {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Messenger'
        $msg = 'Enter a message to send to the remote computer:'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    ##############################################
    
    ##########################
    ##### SEND MESSAGE #######
    ##########################
    Function MessengerText {
        $computername = $txt1.text
        [int]$pct = (0 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (2 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Requesting message input..."
                $msg = MessengerBox
                if ($msg -ne "") {
                    [int]$pct = (3 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                    $stBar1.text = "Sending message to " + $computername.ToUpper()
    
                    Invoke-WmiMethod -Path Win32_Process -Name Create -ComputerName $computername -ArgumentList "c:\windows\system32\msg.exe * $msg"
    
                    if ($? -eq $True) {
                        [int]$pct = (4 / 4) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Sent message to " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (4 / 4) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error: failed to send message to " + $computername.ToUpper()
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Sent message (text): " + $msg + " to " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    $stBar1.text = "No message entered or action cancelled... "
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                }
            }
            else {
                $stBar1.text = "Could not contact to " + $computername.ToUpper()
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t Enter a computer name. No IP addresses."
            [int]$pct = (4 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
        }
        [int]$pct = (4 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    }
    
    ##########################
    ##### SAY MESSAGE ########
    ##########################
    Function MessengerSpeak {
        $computername = $txt1.text
        [int]$pct = (0 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (2 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $stBar1.text = "Requesting message input..."
                $msg = MessengerBox
                if ($msg -ne "") {
                    [int]$pct = (3 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                    $stBar1.text = "Sending message to " + $computername.ToUpper()
    
                    Invoke-Command -ComputerName $computername -ArgumentList $msg -ScriptBlock {
                        Param ($msg)
                        Add-Type -AssemblyName System.Speech
                        $Talk = New-Object System.Speech.Synthesis.SpeechSynthesizer
                        $Talk.Speak($msg)
                    }
    
                    if ($? -eq $True) {
                        [int]$pct = (4 / 4) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Sent message to " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (4 / 4) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Error: failed to send message to " + $computername.ToUpper()
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Sent message (voice): " + $msg + " to " + $computername | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    $stBar1.text = "No message entered or action cancelled... "
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                }
            }
            else {
                $stBar1.text = "Could not contact to " + $computername.ToUpper()
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar}
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t Enter a computer name. No IP addresses."
            [int]$pct = (4 / 4) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
        }
        [int]$pct = (4 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    }
    
    #################################
    ##### View Admin_Tool Logs ######
    #################################
    Function AdminLogs {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $lbl2.visible = $True
        $lbl2.text = ""
        HideUnusedItems
        if (test-path $lfile) { $lbl2.text = (Get-Content -Raw $lfile) }
        Else {
            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
        }
        $Log = Get-Content -Path $lfile
        [array]::Reverse($Log)
        $stBar1.text = "Task logs performed by the Admin_Tool by all users on this computer"
        $lbl2.text = "`t`t`t`t`t Task Logs Performed by Admin_Tool `n`n"
        $lbl2.text += $Log | Out-String
    }
    
    ##########################
    ##### VIEW SETTINGS ######
    ##########################
    Function ViewSettings {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $lbl2.visible = $True
        $lbl2.text = ""
        HideUnusedItems
        AutoOU
        AutoOU2
        AutoOU3
        if ((Get-ADUser $env:username) -or (Get-Module -list ActiveDirectory)) { $RSAT = "Yes" }
        else { $RSAT = "No" }
    
        $lbl2.text = " \#####################################################################################################################/ `n"
        $lbl2.text += "`n`t`t`t`t`t ~ Tested and Built for NIPR Windows 10 ~ `n`n"
        $lbl2.text += "`n`t`t`t`t`t  # Local User Settings (" + $env:username + ") #`n`n"
        $lbl2.text += "- RSAT/ADUC PowerShell module present: " + $RSAT + "`n`n"
        $lbl2.text += "- Version of PowerShell (Need v4 or newer): " + $PSVersionTable.PSVersion + "`n`n`n"
        $lbl2.text += "`t`t`t`t`t`t   # Searcher Settings # `n`n"
        $lbl2.text += "- Your OU: `n"
        $lbl2.text += (Get-ADUser $env:USERNAME.Replace(".adm", "a") -properties * | Select-Object -ExpandProperty DistinguishedName) + "`n`n"
        $lbl2.text += "- MAJCOM OU: `n"
        $lbl2.text += (Get-Content $env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt) + "`n`n"
        $lbl2.text += "- Base OU: `n"
        $lbl2.text += (Get-Content $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt) + "`n`n"
        $lbl2.text += "- Admin OU: `n"
        $lbl2.text += (Get-Content $env:SystemDrive\Admin_Tool\Settings\AdminOU.txt) + "`n`n"
    }
    
    ###########################
    ##### CHANGE SETTINGS #####
    ###########################
    Function MAJCOMOU {
        AutoOU3
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt")) {
            $stBar1.text = "Unable to locate settings file..."
        }
        Else { Notepad.exe $env:SystemDrive\Admin_Tool\Settings\MAJCOMOU.txt }
    }
    Function BaseOU {
        AutoOU
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\BaseOU.txt")) {
            $stBar1.text = "Unable to locate settings file..."
        }
        Else { Notepad.exe $env:SystemDrive\Admin_Tool\Settings\BaseOU.txt }
    }
    Function AdminOU {
        AutoOU2
        if (!(Test-Path "$env:SystemDrive\Admin_Tool\Settings\AdminOU.txt")) {
            $stBar1.text = "Unable to locate settings file..."
        }
        Else { Notepad.exe $env:SystemDrive\Admin_Tool\Settings\AdminOU.txt }
    }
    
    #########################
    #### BITLOCKER STATUS ###
    #########################
    Function BitLockerStatus {
        $lbl2.visible = $True
        $lbl2.text = ""
        [int]$pct = (1 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Getting BitLocker status for " + $computername.ToUpper() + ". Please wait..."
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
    
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $BitLockerStat = Invoke-Command -ComputerName $computername.ToUpper() -ScriptBlock { Get-BitLockerVolume | Select-Object * }
    
                $lbl2.text += "`n`t`t`t`t`t ~ BitLocker Status for " + $computername.ToUpper() + " ~ `n`n`n"
                $lbl2.text += "Computer:`t`t " + [string]$BitLockerStat.ComputerName + "`n"
                $lbl2.text += "Mount Point:`t`t " + [string]$BitLockerStat.MountPoint + "`n"
                $lbl2.text += "Encryption Method:`t " + [string]$BitLockerStat.EncryptionMethod + "`n"
                $lbl2.text += "Auto Unlock Enabled:`t " + [string]$BitLockerStat.AutoUnlockEnabled + "`n"
                $lbl2.text += "Auto Unlock Key Stored:`t " + [string]$BitLockerStat.AutoUnlockKeyStored + "`n"
                $lbl2.text += "Meta Data Version:`t " + [string]$BitLockerStat.MetadataVersion + "`n"
                $lbl2.text += "Volume Status:`t`t " + [string]$BitLockerStat.VolumeStatus + "`n"
                $lbl2.text += "Protection Status:`t " + [string]$BitLockerStat.ProtectionStatus + "`n"
                $lbl2.text += "Lock Status:`t`t " + [string]$BitLockerStat.LockStatus + "`n"
                $lbl2.text += "Encryption Percentage:`t " + [string]$BitLockerStat.EncryptionPercentage + "`n"
                $lbl2.text += "Wipe Percentage:`t " + [string]$BitLockerStat.WipePercentage + "`n"
                $lbl2.text += "Volume Type:`t`t " + [string]$BitLockerStat.VolumeType + "`n"
                $lbl2.text += "Capacity in GB:`t`t " + [string]$BitLockerStat.CapacityGB + "`n"
                $lbl2.text += "Key Protector:`t`t " + [string]$BitLockerStat.KeyProtector + "`n"
                $lbl2.text += "Run Space ID:`t`t " + [string]$BitLockerStat.Runspaceid + "`n"
    
                $stBar1.text = "Done getting BitLocker status for " + $computername.ToUpper()
    
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Got BitLocker status for " + $computername + " with a status of " + [string]$BitLockerStat.ProtectionStatus | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ####################################
    ### DAYS INPUT FOR LOGON ACTIVTY ###
    ####################################
    Function Get-Days {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Logon Activity'
        $msg = 'Enter the number of days to search for logon activity...'
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    
    #######################
    #### LOGON ACTIVITY ###
    #######################
    Function LogonActivity {
        $lbl2.visible = $True
        $lbl2.text = ""
        [int]$pct = (0 / 4) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 4) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Enter the number of days"
                $Days = Get-Days
                if ($Days -ne "") {
                    [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                    $stBar1.text = "Searching event logs on " + $computername.ToUpper() + " for " + $Days + " days of logon activity..."
                    [int]$pct = (2 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $Output = Invoke-Command -ComputerName $Computername -ArgumentList $Days -ScriptBlock {
                        Param($Days)
                        $logs = get-eventlog system -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-$Days)
                        $res = @()
    
                        ForEach ($log in $logs) {
                            if ($log.instanceid -eq 7001) 
                            { $type = "Logon" } 
    
                            Elseif ($log.instanceid -eq 7002)
                            { $type = "Logoff" } 
    
                            Else { Continue } 
    
                            $res += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event" = $type; User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount]) }
                        };
                        $res
                    }
                    [int]$pct = (3 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $lbl2.text = " \#####################################################################################################################/ `n"
                    $lbl2.text += "`n`t`t`t`t`t ~ Logon activity on " + $computername + " for " + $Days + " days ~ `n`n`n"
                    $lbl2.text += $Output | Select-Object User, Time, Event | Out-String
                    $stBar1.text = "Event log search complete on " + $computername.ToUpper()
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched event logs on " + $computername + " for users logged on for " + $Days + " or more days" | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    $stBar1.text = "No days entered or action cancelled..."
                    [int]$pct = (4 / 4) * 100        #set percentage
                    $progress1.Value = $pct
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
                [int]$pct = (4 / 4) * 100        #set percentage
                $progress1.Value = $pct 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #######################
    #### EVENT ACTIVITY ###
    #######################
    Function EventActivity {
        $lbl2.visible = $True
        $lbl2.text = ""
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $stBar1.text = "Getting event activity from " + $computername.ToUpper()
                Start-Sleep 1
    
                $Output = (Get-WinEvent -ComputerName $computername -ListProvider "Microsoft-Windows-Security-Auditing").Events | Select-Object @{Name = 'Id'; Expression = { $_.Id -band 0xffffff } }, Description
    
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $lbl2.text = " \#####################################################################################################################/ `n"
                $lbl2.text += "`n`t`t`t`t`t ~ Event activity for " + $computername + " ~"
                $lbl2.text += $Output | Select-Object Id, Description | Out-String
                $stBar1.text = "Event log search complete on " + $computername.ToUpper()
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched event activity on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ##################################
    ### Input box for module import ###
    ##################################
    Function ModInput {
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    
        $title = 'Input Info...'
        $msg = '
    
    Enter a computer name that has RSAT installed. '
    
        $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
        $text
    }
    
    ##############################
    ### Remotely Import Module ###
    ##############################
    Function ImportModule {
        [int]$pct = (0 / 8) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
    
        $stBar1.text = "Checking RSAT/AD status..."
        if (!(Get-Module -list ActiveDirectory)) {
    
            $stBar1.text = "Input computer name that has RSAT installed..."
            $computer = ModInput
    
            [int]$pct = (1 / 8) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
    
            if (!($computer -like "")) {
                [int]$pct = (2 / 8) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Pinging computer " + $computer.ToUpper()
                if (test-connection $computer -quiet -count 1 -ErrorAction SilentlyContinue) {
                    [int]$pct = (3 / 8) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Creating PSSession with " + $computer.ToUpper()
                    [int]$pct = (4 / 8) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
    
                    if (Test-Path "$env:SystemDrive\Admin_Tool\AD_Module") {
                        [int]$pct = (5 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        Remove-Item -Path "$env:SystemDrive\Admin_Tool\AD_Module" -Force -Recurse
                        New-Item -Path "$env:SystemDrive\Admin_Tool\AD_Module" -ItemType Directory -Force
                    }
                    else { New-Item -Path "$env:SystemDrive\Admin_Tool\AD_Module" -ItemType Directory -Force }
    
                    if ((Test-Path -Path "\\$computer\C$\Windows\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory") -and (Test-Path -Path "\\$computer\C$\Windows\Microsoft.NET\assembly\GAC_64\Microsoft.ActiveDirectory.Management")) {
                        [int]$pct = (6 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Copying Active Directory .DLL file from " + $computer.ToUpper()
                        Copy-Item -Recurse -Path "\\$computer\C$\Windows\Microsoft.NET\assembly\GAC_64\Microsoft.ActiveDirectory.Management\*.dll" -Destination "$env:SystemDrive\Admin_Tool\AD_Module" -Force -ErrorAction SilentlyContinue
                        Copy-Item -Recurse -Path "\\$computer\C$\Windows\Microsoft.NET\assembly\GAC_64\Microsoft.ActiveDirectory.Management\*\*.dll" -Destination "$env:SystemDrive\Admin_Tool\AD_Module" -Force -ErrorAction SilentlyContinue
                        $stBar1.text = "Copying Active Directory module from " + $computer.ToUpper()
                        Copy-Item -Recurse -Path "\\$computer\C$\Windows\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory" -Destination "$env:SystemDrive\Admin_Tool\AD_Module" -Force -ErrorAction SilentlyContinue
                        [int]$pct = (7 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Importing AD module... (Please wait)"
                        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\*.dll -ErrorAction SilentlyContinue
                        Start-Sleep 1
                        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\ActiveDirectory\*.psd1 -ErrorAction SilentlyContinue
                        Start-Sleep 1
                        [int]$pct = (8 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (Get-ADUser $env:username) {
                            $stBar1.text = "Import successful..."
                            $vbmsg.popup("AD module was successfully imported from $computer.", 0, "Information", 0)
                        }
                        else {
                            $stBar1.text = "Import failed..."
                            $vbmsg.popup("AD module was NOT successfully imported from $computer.", 0, "Error", 0)
                        }
                    }
                    elseif (Test-Path -Path "$computer\C$\Admin_Tool\AD_Module\") {
                        [int]$pct = (6 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Copying Active Directory .DLL file from " + $computer.ToUpper()
                        Copy-Item -Recurse -Path "$computer\C$\Admin_Tool\AD_Module" -Destination "$env:SystemDrive\Admin_Tool" -Force
                        [int]$pct = (7 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Importing AD module... (Please wait)"
                        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\*.dll
                        Start-Sleep 1
                        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\ActiveDirectory\*.psd1
                        Start-Sleep 1
                        [int]$pct = (8 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        if (Get-ADUser $env:username) {
                            $stBar1.text = "Import successful..."
                            $vbmsg.popup("AD module was successfully imported from $computer.", 0, "Information", 0)
                        }
                        else {
                            $stBar1.text = "Import failed..."
                            $vbmsg.popup("AD module was NOT successfully imported from $computer.", 0, "Error", 0)
                        }
                        
                    }
                    else {
                        [int]$pct = (8 / 8) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "Unable to find AD .DLL file and module on " + $computer.ToUpper()
                        $vbmsg1 = $vbmsg.popup("Unable to find the Active Directory .DLL file and module on $computer. Try another computer or install RSAT.", 0, "Info", 0)
                    }
    
                    if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Imported AD modules from " + $computer | out-file -filepath $lfile -append }
                    Else {
                        New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                        "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                    }
                }
                else {
                    [int]$pct = (8 / 8) * 100        #set percentage
                    $progress1.Value = $pct        #update the progress bar
                    $stBar1.text = "Can't ping " + $computer.ToUpper()
                    $vbmsg.popup("Unable to ping $computer.", 0, "Error", 0)
                }
            }
            else {
                [int]$pct = (8 / 8) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "No computer name entered or action cancelled."
                $vbmsg.popup("No computer name entered or action cancelled.", 0, "Error", 0)
            }
        }
        else {
            [int]$pct = (8 / 8) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $vbmsg.popup("Your computer is reporting that you already have the AD module installed.", 0, "Error", 0)
            $stBar1.text = "Your computer is saying it already has RSAT/AD module..."
        }
    }
    
    
    #####################
    #### PII ACTIVITY ###
    #####################
    Function PIIActivity {
        $lbl2.visible = $True
        $lbl2.text = ""
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        HideUnusedItems
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                [int]$pct = (1 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $stBar1.text = "Getting DSet info from " + $computername.ToUpper()
                Start-Sleep 1
    
                $Output = Get-EventLog -ComputerName $computername -LogName DSETAddIn -EntryType Warning -ErrorAction SilentlyContinue
    
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                $lbl2.text = " \#####################################################################################################################/ `n"
                $lbl2.text += "`n`t`t`t`t`t ~ DSet activity for " + $computername + " ~"
                $lbl2.text += $Output | Select-Object TimeWritten, Message | Out-String
                $stBar1.text = "DSet log search complete on " + $computername.ToUpper()
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Searched for PII activity on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct 
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ######################
    ## ClearPrint Queue ##
    ######################
    function ClearPQ {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (1 / 5) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Stopping Print Spooler"
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process Net -ArgumentList "Stop Spooler" -Wait }
                [int]$pct = (2 / 5) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Deleting All .sdh Files in the Printers Folder (Don't worry, they'll be recreated!)"
                Invoke-Command -ComputerName $computername -ScriptBlock { Remove-Item $env:SystemRoot\system32\spool\printers\*.shd }
                [int]$pct = (3 / 5) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Deleting All .spl Files in the Printers Folder"
                Invoke-Command -ComputerName $computername -ScriptBlock { Remove-Item $env:SystemRoot\system32\spool\printers\*.spl }
                [int]$pct = (4 / 5) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Starting the Print Spooler"
                Invoke-Command -ComputerName $computername -ScriptBlock { Start-Process Net -ArgumentList "Start Spooler" -Wait }
                $stBar1.text = "Print queue has been cleared on " + $computername.ToUpper()
                [int]$pct = (5 / 5) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Cleared print queue on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else {
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    #######################
    ## List Local Users  ##
    #######################
    function LocalUsers {
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        [int]$pct = (0 / 1) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        if ($txt1.text -eq "." -OR $txt1.text -eq "localhost") { $txt1.text = hostname }
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            ClearGrid
            HideUnusedItems
            $list11.visible = $true
            $lbl2.Visible = $false
            $stBar1.text = "Pinging " + $computername.ToUpper()
    
            if (test-connection $computername -quiet -count 1) {
    
                $list11.Columns[0].text = "User"
                $list11.Columns[0].width = 150
                $list11.Columns[1].text = "Description"
                $list11.Columns[1].width = 150
                $list11.Columns[2].text = "Enabled"
                $list11.Columns[2].width = 150
                $list11.Columns[3].text = "PwdLastSet"
                $list11.Columns[3].width = 150
                $list11.Columns[4].text = "SID"
                $list11.Columns[4].width = 150
    
                $systeminfoerror = $null
    
                $stBar1.text = "Getting local users on " + $computername + "..."
                $Users = Invoke-Command -ComputerName $computername -ScriptBlock { Get-LocalUser } -ErrorVariable systeminfoerror
    
                if (!($systeminfoerror)) {
                    $AllInfo = foreach ($Us in $Users) {
    
                        $i++
                        [int]$pct = ($i / $Users.Count) * 100
                        #update the progress bar
                        $progress1.Value = $pct
            
                        $PSObject = New-Object PSObject -Property @{
                            User        = $Us.Name | Out-String
                            Description = $Us.Description | Out-String
                            Enabled     = $Us.Enabled | Out-String
                            PwdLastSet  = $Us.PasswordLastSet | Out-String
                            SID         = $Us.SID | Out-String
                        }
                        $PSObject | Select-Object User, Description, Enabled, PwdLastSet, SID | Sort-Object User
                    }
    
                    $columnproperties = "User", "Description", "Enabled", "PwdLastSet", "SID"
                    foreach ($d in $AllInfo) {
    
                        $text = ""
                        $item = new-object System.Windows.Forms.ListViewItem($d.User)
    
                        if ($null -eq $d.Description) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Description) }
        
                        if ($null -eq $d.Enabled) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.Enabled) }
    
                        if ($null -eq $d.PwdLastSet) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.PwdLastSet) }
    
                        if ($null -eq $d.SID) {
                            $item.SubItems.Add($text)
                        }
                        Else { $item.SubItems.Add($d.SID) }
    
                        $item.Tag = $d
                        $list11.Items.Add($item) > $null
                    }
    
                    $stBar1.text = "Local users on " + $computername.ToUpper() + " (" + $Users.count + ")"
                    $btn26.Visible = $true
                    $btn25.Visible = $true
                }
                else { $stBar1.text = "There was a problem getting local users from " + $computername.ToUpper() }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Ran local user query on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }
            }
            else { $stBar1.text = "Could not contact " + $computername.ToUpper() }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    ##################################
    ## Reset a Local Users Password ##
    ##################################
    $btn25_OnClick = 
    {
        [int]$pct = (0 / 6) * 100
        $progress1.Value = $pct #update the progress bar
    
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($list11.selecteditems.count -gt 1)) {
            if (!($list11.selecteditems.count -lt 1)) {
                if (!($computername -like "*.*.*.*")) {
    
                    [int]$pct = (2 / 6) * 100
                    $progress1.Value = $pct #update the progress bar
    
                    $stBar1.text = "Pinging " + $computername.ToUpper()
                    if (Test-Connection $Computername -quiet -count 1) {
                        [int]$pct = (3 / 6) * 100
                        $progress1.Value = $pct #update the progress bar
    
                        $exprString2 = '$list11.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.User}'
                        $user = invoke-expression $exprString2
                        $username = $user.Trim()
    
                        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                        $stBar1.text = "Loading " + $username + "'s settings on " + $computername + "..."
    
                        [int]$pct = (4 / 6) * 100
                        $progress1.Value = $pct #update the progress bar
    
                        If (!($username -eq "")) {
                            $stBar1.text = "Enter new password..."
                            $password = Read-Host -Prompt "Enter a new password." -AsSecureString -ErrorAction SilentlyContinue
                            if ($null -ne $password) {
                                $decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
                                [int]$pct = (5 / 6) * 100
                                $progress1.Value = $pct #update the progress bar
        
                                $stBar1.text = "Resetting " + $username + "'s Password on " + $computername.ToUpper()
        ([adsi]"WinNT://$computername/$username,user").SetPassword($decodedpassword)
        
                                if ($? -eq $True) {
                                    $stBar1.text = "Password reset complete for " + $username + " on " + $computername.ToUpper()
    
                                    [int]$pct = (6 / 6) * 100
                                    $progress1.Value = $pct #update the progress bar
                                }
                                else {
                                    $stBar1.text = "Error: issue resetting password for " + $username
                                    [int]$pct = (6 / 6) * 100
                                    $progress1.Value = $pct #update the progress bar
                                }
                            }
                            else { $stBar1.text = "No password entered or action cancelled..." }
                        }
                        Else {
                            $stBar1.text = "Can't find user " + $username
                            [int]$pct = (6 / 6) * 100
                            $progress1.Value = $pct #update the progress bar
                        }
    
                        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Reset password for local account " + $username + " on " + $computername | out-file -filepath $lfile -append }
                        Else {
                            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                        }
    
                    }
                    else {
                        $stBar1.text = "Could not contact " + $computername.ToUpper()
                        [int]$pct = (6 / 6) * 100
                        $progress1.Value = $pct #update the progress bar
                    }
                }
                Else {
                    $lbl2.visible = $true
                    $list1.visible = $false
                    $lbl2.text = ""
                    $stBar1.text = "Enter a computer name. No IP addresses."
                    $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
                    [int]$pct = (1 / 5) * 100
                    $progress1.Value = $pct #update the progress bar
                }
            }
            else { $vbmsg1 = $vbmsg.popup("Please select an account to reset.", 0, "Error", 0) }
        }
        else { $vbmsg1 = $vbmsg.popup("You may only select one at time for password resets.", 0, "Error", 0) }
    } #End function reset password
    
    ##########################
    ## Unlocks a Local User ##
    ##########################
    $btn26_OnClick = 
    {
        [int]$pct = (0 / 3) * 100
        $progress1.Value = $pct #update the progress bar
    
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        $computername = $txt1.text
        if (!($list11.selecteditems.count -gt 1)) {
            if (!($list11.selecteditems.count -lt 1)) {
                if (!($computername -like "*.*.*.*")) {
                    $stBar1.text = "Pinging " + $computername.ToUpper()
                    if (Test-Connection $Computername -quiet -count 1) {
                        [int]$pct = (1 / 3) * 100
                        $progress1.Value = $pct #update the progress bar
    
                        $exprString2 = '$list11.SelectedItems | foreach-object {$_.tag} | foreach-object {$_.User}'
                        $user = invoke-expression $exprString2
                        $username = $user.Trim()
    
                        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
                        $stBar1.text = "Loading " + $username + "'s settings on " + $computername + "..."
    
                        [int]$pct = (2 / 3) * 100
                        $progress1.Value = $pct #update the progress bar
    
                        If ($null -ne $username) {
                            $stBar1.text = "Enabling user " + $username + " on " + $computername.ToUpper()
                            Invoke-Command -ComputerName $computername -ArgumentList $username -ScriptBlock { Param($username); Enable-LocalUser -Name $username }
                            if ($? -eq $True) {
                                $stBar1.text = "User " + $username + " is now enabled..."
                                [int]$pct = (3 / 3) * 100
                                $progress1.Value = $pct #update the progress bar
                            }
                            else {
                                $stBar1.text = "Error: issue enableing user " + $username
                                [int]$pct = (3 / 3) * 100
                                $progress1.Value = $pct #update the progress bar
                            }
                        }
                        Else {
                            $stBar1.text = "Error: unable to find user " + $username
                            [int]$pct = (3 / 3) * 100
                            $progress1.Value = $pct #update the progress bar
                        }
                        if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Enabled local account " + $username + " on " + $computername | out-file -filepath $lfile -append }
                        Else {
                            New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                            "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                        }
                    }
                    else {
                        $stBar1.text = "Could not contact " + $computername.ToUpper()
                        [int]$pct = (3 / 3) * 100
                        $progress1.Value = $pct #update the progress bar
                    }
                }
                Else {
                    $lbl2.visible = $true
                    $list1.visible = $false
                    $lbl2.text = ""
                    $stBar1.text = "Enter a computer name. No IP addresses."
                    $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
                    [int]$pct = (3 / 3) * 100
                    $progress1.Value = $pct #update the progress bar
                }
            }
            else { $vbmsg1 = $vbmsg.popup("Please select a profile to enable.", 0, "Error", 0) }
        }
        else { $vbmsg1 = $vbmsg.popup("You may only select one to enable at a time.", 0, "Error", 0) }
    } #End function enable user
    
    ############################
    ## Update McAfee Dat File ##
    ############################
    
    function Update-McAfeeDAT {
        [int]$pct = (0 / 3) * 100        #set percentage
        $progress1.Value = $pct        #update the progress bar
        [System.Windows.Forms.Cursor]::Current = 'WaitCursor'
        HideUnusedItems
        $lbl2.visible = $True
        $computername = $txt1.text
        if (!($computername -like "*.*.*.*")) {
            [int]$pct = (1 / 3) * 100        #set percentage
            $progress1.Value = $pct        #update the progress bar
            $stBar1.text = "Pinging " + $computername.ToUpper()
            if (Test-Connection $Computername -quiet -count 1) {
                [int]$pct = (2 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Contacting McAfee ePO server for " + $computername.ToUpper()
                $Path32 = "\\$Computername\C$\Program Files (x86)\McAfee\VirusScan Enterprise\MCUpdat*.exe"
                $Path64 = "\\$Computername\C$\Program Files\McAfee\Agent\MCUpdat*.exe"
            
                If (Test-Path $Path32) {
                    $Result = Invoke-Command -ComputerName $computername -ScriptBlock { $Output = Start-Process "C:\Program Files (x86)\McAfee\VirusScan Enterprise\MCUpdat*.exe" -ArgumentList "/update /quiet" -Wait -PassThru
                        $Output.ExitCode } -ErrorAction SilentlyContinue
                    Start-Sleep 2
                    $Result1 = Invoke-Command -ComputerName $computername -ScriptBlock { $Output1 = Start-Process "C:\Program Files\McAfee\Endpoint Security\Threat Prevention\amcfg.exe" -ArgumentList "/update" -Wait -PassThru
                        $Output1.ExitCode } -ErrorAction SilentlyContinue
    
                    if (($? -eq $True) -and ($result1 -eq 0) -and ($Result -eq 0)) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "McAfee DAT update started on " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue updating the DAT file on " + $computername.ToUpper()
                    }
                }
                Elseif (Test-Path $Path64) {
                    $Result = Invoke-Command -ComputerName $computername -ScriptBlock { $Output = Start-Process "C:\Program Files\McAfee\Agent\MCUpdat*.exe" -ArgumentList "/update /quiet" -Wait -PassThru
                        $Output.Exitcode } -ErrorAction SilentlyContinue
                    Start-Sleep 2
                    $Result1 = Invoke-Command -ComputerName $computername -ScriptBlock { $Output1 = Start-Process "C:\Program Files\McAfee\Endpoint Security\Threat Prevention\amcfg.exe" -ArgumentList "/update" -Wait -PassThru
                        $Output1.ExitCode } -ErrorAction SilentlyContinue
    
                    if (($? -eq $True) -and ($result1 -eq 0) -and ($Result -eq 0)) {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "McAfee DAT update started on " + $computername.ToUpper()
                    }
                    else {
                        [int]$pct = (3 / 3) * 100        #set percentage
                        $progress1.Value = $pct        #update the progress bar
                        $stBar1.text = "There was an issue updating the DAT file on " + $computername.ToUpper()
                    }
                }
                else { $stBar1.text = "Unable to locate the needed McAfee files to invoke the update on " + $computername.ToUpper() }
    
                if (test-path $lfile) { (get-date -uformat "%Y-%m-%d-%H:%M") + ": " + $user + " - " + "Updated McAfee DAT file on " + $computername | out-file -filepath $lfile -append }
                Else {
                    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
                    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | out-file -filepath $lfile
                }    
            }
            else {
                [int]$pct = (3 / 3) * 100        #set percentage
                $progress1.Value = $pct        #update the progress bar
                $stBar1.text = "Could not contact " + $computername.ToUpper()
            }
        }
        Else {
            $lbl2.visible = $true
            $list1.visible = $false
            $lbl2.text = ""
            $stBar1.text = "Enter a computer name. No IP addresses."
            $lbl2.text += "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`t`t`t`t`t Enter a computer name. No IP addresses."
        }
    }
    
    function About {
        $lbl2.visible = $True
        $lbl2.text = ""
        HideUnusedItems
        $stBar1.text = "About This Program"
        $lbl2.text = "`n`n`n`n`n"
        $lbl2.text += "`t`t`t`t`t ######################################## " + "`n"
        $lbl2.text += "`t`t`t`t`t So Easy... Even an Lt. Can Use it! " + "`n"
        $lbl2.text += "`t`t`t`t`t --------------------------------------------------------------- " + "`n"
        $lbl2.text += "`t`t`t`t`t Original Author: Rich Prescott " + "`n"
        $lbl2.text += "`t`t`t`t`t Heavily Modified By: MSgt Skyler Hunter " + "`n"
        $lbl2.text += "`t`t`t`t`t Contributors: SSgt Stilianos Daskalakis " + "`n"
        $lbl2.text += "`t`t`t`t`t --------------------------------------------------------------- " + "`n"
        $lbl2.text += "`t`t`t`t`t Designed to ease administration and " + "`n"
        $lbl2.text += "`t`t`t`t`t streamline fix actions. " + "`n"
        $lbl2.text += "`t`t`t`t`t --------------------------------------------------------------- " + "`n"
        $lbl2.text += "`t`t`t`t`t This script/program comes with no warranty " + "`n"
        $lbl2.text += "`t`t`t`t`t and is used at the operators own discretion." + "`n"
        $lbl2.text += "`t`t`t`t`t Any miss use or damage that may occur to any" + "`n"
        $lbl2.text += "`t`t`t`t`t system, network equipment, or user/profile" + "`n"
        $lbl2.text += "`t`t`t`t`t will not be held accountable by the creator" + "`n"
        $lbl2.text += "`t`t`t`t`t or maintainer of this script and it's tools." + "`n"
        $lbl2.text += "`t`t`t`t`t`t         Click Responsibly!" + "`n"
        $lbl2.text += "`t`t`t`t`t --------------------------------------------------------------- " + "`n"
        $lbl2.text += "`t`t`t`t`t Requires Remote Server Administration Tools (RSAT) " + "`n"
        $lbl2.text += "`t`t`t`t`t from Microsoft in order to use the AD Modules. " + "`n"
        $lbl2.text += "`t`t`t`t`t ######################################## " + "`n"
        $stBar1.text = "Ready"
    }
    
    $OnLoadForm_StateCorrection =
    {
        $form1.WindowState = $InitialFormWindowState #Correct the initial state of the form to prevent the .Net maximized form issue
    }
    
    #----------------------------------------------
    #region Generated Form Code
    $form1 = New-Object System.Windows.Forms.Form
    Update-FormTitle
    $form1.Name = "form1"
    $form1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.BackColor = [System.Drawing.Color]::SlateGray
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 750
    $System_Drawing_Size.Height = 621
    $form1.ClientSize = $System_Drawing_Size
    $form1.StartPosition = "CenterScreen"
    $Form1.KeyPreview = $True
    $Form1.Add_KeyDown({ if ($_.KeyCode -eq "Escape") 
            { $Form1.Close() } })
    
    # Menu Strip #
    $MenuStrip = new-object System.Windows.Forms.MenuStrip
    $MenuStrip.backcolor = "ControlLight"
    $FileMenu = new-object System.Windows.Forms.ToolStripMenuItem("&File")
    $CSTMenu = new-object System.Windows.Forms.ToolStripMenuItem("CST")
    $NetOpsMenu = new-object System.Windows.Forms.ToolStripMenuItem("NetOps")
    $MDT = new-object System.Windows.Forms.ToolStripMenuItem("MDT")
    $SettingsMenu = new-object System.Windows.Forms.ToolStripMenuItem("Settings")
    
    if (!(IsAdmin)) {
        $CSTMenu.Enabled = $False
    }
    else { $CSTMenu.Enabled = $True }
    
    if (!(IsAdmin)) {
        $NetOpsMenu.Enabled = $False
    }
    else { $NetOpsMenu.Enabled = $True }
    
    if (!(IsAdmin)) {
        $MDT.Enabled = $False
    }
    else { $NetOpsMenu.Enabled = $True }
    
    $FileExit = new-object System.Windows.Forms.ToolStripMenuItem("E&xit")
    $FileExit.add_Click({ $form1.close() })
    $FileMenu.DropDownItems.Add($FileExit) > $null
    
    $About = new-object System.Windows.Forms.ToolStripMenuItem("About")
    $About.add_Click({ About })
    $FileMenu.DropdownItems.Add($About) > $null
    
    $WSUSMenu = new-object System.Windows.Forms.ToolStripMenuItem("&WSUS")
    $NetOpsMenu.DropdownItems.Add($WSUSMenu) > $null
        
    $WSUSReport = new-object System.Windows.Forms.ToolStripMenuItem("Logs")
    $WSUSReport.add_Click({ WSUSLogs })
    $WSUSMenu.DropDownItems.Add($WSUSReport) > $null
    
    $QFixSUSDetect = new-object System.Windows.Forms.ToolStripMenuItem("Detect Server")
    $QFixSUSDetect.add_Click({ Invoke-WSUSDetect })
    $WSUSMenu.DropdownItems.Add($QFixSUSDetect) > $null
    
    $QFixSUSReport = new-object System.Windows.Forms.ToolStripMenuItem("Report to Server")
    $QFixSUSReport.add_Click({ Invoke-WSUSReport })
    $WSUSMenu.DropdownItems.Add($QFixSUSReport) > $null
    
    <#     YOU FOUND ME! UNCOMMENT TO ENABLE THE 'RUN-AS' TOOL
    
    $RunAs = new-object System.Windows.Forms.ToolStripMenuItem("Apply 'Run As' Fix")
    $CSTMenu.DropdownItems.Add($RunAs) > $null
    
        $RunAsRemote = new-object System.Windows.Forms.ToolStripMenuItem("Remote PC")
        $RunAsRemote.add_Click({RunAsRemote})
        $RunAs.DropDownItems.Add($RunAsRemote) > $null
        
        $RunAsLocal = new-object System.Windows.Forms.ToolStripMenuItem("This PC ($env:computername)")
        $RunAsLocal.add_Click({RunAsLocal})
        $RunAs.DropDownItems.Add($RunAsLocal) > $null
    #>
    
    $PShell = new-object System.Windows.Forms.ToolStripMenuItem("Open Powershell as Admin")
    $CSTMenu.DropdownItems.Add($PShell) > $null
        
    $PShellRemote = new-object System.Windows.Forms.ToolStripMenuItem("Remote PC")
    $PShellRemote.add_Click({ PShellRemote })
    $PShell.DropDownItems.Add($PShellRemote) > $null
        
    $PShellLocal = new-object System.Windows.Forms.ToolStripMenuItem("This PC ($env:computername)")
    $PShellLocal.add_Click({ PShellLocal })
    $PShell.DropDownItems.Add($PShellLocal) > $null
    
    $Printers = new-object System.Windows.Forms.ToolStripMenuItem("Printer Stuff")
    $CSTMenu.DropdownItems.Add($Printers) > $null
    
    $PrinterStat = new-object System.Windows.Forms.ToolStripMenuItem("List Printers")
    $PrinterStat.add_Click({ PrinterStat })
    $Printers.DropdownItems.Add($PrinterStat) > $null
    
    $ClearPQ = new-object System.Windows.Forms.ToolStripMenuItem("Clear Print Queue")
    $ClearPQ.add_Click({ ClearPQ })
    $Printers.DropdownItems.Add($ClearPQ) > $null
    
    $PrintMan = new-object System.Windows.Forms.ToolStripMenuItem("Printer Management")
    $PrintMan.add_Click({ PrintMan })
    $Printers.DropdownItems.Add($PrintMan) > $null
    
    $Messenger = new-object System.Windows.Forms.ToolStripMenuItem("Send Message")
    $CSTMenu.DropdownItems.Add($Messenger) > $null
    
    $MessengerText = new-object System.Windows.Forms.ToolStripMenuItem("Text Message")
    $MessengerText.add_Click({ MessengerText })
    $Messenger.DropdownItems.Add($MessengerText) > $null
    
    $MessengerSpeak = new-object System.Windows.Forms.ToolStripMenuItem("Say Message")
    $MessengerSpeak.add_Click({ MessengerSpeak })
    $Messenger.DropdownItems.Add($MessengerSpeak) > $null
    
    $UserProfile = new-object System.Windows.Forms.ToolStripMenuItem("User Profile Management")
    $CSTMenu.DropdownItems.Add($UserProfile) > $null
    
    $ProUser = new-object System.Windows.Forms.ToolStripMenuItem("List and Remove User Profiles")
    $ProUser.add_Click({ ProRemoveUser })
    $UserProfile.DropdownItems.Add($ProUser) > $null
        
    $ProRemove = new-object System.Windows.Forms.ToolStripMenuItem("Remove Profiles by # of Days")
    $ProRemove.add_Click({ ProRemoveDate })
    $UserProfile.DropdownItems.Add($ProRemove) > $null
    
    $Locals = new-object System.Windows.Forms.ToolStripMenuItem("Local Users")
    $CSTMenu.DropdownItems.Add($Locals) > $null
    
    $LocalQuick = new-object System.Windows.Forms.ToolStripMenuItem("Local Users - Quick View")
    $LocalQuick.add_Click({ LocalUsers })
    $Locals.DropdownItems.Add($LocalQuick) > $null
        
    $LocalCon = new-object System.Windows.Forms.ToolStripMenuItem("Local Users/Group Console")
    $LocalCon.add_Click({ UsersGroups })
    $Locals.DropdownItems.Add($LocalCon) > $null
    
    $GroupP = new-object System.Windows.Forms.ToolStripMenuItem("Group Policy")
    $NetOpsMenu.DropdownItems.Add($GroupP) > $null
        
    $QFixGPUpdate = new-object System.Windows.Forms.ToolStripMenuItem("Group Policy Update")
    $QFixGPUpdate.add_Click({ Update-GroupPolicy })
    $GroupP.DropdownItems.Add($QFixGPUpdate) > $null
    
    $GPEdit = new-object System.Windows.Forms.ToolStripMenuItem("Group Policy Edit")
    $GPEdit.add_Click({ GPEDIT })
    $GroupP.DropdownItems.Add($GPEdit) > $null
    
    $GPResult = new-object System.Windows.Forms.ToolStripMenuItem("Group Policy Result/Report")
    $GroupP.DropdownItems.Add($GPResult) > $null
    
    $GPRun = new-object System.Windows.Forms.ToolStripMenuItem("Run GPResult")
    $GPRun.add_Click({ GPRESULT })
    $GPResult.DropdownItems.Add($GPRun) > $null
    
    $GPReport = new-object System.Windows.Forms.ToolStripMenuItem("View GPResult Reports")
    $GPReport.add_Click({ GPREPORT })
    $GPResult.DropdownItems.Add($GPReport) > $null
    
    $SCCM = new-object System.Windows.Forms.ToolStripMenuItem("SCCM")
    $NetOpsMenu.DropdownItems.Add($SCCM) > $null
        
    $SCCMRepair = new-object System.Windows.Forms.ToolStripMenuItem("SCCM - Repair")
    $SCCMRepair.add_Click({ SCCMRepair })
    $SCCM.DropdownItems.Add($SCCMRepair) > $null
        
    $SCCMAuto = new-object System.Windows.Forms.ToolStripMenuItem("SCCM - Start Service")
    $SCCMAuto.add_Click({ SCCMAuto })
    $SCCM.DropDownItems.Add($SCCMAuto) > $null
    
    $SCCMInst = new-object System.Windows.Forms.ToolStripMenuItem("SCCM - Install (Experimental)")
    $SCCMInst.add_Click({ SCCMInstall })
    $SCCM.DropDownItems.Add($SCCMInst) > $null
    
    $SCCMUnin = new-object System.Windows.Forms.ToolStripMenuItem("SCCM - Uninstall (x64 Only)")
    $SCCMUnin.add_Click({ SCCMUnin })
    $SCCM.DropDownItems.Add($SCCMUnin) > $null
    
    $Searcher = new-object System.Windows.Forms.ToolStripMenuItem("Searcher")
    $NetOpsMenu.DropdownItems.Add($Searcher) > $null
        
    $OUList = new-object System.Windows.Forms.ToolStripMenuItem("List MAJCOM OUs")
    $OUList.add_Click({ OUList })
    $Searcher.DropdownItems.Add($OUList) > $null
    
    $UserList = new-object System.Windows.Forms.ToolStripMenuItem("List Users in Base OU")
    $UserList.add_Click({ UserOUList })
    $Searcher.DropdownItems.Add($UserList) > $null
    
    $PCList = new-object System.Windows.Forms.ToolStripMenuItem("List PCs in Base OU")
    $PCList.add_Click({ PCOUList })
    $Searcher.DropdownItems.Add($PCList) > $null
    
    $SecGP = new-object System.Windows.Forms.ToolStripMenuItem("List Users in Sec Grp")
    $SecGP.add_Click({ UserSecList })
    $Searcher.DropdownItems.Add($SecGP) > $null
    
    $OrgMbr = new-object System.Windows.Forms.ToolStripMenuItem("List PCs in Sec Grp")
    $OrgMbr.add_Click({ PCSecList })
    $Searcher.DropdownItems.Add($OrgMbr) > $null
    
    $StalePC = new-object System.Windows.Forms.ToolStripMenuItem("List Stale PCs in Base OU")
    $StalePC.add_Click({ StaleComputers })
    $Searcher.DropdownItems.Add($StalePC) > $null
    
    $UserSearch = new-object System.Windows.Forms.ToolStripMenuItem("Search Users")
    $Searcher.DropdownItems.Add($UserSearch) > $null
    
    $LastSearch = new-object System.Windows.Forms.ToolStripMenuItem("Search by 'Last, First M Rank...'")
    $LastSearch.add_Click({ UserSearchList })
    $UserSearch.DropdownItems.Add($LastSearch) > $null
    
    $UnitOrgSearch = new-object System.Windows.Forms.ToolStripMenuItem("Search by Unit and Office Sym")
    $UnitOrgSearch.add_Click({ OrgnOffice })
    $UserSearch.DropdownItems.Add($UnitOrgSearch) > $null
    
    $DSNSearch = new-object System.Windows.Forms.ToolStripMenuItem("Search by DSN")
    $DSNSearch.add_Click({ PhoneList })
    $UserSearch.DropdownItems.Add($DSNSearch) > $null
    
    $TitleSearch = new-object System.Windows.Forms.ToolStripMenuItem("Search by Duty Title")
    $TitleSearch.add_Click({ TitleList })
    $UserSearch.DropdownItems.Add($TitleSearch) > $null
    
    $DisUsers = new-object System.Windows.Forms.ToolStripMenuItem("List Disabled Base Users")
    $DisUsers.add_Click({ DisabledUsers })
    $UserSearch.DropdownItems.Add($DisUsers) > $null
    
    $StaleUsers = new-object System.Windows.Forms.ToolStripMenuItem("List Stale Base Users")
    $StaleUsers.add_Click({ StaleUsers })
    $UserSearch.DropdownItems.Add($StaleUsers) > $null
    
    $AdminUsers = new-object System.Windows.Forms.ToolStripMenuItem("List Base Admin Users")
    $AdminUsers.add_Click({ AdminUsers })
    $UserSearch.DropdownItems.Add($AdminUsers) > $null
    
    $SearchReport = new-object System.Windows.Forms.ToolStripMenuItem("Searcher Reports")
    $SearchReport.add_Click({ SearchReport })
    $Searcher.DropdownItems.Add($SearchReport) > $null
    
    $PingSweep = new-object System.Windows.Forms.ToolStripMenuItem("Ping Sweep")
    $NetOpsMenu.DropdownItems.Add($PingSweep) > $null
    
    $NetScanner = new-object System.Windows.Forms.ToolStripMenuItem("Ping IP Range")
    $NetScanner.add_Click({ NetScanner })
    $PingSweep.DropdownItems.Add($NetScanner) > $null
        
    $FastPing = new-object System.Windows.Forms.ToolStripMenuItem("Fast Ping")
    $FastPing.add_Click({ FastPinger })
    $PingSweep.DropdownItems.Add($FastPing) > $null
    
    $DetailPing = new-object System.Windows.Forms.ToolStripMenuItem("Detailed Ping")
    $DetailPing.add_Click({ DetailPing })
    $PingSweep.DropdownItems.Add($DetailPing) > $null
    
    $HealthPing = new-object System.Windows.Forms.ToolStripMenuItem("Health Ping")
    $HealthPing.add_Click({ HealthPing })
    $PingSweep.DropdownItems.Add($HealthPing) > $null
    
    $PingQuery = new-object System.Windows.Forms.ToolStripMenuItem("Ping Records")
    $PingQuery.add_Click({ PingQuery })
    $PingSweep.DropdownItems.Add($PingQuery) > $null
    
    $McAfeeTools = new-object System.Windows.Forms.ToolStripMenuItem("McAfee Tools")
    $NetOpsMenu.DropdownItems.Add($McAfeeTools) > $null
        
    $CheckPol = new-object System.Windows.Forms.ToolStripMenuItem("Check for New Policies")
    $CheckPol.add_Click({ CheckPolicies })
    $McAfeeTools.DropdownItems.Add($CheckPol) > $null
    
    $ColSend = new-object System.Windows.Forms.ToolStripMenuItem("Collect and Send Properties")
    $ColSend.add_Click({ collectprops })
    $McAfeeTools.DropdownItems.Add($ColSend) > $null
    
    $SendEvents = new-object System.Windows.Forms.ToolStripMenuItem("Send Events")
    $SendEvents.add_Click({ sendevents })
    $McAfeeTools.DropdownItems.Add($SendEvents) > $null
    
    $UpdateMcAfee = new-object System.Windows.Forms.ToolStripMenuItem("Update Dat File")
    $UpdateMcAfee.add_Click({ Update-McAfeeDat })
    $McAfeeTools.DropdownItems.Add($UpdateMcAfee) > $null
    
    $McAfeeLog = new-object System.Windows.Forms.ToolStripMenuItem("View McAfee Logs")
    $McAfeeLog.add_Click({ McAfeeLog })
    $McAfeeTools.DropdownItems.Add($McAfeeLog) > $null
    
    $FolderSizes = new-object System.Windows.Forms.ToolStripMenuItem("Folder Sizes")
    $NetOpsMenu.DropdownItems.Add($FolderSizes) > $null
        
    $GetSizes = new-object System.Windows.Forms.ToolStripMenuItem("Run a Scan")
    $GetSizes.add_Click({ FolderSize })
    $FolderSizes.DropdownItems.Add($GetSizes) > $null
    
    $FolderLo = new-object System.Windows.Forms.ToolStripMenuItem("Open Generated Reports")
    $FolderLo.add_Click({ FolderSizesFolder })
    $FolderSizes.DropdownItems.Add($FolderLo) > $null
    
    $PIIScanner = new-object System.Windows.Forms.ToolStripMenuItem("Basic PII Scanner (SSN)")
    $NetOpsMenu.DropdownItems.Add($PIIScanner) > $null
        
    $PIIScan = new-object System.Windows.Forms.ToolStripMenuItem("Run a Scan")
    $PIIScan.add_Click({ PII_Scanner })
    $PIIScanner.DropdownItems.Add($PIIScan) > $null
    
    $PIIScanResults = new-object System.Windows.Forms.ToolStripMenuItem("Open Generated Reports")
    $PIIScanResults.add_Click({ PIIScanFolder })
    $PIIScanner.DropdownItems.Add($PIIScanResults) > $null
    
    $ViewServices = new-object System.Windows.Forms.ToolStripMenuItem("Services")
    $ViewServices.add_Click({ Services })
    $CSTMenu.DropdownItems.Add($ViewServices) > $null
    
    $BitLockerStatus = new-object System.Windows.Forms.ToolStripMenuItem("BitLocker Status")
    $BitLockerStatus.add_Click({ BitLockerStatus })
    $CSTMenu.DropdownItems.Add($BitLockerStatus) > $null
    
    $ImportModule = new-object System.Windows.Forms.ToolStripMenuItem("Remotely Import AD Module")
    $ImportMOdule.add_Click({ ImportModule })
    $NetOpsMenu.DropdownItems.Add($ImportModule) > $null
    
    $MultiRestart = new-object System.Windows.Forms.ToolStripMenuItem("Shutdown/Restart Multiple PCs")
    $MultiRestart.add_Click({ MultiRestart })
    $NetOpsMenu.DropdownItems.Add($MultiRestart) > $null
    
    $ClientHealth = new-object System.Windows.Forms.ToolStripMenuItem("Client Health Status")
    $ClientHealth.add_Click({ ClientStatus })
    $NetOpsMenu.DropdownItems.Add($ClientHealth) > $null
    
    $MassCopier = new-object System.Windows.Forms.ToolStripMenuItem("Copy File to Multiple PCs")
    $MassCopier.add_Click({ MassCopy })
    $NetOpsMenu.DropdownItems.Add($MassCopier) > $null
    
    $PasswordChanger = new-object System.Windows.Forms.ToolStripMenuItem("Change Local Pwd on Multiple PCs")
    $PasswordChanger.add_Click({ PasswordChanger })
    $NetOpsMenu.DropdownItems.Add($PasswordChanger) > $null
    
    $SCCMApps = new-object System.Windows.Forms.ToolStripMenuItem("Software Center Apps")
    $SCCMApps.add_Click({ SCCMApps })
    $CSTMenu.DropdownItems.Add($SCCMApps) > $null
    
    $ViewCompManage = new-object System.Windows.Forms.ToolStripMenuItem("Computer Management")
    $ViewCompManage.add_Click({ CompManage })
    $CSTMenu.DropdownItems.Add($ViewCompManage) > $null
    
    $RemoteAdmin = new-object System.Windows.Forms.ToolStripMenuItem("Enable Remote Admin/Desktop")
    $RemoteAdmin.add_Click({ RemoteAdmin })
    $NetOpsMenu.DropdownItems.Add($RemoteAdmin) > $null
    
    $AdminExp = new-object System.Windows.Forms.ToolStripMenuItem("File Explorer w/ Admin Rights")
    $AdminExp.add_Click({ AdminExp })
    $CSTMenu.DropdownItems.Add($AdminExp) > $null
    
    $ViewProcesses = new-object System.Windows.Forms.ToolStripMenuItem("List Processes")
    $ViewProcesses.add_Click({ Processes })
    $CSTMenu.DropdownItems.Add($ViewProcesses) > $null
    
    $REGEDIT = new-object System.Windows.Forms.ToolStripMenuItem("RegEdit (This PC, $env:computername)")
    $REGEDIT.add_Click({ REGEDIT })
    $CSTMenu.DropdownItems.Add($REGEDIT) > $null
    
    $AdminLogs = new-object System.Windows.Forms.ToolStripMenuItem("View Admin_Tool Logs")
    $AdminLogs.add_Click({ AdminLogs })
    $SettingsMenu.DropdownItems.Add($AdminLogs) > $null
    
    $ViewSettings = new-object System.Windows.Forms.ToolStripMenuItem("View Settings")
    $ViewSettings.add_Click({ ViewSettings })
    $SettingsMenu.DropdownItems.Add($ViewSettings) > $null
    
    $ChangeSettings = new-object System.Windows.Forms.ToolStripMenuItem("Change Settings")
    $SettingsMenu.DropdownItems.Add($ChangeSettings) > $null
    
    $MAJCOMOU = new-object System.Windows.Forms.ToolStripMenuItem("MAJCOM OU")
    $MAJCOMOU.add_Click({ MAJCOMOU })
    $ChangeSettings.DropdownItems.Add($MAJCOMOU) > $null
    
    $BASEOU = new-object System.Windows.Forms.ToolStripMenuItem("Base OU")
    $BASEOU.add_Click({ BaseOU })
    $ChangeSettings.DropdownItems.Add($BASEOU) > $null
    
    $ADMINOU = new-object System.Windows.Forms.ToolStripMenuItem("Admin OU")
    $ADMINOU.add_Click({ AdminOU })
    $ChangeSettings.DropdownItems.Add($ADMINOU) > $null
    
    $Logs = new-object System.Windows.Forms.ToolStripMenuItem("Logs")
    $MDT.DropdownItems.Add($Logs) > $null
    
    $logon = new-object System.Windows.Forms.ToolStripMenuItem("Logon Activity")
    $logon.add_Click({ LogonActivity })
    $Logs.DropdownItems.Add($logon) > $null
    
    $Event = new-object System.Windows.Forms.ToolStripMenuItem("Event Activity")
    $Event.add_Click({ EventActivity })
    $Logs.DropdownItems.Add($Event) > $null
    
    $Dset = new-object System.Windows.Forms.ToolStripMenuItem("DSet Activity")
    $Dset.add_Click({ PIIActivity })
    $Logs.DropdownItems.Add($Dset) > $null
    
    $ViewEventVwr = new-object System.Windows.Forms.ToolStripMenuItem("Event Viewer")
    $ViewEventVwr.add_Click({ EventViewer })
    $Logs.DropdownItems.Add($ViewEventVwr) > $null
    
    $ListConnections = new-object System.Windows.Forms.ToolStripMenuItem("List Connections")
    $ListConnections.add_Click({ Connections })
    $MDT.DropdownItems.Add($ListConnections) > $null
    
    $PortScan = new-object System.Windows.Forms.ToolStripMenuItem("Port Scanner")
    $PortScan.add_Click({ PortScan })
    $MDT.DropdownItems.Add($PortScan) > $null
    
    $ServiceScan = new-object System.Windows.Forms.ToolStripMenuItem("Service Scanner")
    $ServiceScan.add_Click({ ServiceScanner })
    $MDT.DropdownItems.Add($ServiceScan) > $null
    
    $MenuStrip.Items.Add($FileMenu) > $null
    $MenuStrip.Items.Add($CSTMenu) > $null
    $MenuStrip.Items.Add($NetOpsMenu) > $null
    $MenuStrip.Items.Add($MDT) > $null
    $MenuStrip.Items.Add($SettingsMenu) > $null
    $form1.Controls.Add($MenuStrip)
    
    # Textbox 1 - Computer Name #
    $txt1 = New-Object System.Windows.Forms.TextBox
    $System_Drawing_Size = New-Object System.Drawing.Size
    $txt1.Font = New-Object System.Drawing.Font("Verdana", 8, [System.Drawing.FontStyle]::Bold)
    $System_Drawing_Size.Width = 240
    $System_Drawing_Size.Height = 27
    $txt1.Size = $System_Drawing_Size
    $txt1.DataBindings.DefaultDataSourceUpdateMode = 0
    $txt1.Name = "txt1"
    $txt1.Text = "Username, EDIPI, PC, or IP Address"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 32
    $txt1.Location = $System_Drawing_Point
    $txt1.TabIndex = 0
    $form1.Controls.Add($txt1)
    
    
    # Label 2 - Results #
    $lbl2 = New-Object System.Windows.Forms.Richtextbox
    $lbl2.TabIndex = 7
    $System_Drawing_Size = New-Object System.Drawing.Size
    $lbl2.Font = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Bold)
    $System_Drawing_Size.Width = 738
    $System_Drawing_Size.Height = ($form1.height - 230)
    $lbl2.Size = $System_Drawing_Size
    $lbl2.BorderStyle = 2
    $lbl2.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $lbl2.Location = $System_Drawing_Point
    $lbl2.DataBindings.DefaultDataSourceUpdateMode = 0
    $lbl2.Name = "lbl2"
    $lbl2.Text += "`n"
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                   (_)'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |_____'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |*  *  *  )'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |  *  *  (_______'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |*  *  *  : * * | ####)'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |  *  *  *:  *  |         (______________'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |*  *  *  : * * | ####:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |  *  *  *:  *  |         :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |*  *  *  : * * | ####:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |~~~~~:  *  |         :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |#####: * * | ####:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |          :~~~|         :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |#####:########:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |          :                :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |#####:########:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |          :                :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |          :########:##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |                           :                            |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |                           :##############|'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.Text += "`n"
    $lbl2.Text += '                                                                                                    |  |'
    $lbl2.WordWrap = $False
    $lbl2.AutoSize = $True
    $lbl2.Multiline = $True
    $lbl2.Visible = $true
    $form1.Controls.Add($lbl2)
    
    # Text Entry 1 - User Info W/ EDIPI #
    $Ent1 = New-Object System.Windows.Forms.Label
    $Ent1.Text = "Ex: Doe, John K MSgt..."
    $Ent1.Font = New-Object System.Drawing.Font("Verdana", 7, [System.Drawing.FontStyle]::Italic)
    $Ent1.ForeColor = "LightGray"
    $Ent1.DataBindings.DefaultDataSourceUpdateMode = 0 
    $Ent1.TabIndex = 7 
    $Ent1.Name = 'Ent1' 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 126 
    $System_Drawing_Size.Height = 12 
    $Ent1.Size = $System_Drawing_Size 
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 54
    $Ent1.Location = $System_Drawing_Point  
    $form1.Controls.Add($Ent1) 
    
    # Text Entry 2 - Computer Name #
    $Ent2 = New-Object System.Windows.Forms.Label
    $Ent2.Text = "Ex: $env:computername"
    $Ent2.Font = New-Object System.Drawing.Font("Verdana", 7, [System.Drawing.FontStyle]::Italic)
    $Ent2.ForeColor = "LightGray"
    $Ent2.DataBindings.DefaultDataSourceUpdateMode = 0 
    $Ent2.TabIndex = 9 
    $Ent2.Name = 'Ent2' 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 105
    $System_Drawing_Size.Height = 12 
    $Ent2.Size = $System_Drawing_Size 
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 130
    $System_Drawing_Point.Y = 54
    $Ent2.Location = $System_Drawing_Point  
    $form1.Controls.Add($Ent2)
    
    # Text Entry  - Task progress #
    $Ent3 = New-Object System.Windows.Forms.Label
    $Ent3.Text = "Task progress..."
    $Ent3.Font = New-Object System.Drawing.Font("Verdana", 8, [System.Drawing.FontStyle]::Italic)
    $Ent3.ForeColor = "LightGray"
    $Ent3.DataBindings.DefaultDataSourceUpdateMode = 0 
    $Ent3.TabIndex = 7 
    $Ent3.Name = 'Ent3' 
    $System_Drawing_Size = New-Object System.Drawing.Size 
    $System_Drawing_Size.Width = 110 
    $System_Drawing_Size.Height = 13 
    $Ent3.Size = $System_Drawing_Size 
    $System_Drawing_Point = New-Object System.Drawing.Point 
    $System_Drawing_Point.X = 72
    $System_Drawing_Point.Y = 110
    $Ent3.Location = $System_Drawing_Point  
    $form1.Controls.Add($Ent3)
    
    # Text Entry  - Admin Message #
    if (!(IsAdmin)) {
        $Ent4 = New-Object System.Windows.Forms.Label
        $Ent4.Text = "Run as admin to use the other tools."
        $Ent4.Font = New-Object System.Drawing.Font("Verdana", 10, [System.Drawing.FontStyle]::Bold)
        $Ent4.ForeColor = "Red"
        $Ent4.DataBindings.DefaultDataSourceUpdateMode = 0 
        $Ent4.TabIndex = 7 
        $Ent4.Name = 'Ent4' 
        $System_Drawing_Size = New-Object System.Drawing.Size 
        $System_Drawing_Size.Width = 300 
        $System_Drawing_Size.Height = 20 
        $Ent4.Size = $System_Drawing_Size 
        $System_Drawing_Point = New-Object System.Drawing.Point 
        $System_Drawing_Point.X = 300
        $System_Drawing_Point.Y = 130
        $Ent4.Location = $System_Drawing_Point  
        $form1.Controls.Add($Ent4)
    }
    
    # Group 1 - Common Tools #
    $grp1 = New-Object System.Windows.Forms.GroupBox
    $grp1.Name = "grp1"
    $grp1.Text = "Common Tools"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 350
    $System_Drawing_Size.Height = 85
    $grp1.Size = $System_Drawing_Size
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 257
    $System_Drawing_Point.Y = 25
    $grp1.Location = $System_Drawing_Point
    $grp1.TabStop = $False
    $grp1.TabIndex = 4
    $grp1.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.Controls.Add($grp1)
    
    
    # Group 2 - Remote Install #
    $grp2 = New-Object System.Windows.Forms.GroupBox
    $grp2.Name = "grp2"
    $grp2.Text = "Remote Install"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 125
    $System_Drawing_Size.Height = 130
    $grp2.Size = $System_Drawing_Size
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 617
    $System_Drawing_Point.Y = 25
    $grp2.Location = $System_Drawing_Point
    $grp2.TabStop = $False
    $grp2.TabIndex = 5
    $grp2.DataBindings.DefaultDataSourceUpdateMode = 0
    $form1.Controls.Add($grp2)
    
    ############################ RADIO BUTTONS ##############################
    $RadioButton1 = New-Object System.Windows.Forms.RadioButton #create the radio button
    $RadioButton1.Location = new-object System.Drawing.Point(6, 15) #location of the radio button(px) in relation to the group box's edges (length, height)
    $RadioButton1.size = New-Object System.Drawing.Size(44, 20) #the size in px of the radio button (length, height)
    $RadioButton1.Checked = $true #is checked by default
    $RadioButton1.Text = "One" #labeling the radio button
    if (!(IsAdmin)) {
        $RadioButton1.Enabled = $False
    }
    else { $RadioButton1.Enabled = $True }
    $grp2.Controls.Add($RadioButton1) #activate the inside the group box
    
    $RadioButton2 = New-Object System.Windows.Forms.RadioButton #create the radio button
    $RadioButton2.Location = new-object System.Drawing.Point(51, 15) #location of the radio button(px) in relation to the group box's edges (length, height)
    $RadioButton2.size = New-Object System.Drawing.Size(50, 20) #the size in px of the radio button (length, height)
    $RadioButton2.Checked = $false #is not checked by default
    $RadioButton2.Text = "Many" #labeling the radio button
    if (!(IsAdmin)) {
        $RadioButton2.Enabled = $False
    }
    else { $RadioButton2.Enabled = $True }
    $grp2.Controls.Add($RadioButton2) #activate the inside the group box
    #########################################################################
    
    ############################## DROP DOWN ################################
    $DropDownBox = New-Object System.Windows.Forms.ComboBox #creating the dropdown list
    $DropdownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $DropdownBox.BackColor = "LightGray"
    $Dropdownbox.Font = New-Object System.Drawing.Font("Verdana", 7, [System.Drawing.FontStyle]::Bold)
    $DropDownBox.Location = New-Object System.Drawing.Size(5, 42) #location of the drop down (px) in relation to the primary window's edges (length, height)
    $DropDownBox.Size = New-Object System.Drawing.Size(115, 30) #the size in px of the drop down box (length, height)
    $DropDownBox.DropDownHeight = 200 #the height of the pop out selection box
    $grp2.Controls.Add($DropDownBox) #activating the drop box inside the primary window
    
    $InstallArray = @("Java", "Adobe Pro", "Adobe Flash", "Firefox", "Chrome", "SMIME", "VPN", "AtHoc (PACAF)", "MSI/MSU/MSP File", "HBSS Frame Package", "PS1/VBS/CMD Script", "Custom Install")
    
    foreach ($Install in $InstallArray) {
        $DropDownBox.Items.Add($Install) > $null
    } #end foreach
    ##########################################################################
    
    # Button 15 - Open Computer Text File #
    $btn15 = New-Object System.Windows.Forms.Button
    $btn15.TabIndex = 15
    $btn15.Name = "btn15"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 22
    $System_Drawing_Size.Height = 23
    $btn15.Size = $System_Drawing_Size
    $btn15.UseVisualStyleBackColor = $True
    $btn15.Text = "..."
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 100
    $System_Drawing_Point.Y = 12
    $btn15.Location = $System_Drawing_Point
    $btn15.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn15.add_Click($btn15_OnClick)
    if (!(IsAdmin)) {
        $btn15.Enabled = $False
    }
    else { $btn15.Enabled = $True }
    $grp2.Controls.Add($btn15)
    
    # Button 14 - User Search #
    $btn14 = New-Object System.Windows.Forms.Button
    $btn14.TabIndex = 14
    $btn14.Name = "btn14"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 115
    $System_Drawing_Size.Height = 30
    $btn14.Size = $System_Drawing_Size
    $btn14.UseVisualStyleBackColor = $True
    $btn14.Text = "User Information"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 70
    $btn14.BackColor = "LightSteelBlue"
    $btn14.Location = $System_Drawing_Point
    $btn14.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn14.add_Click($btn14_OnClick)
    $form1.Controls.Add($btn14)
    
    # Button 1 - System Info #
    $btn1 = New-Object System.Windows.Forms.Button
    $btn1.TabIndex = 1
    $btn1.Name = "btn1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn1.Size = $System_Drawing_Size
    $btn1.UseVisualStyleBackColor = $True
    $btn1.Text = "Computer Info"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 7
    $System_Drawing_Point.Y = 20
    $btn1.BackColor = "LightYellow"
    $btn1.Location = $System_Drawing_Point
    $btn1.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn1.add_Click($btn1_OnClick)
    $grp1.Controls.Add($btn1)
    
    # Button 27 - Ping #
    $btn27 = New-Object System.Windows.Forms.Button
    $btn27.TabIndex = 27
    $btn27.Name = "btn1"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 115
    $System_Drawing_Size.Height = 30
    $btn27.Size = $System_Drawing_Size
    $btn27.UseVisualStyleBackColor = $True
    $btn27.Text = "Ping"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 130
    $System_Drawing_Point.Y = 70
    $btn27.BackColor = "LightGreen"
    $btn27.Location = $System_Drawing_Point
    $btn27.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn27.add_Click($btn27_OnClick)
    $form1.Controls.Add($btn27)
    
    # Button 3 - Applications #
    $btn3 = New-Object System.Windows.Forms.Button
    $btn3.TabIndex = 3
    $btn3.Name = "btn3"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn3.Size = $System_Drawing_Size
    $btn3.UseVisualStyleBackColor = $True
    $btn3.Text = "&Applications"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 120
    $System_Drawing_Point.Y = 20
    $btn3.Location = $System_Drawing_Point
    $btn3.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn3.add_Click($btn3_OnClick)
    if (!(IsAdmin)) {
        $btn3.Enabled = $False
    }
    else { $btn3.Enabled = $True }
    $grp1.Controls.Add($btn3)
    
    
    # Button 4 - Remote Desktop #
    $btn4 = New-Object System.Windows.Forms.Button
    $btn4.TabIndex = 4
    $btn4.Name = "btn4"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn4.Size = $System_Drawing_Size
    $btn4.UseVisualStyleBackColor = $True
    $btn4.Text = "Remote &Desktop"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 233
    $System_Drawing_Point.Y = 20
    $btn4.Location = $System_Drawing_Point
    $btn4.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn4.add_Click($btn4_OnClick)
    if (!(IsAdmin)) {
        $btn4.Enabled = $False
    }
    else { $btn4.Enabled = $True }
    $grp1.Controls.Add($btn4)
    
    
    # Button 5 - Files to be Installed #
    $btn5 = New-Object System.Windows.Forms.Button
    $btn5.TabIndex = 5
    $btn5.Name = "btn5"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 117
    $System_Drawing_Size.Height = 25
    $btn5.Size = $System_Drawing_Size
    $btn5.UseVisualStyleBackColor = $True
    $btn5.Text = "File to be Installed"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 4
    $System_Drawing_Point.Y = 69
    $btn5.Location = $System_Drawing_Point
    $btn5.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn5.add_Click($btn5_OnClick)
    if (!(IsAdmin)) {
        $btn5.Enabled = $False
    }
    else { $btn5.Enabled = $True }
    $grp2.Controls.Add($btn5)
    
    # Button 16 - Run the Install #
    $btn16 = New-Object System.Windows.Forms.Button
    $btn16.TabIndex = 16
    $btn16.Name = "btn16"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 117
    $System_Drawing_Size.Height = 25
    $btn16.Size = $System_Drawing_Size
    $btn16.UseVisualStyleBackColor = $True
    $btn16.Text = "Run the Install"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 4
    $System_Drawing_Point.Y = 100
    $btn16.Location = $System_Drawing_Point
    $btn16.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn16.add_Click($btn16_OnClick) #({btn16_OnClick}) makes this button a function
    if (!(IsAdmin)) {
        $btn16.Enabled = $False
    }
    else { $btn16.Enabled = $True }
    $grp2.Controls.Add($btn16)
    
    # Button 6 - File Structure #
    $btn6 = New-Object System.Windows.Forms.Button
    $btn6.TabIndex = 6
    $btn6.Name = "btn6"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn6.Size = $System_Drawing_Size
    $btn6.UseVisualStyleBackColor = $True
    $btn6.Text = "View &C Drive"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 7
    $System_Drawing_Point.Y = 50
    $btn6.Location = $System_Drawing_Point
    $btn6.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn6.add_Click($btn6_OnClick)
    if (!(IsAdmin)) {
        $btn6.Enabled = $False
    }
    else { $btn6.Enabled = $True }
    $grp1.Controls.Add($btn6)
    
    
    # Button 7 - Restart Computer #
    $btn7 = New-Object System.Windows.Forms.Button
    $btn7.TabIndex = 7
    $btn7.Name = "btn7"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn7.Size = $System_Drawing_Size
    $btn7.UseVisualStyleBackColor = $True
    $btn7.Text = "&Restart Computer"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 120
    $System_Drawing_Point.Y = 50
    $btn7.Location = $System_Drawing_Point
    $btn7.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn7.add_Click($btn7_OnClick)
    if (!(IsAdmin)) {
        $btn7.Enabled = $False
    }
    else { $btn7.Enabled = $True }
    $grp1.Controls.Add($btn7)
    
    # Button 28 - Switch User #
    $btn28 = New-Object System.Windows.Forms.Button
    $btn28.TabIndex = 28
    $btn28.Name = "btn28"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn28.Size = $System_Drawing_Size
    $btn28.UseVisualStyleBackColor = $True
    $btn28.Text = "&Switch User"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 234
    $System_Drawing_Point.Y = 50
    $btn28.Location = $System_Drawing_Point
    $btn28.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn28.add_Click($SwitchUser)
    if (!(IsAdmin)) {
        $btn28.Enabled = $False
    }
    else { $btn28.Enabled = $True }
    $grp1.Controls.Add($btn28)
    
    # Button 10 - End Process #
    $btn10 = New-Object System.Windows.Forms.Button
    $btn10.TabIndex = 11
    $btn10.Name = "btn10"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn10.Size = $System_Drawing_Size
    $btn10.anchor = "bottom, left"
    $btn10.UseVisualStyleBackColor = $True
    $btn10.Text = "End Process"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn10.Location = $System_Drawing_Point
    $btn10.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn10.add_Click($btn10_OnClick)
    $btn10.Visible = $False
    $form1.Controls.Add($btn10)
    
    # Button 11 - Uninstall App #
    $btn11 = New-Object System.Windows.Forms.Button
    $btn11.TabIndex = 12
    $btn11.Name = "btn11"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn11.Size = $System_Drawing_Size
    $btn11.anchor = "bottom, left"
    $btn11.UseVisualStyleBackColor = $True
    $btn11.Text = "Uninstall App"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn11.Location = $System_Drawing_Point
    $btn11.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn11.add_Click($btn11_OnClick)
    $btn11.Visible = $False
    $form1.Controls.Add($btn11)
    
    # Button 18 - Refresh Install Log For Multi-Install#
    $btn18 = New-Object System.Windows.Forms.Button
    $btn18.TabIndex = 12
    $btn18.Name = "btn18"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn18.Size = $System_Drawing_Size
    $btn18.anchor = "bottom, left"
    $btn18.UseVisualStyleBackColor = $True
    $btn18.Text = "Refresh Log"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn18.Location = $System_Drawing_Point
    $btn18.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn18.add_Click($btn18_OnClick)
    $btn18.Visible = $False
    $form1.Controls.Add($btn18)
    
    # Button 19 - Refresh Get-Job #
    $btn19 = New-Object System.Windows.Forms.Button
    $btn19.TabIndex = 12
    $btn19.Name = "btn19"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn19.Size = $System_Drawing_Size
    $btn19.anchor = "bottom, left"
    $btn19.UseVisualStyleBackColor = $True
    $btn19.Text = "Get Jobs"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 376
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn19.Location = $System_Drawing_Point
    $btn19.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn19.add_Click($btn19_OnClick)
    $btn19.Visible = $False
    $form1.Controls.Add($btn19)
    
    # Button 20 - Stop Get-Job #
    $btn20 = New-Object System.Windows.Forms.Button
    $btn20.TabIndex = 12
    $btn20.Name = "btn20"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn20.Size = $System_Drawing_Size
    $btn20.anchor = "bottom, left"
    $btn20.UseVisualStyleBackColor = $True
    $btn20.Text = "Stop Job"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 490
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn20.Location = $System_Drawing_Point
    $btn20.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn20.add_Click($btn20_OnClick)
    $btn20.Visible = $False
    $form1.Controls.Add($btn20)
    
    # Button 17 - SCCM Apps #
    $btn17 = New-Object System.Windows.Forms.Button
    $btn17.TabIndex = 20
    $btn17.Name = "btn17"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn17.Size = $System_Drawing_Size
    $btn17.anchor = "bottom, left"
    $btn17.UseVisualStyleBackColor = $True
    $btn17.Text = "Install/Uninstall"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn17.Location = $System_Drawing_Point
    $btn17.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn17.add_Click($btn17_OnClick)
    $btn17.Visible = $false
    $form1.Controls.Add($btn17)
    
    # Button 21 - Kill Connection #
    $btn21 = New-Object System.Windows.Forms.Button
    $btn21.TabIndex = 21
    $btn21.Name = "btn21"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn21.Size = $System_Drawing_Size
    $btn21.anchor = "bottom, left"
    $btn21.UseVisualStyleBackColor = $True
    $btn21.Text = "Kill Connection"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn21.Location = $System_Drawing_Point
    $btn21.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn21.add_Click($btn21_OnClick)
    $btn21.Visible = $False
    $form1.Controls.Add($btn21)
    
    # Button 22 - Uninstall String #
    $btn22 = New-Object System.Windows.Forms.Button
    $btn22.TabIndex = 22
    $btn22.Name = "btn22"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn22.Size = $System_Drawing_Size
    $btn22.anchor = "bottom, left"
    $btn22.UseVisualStyleBackColor = $True
    $btn22.Text = "Manual Uninstall"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 376
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn22.BackColor = "LightYellow"
    $btn22.Location = $System_Drawing_Point
    $btn22.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn22.add_Click($btn22_OnClick)
    $btn22.Visible = $False
    $form1.Controls.Add($btn22)
    
    # Button 23 - Remove Users #
    $btn23 = New-Object System.Windows.Forms.Button
    $btn23.TabIndex = 23
    $btn23.Name = "btn23"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn23.Size = $System_Drawing_Size
    $btn23.anchor = "bottom, left"
    $btn23.UseVisualStyleBackColor = $True
    $btn23.Text = "Remove User(s)"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    #$btn23.BackColor = "LightGreen"
    $btn23.Location = $System_Drawing_Point
    $btn23.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn23.add_Click($btn23_OnClick)
    $btn23.Visible = $False
    $form1.Controls.Add($btn23)
    
    # Button 24 - Force Remove Users #
    $btn24 = New-Object System.Windows.Forms.Button
    $btn24.TabIndex = 24
    $btn24.Name = "btn24"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn24.Size = $System_Drawing_Size
    $btn24.anchor = "bottom, left"
    $btn24.UseVisualStyleBackColor = $True
    $btn24.Text = "Force Remove"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 376
    $System_Drawing_Point.Y = ($form1.height - 535)
    $btn24.BackColor = "Pink"
    $btn24.Location = $System_Drawing_Point
    $btn24.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn24.add_Click($btn24_OnClick)
    $btn24.Visible = $False
    $form1.Controls.Add($btn24)
    
    # Button 25 - Reset Local User Passwords #
    $btn25 = New-Object System.Windows.Forms.Button
    $btn25.TabIndex = 25
    $btn25.Name = "btn25"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn25.Size = $System_Drawing_Size
    $btn25.anchor = "bottom, left"
    $btn25.UseVisualStyleBackColor = $True
    $btn25.Text = "Reset Password"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 263
    $System_Drawing_Point.Y = ($form1.height - 535)
    #$btn25.BackColor = "Pink"
    $btn25.Location = $System_Drawing_Point
    $btn25.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn25.add_Click($btn25_OnClick)
    $btn25.Visible = $False
    $form1.Controls.Add($btn25)
    
    # Button 26 - Unlock Local User Account #
    $btn26 = New-Object System.Windows.Forms.Button
    $btn26.TabIndex = 26
    $btn26.Name = "btn26"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 110
    $System_Drawing_Size.Height = 25
    $btn26.Size = $System_Drawing_Size
    $btn26.anchor = "bottom, left"
    $btn26.UseVisualStyleBackColor = $True
    $btn26.Text = "Enable User"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 376
    $System_Drawing_Point.Y = ($form1.height - 535)
    #$btn26.BackColor = "Pink"
    $btn26.Location = $System_Drawing_Point
    $btn26.DataBindings.DefaultDataSourceUpdateMode = 0
    $btn26.add_Click($btn26_OnClick)
    $btn26.Visible = $False
    $form1.Controls.Add($btn26)
    
    ## Listview 1 ##
    $list1 = New-Object System.Windows.Forms.ListView
    $list1.DataBindings.DefaultDataSourceUpdateMode = 0
    $list1.Name = "list1"
    $list1.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list1.Location = $System_Drawing_Point
    $list1.TabIndex = 3
    $list1.View = [System.Windows.Forms.View]"Details"
    $list1.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list1.FullRowSelect = $true
    $list1.GridLines = $true
    $columnnames = "Name", "InstallDate", "UninstallKey"
    $list1.Columns.Add("Name", 150) | out-null
    $list1.Columns.Add("InstallDate", 450) | out-null
    $list1.Columns.Add("UninstallKey", 950) | out-null
    $list1.visible = $false
    $form1.Controls.Add($list1)
    
    ## Listview 2 ##
    $list2 = New-Object System.Windows.Forms.ListView
    $list2.DataBindings.DefaultDataSourceUpdateMode = 0
    $list2.Name = "list2"
    $list2.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list2.Location = $System_Drawing_Point
    $list2.TabIndex = 4
    $list2.View = [System.Windows.Forms.View]"Details"
    $list2.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list2.FullRowSelect = $true
    $list2.GridLines = $true
    $columnnames = "Name", "Path"
    $list2.Columns.Add("Name", 150) | out-null
    $list2.Columns.Add("Path", 450) | out-null
    $list2.visible = $false
    $form1.Controls.Add($list2)
    
    ## Listview 3 ##
    $list3 = New-Object System.Windows.Forms.ListView
    $list3.DataBindings.DefaultDataSourceUpdateMode = 0
    $list3.Name = "list3"
    $list3.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list3.Location = $System_Drawing_Point
    $list3.TabIndex = 5
    $list3.View = [System.Windows.Forms.View]"Details"
    $list3.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list3.FullRowSelect = $true
    $list3.GridLines = $true
    $columnnames = "Name", "State"
    $list3.Columns.Add("Name", 150) | out-null
    $list3.Columns.Add("State", 450) | out-null
    $list3.visible = $False
    $form1.Controls.Add($list3)
    
    ## Listview 5 ##
    $list5 = New-Object System.Windows.Forms.ListView
    $list5.DataBindings.DefaultDataSourceUpdateMode = 0
    $list5.Name = "list5"
    $list5.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list5.Location = $System_Drawing_Point
    $list5.TabIndex = 6
    $list5.View = [System.Windows.Forms.View]"Details"
    $list5.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list5.FullRowSelect = $true
    $list5.GridLines = $true
    $columnnames = "Name", "State"
    $list5.Columns.Add("Name", 150) | out-null
    $list5.Columns.Add("ExecutablePath", 450) | out-null
    $list5.visible = $False
    $form1.Controls.Add($list5)
    
    ## Listview 6 - Show Connections ##
    $list6 = New-Object System.Windows.Forms.ListView
    $list6.DataBindings.DefaultDataSourceUpdateMode = 0
    $list6.Name = "list6"
    $list6.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list6.Location = $System_Drawing_Point
    $list6.TabIndex = 8
    $list6.View = [System.Windows.Forms.View]"Details"
    $list6.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list6.FullRowSelect = $true
    $list6.GridLines = $true
    $columnnames = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
    $list6.Columns.Add("ComputerName", 150) | out-null
    $list6.Columns.Add("Protocol", 150) | out-null
    $list6.Columns.Add("State", 150) | out-null
    $list6.Columns.Add("LocalAddress", 150) | out-null
    $list6.Columns.Add("LocalPort", 150) | out-null
    $list6.Columns.Add("RemoteAddress", 150) | out-null
    $list6.Columns.Add("RemoteHostName", 150) | out-null
    $list6.Columns.Add("RemotePort", 150) | out-null
    $list6.Columns.Add("CreationTime", 150) | out-null
    $list6.Columns.Add("ProcessName", 150) | out-null
    $list6.Columns.Add("UserName", 150) | out-null
    $list6.Columns.Add("OwningProcess", 150) | out-null
    $list6.visible = $False
    $form1.Controls.Add($list6)
    
    ## Listview 7 - Port Scanner ##
    $list7 = New-Object System.Windows.Forms.ListView
    $list7.DataBindings.DefaultDataSourceUpdateMode = 0
    $list7.Name = "list7"
    $list7.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list7.Location = $System_Drawing_Point
    $list7.TabIndex = 8
    $list7.View = [System.Windows.Forms.View]"Details"
    $list7.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list7.FullRowSelect = $true
    $list7.GridLines = $true
    $columnnames = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
    $list7.Columns.Add("ComputerName", 150) | out-null
    $list7.Columns.Add("Protocol", 150) | out-null
    $list7.Columns.Add("State", 150) | out-null
    $list7.Columns.Add("LocalAddress", 150) | out-null
    $list7.Columns.Add("LocalPort", 150) | out-null
    $list7.Columns.Add("RemoteAddress", 150) | out-null
    $list7.Columns.Add("RemoteHostName", 150) | out-null
    $list7.Columns.Add("RemotePort", 150) | out-null
    $list7.Columns.Add("CreationTime", 150) | out-null
    $list7.Columns.Add("ProcessName", 150) | out-null
    $list7.Columns.Add("UserName", 150) | out-null
    $list7.Columns.Add("OwningProcess", 150) | out-null
    $list7.visible = $False
    $form1.Controls.Add($list7)
    
    ## Listview 9 - Service Scanner ##
    $list9 = New-Object System.Windows.Forms.ListView
    $list9.DataBindings.DefaultDataSourceUpdateMode = 0
    $list9.Name = "list9"
    $list9.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list9.Location = $System_Drawing_Point
    $list9.TabIndex = 8
    $list9.View = [System.Windows.Forms.View]"Details"
    $list9.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list9.FullRowSelect = $true
    $list9.GridLines = $true
    $columnnames = "ComputerName", "Protocol", "State", "LocalAddress", "LocalPort", "RemoteAddress", "RemoteHostName", "RemotePort", "CreationTime", "ProcessName", "UserName", "OwningProcess"
    $list9.Columns.Add("ComputerName", 150) | out-null
    $list9.Columns.Add("Protocol", 150) | out-null
    $list9.Columns.Add("State", 150) | out-null
    $list9.Columns.Add("LocalAddress", 150) | out-null
    $list9.Columns.Add("LocalPort", 150) | out-null
    $list9.Columns.Add("RemoteAddress", 150) | out-null
    $list9.Columns.Add("RemoteHostName", 150) | out-null
    $list9.Columns.Add("RemotePort", 150) | out-null
    $list9.Columns.Add("CreationTime", 150) | out-null
    $list9.Columns.Add("ProcessName", 150) | out-null
    $list9.Columns.Add("UserName", 150) | out-null
    $list9.Columns.Add("OwningProcess", 150) | out-null
    $list9.visible = $False
    $form1.Controls.Add($list9)
    
    ## Listview 10 - Remove Profiles ##
    $list10 = New-Object System.Windows.Forms.ListView
    $list10.DataBindings.DefaultDataSourceUpdateMode = 0
    $list10.Name = "list10"
    $list10.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list10.Location = $System_Drawing_Point
    $list10.TabIndex = 10
    $list10.View = [System.Windows.Forms.View]"Details"
    $list10.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list10.FullRowSelect = $true
    $list10.GridLines = $true
    $columnnames = "User", "Size", "LastAccessed", "LastWritten"
    $list10.Columns.Add("User", 150) | out-null
    $list10.Columns.Add("Size", 150) | out-null
    $list10.Columns.Add("LastAccessed", 150) | out-null
    $list10.Columns.Add("LastWritten", 150) | out-null
    $list10.visible = $False
    $form1.Controls.Add($list10)
    
    ## Listview 11 - List Local Profiles ##
    $list11 = New-Object System.Windows.Forms.ListView
    $list11.DataBindings.DefaultDataSourceUpdateMode = 0
    $list11.Name = "list11"
    $list11.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list11.Location = $System_Drawing_Point
    $list11.TabIndex = 11
    $list11.View = [System.Windows.Forms.View]"Details"
    $list11.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list11.FullRowSelect = $true
    $list11.GridLines = $true
    $columnnames = "User", "Description", "Enabled", "PwdLastSet", "SID"
    $list11.Columns.Add("User", 150) | out-null
    $list11.Columns.Add("Description", 150) | out-null
    $list11.Columns.Add("Enabled", 150) | out-null
    $list11.Columns.Add("PwdLastSet", 150) | out-null
    $list11.Columns.Add("SID", 150) | out-null
    $list11.visible = $False
    $form1.Controls.Add($list11)
    
    ## Listview 12 - List Printers ##
    $list12 = New-Object System.Windows.Forms.ListView
    $list12.DataBindings.DefaultDataSourceUpdateMode = 0
    $list12.Name = "list12"
    $list12.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 185
    $list12.Location = $System_Drawing_Point
    $list12.TabIndex = 12
    $list12.View = [System.Windows.Forms.View]"Details"
    $list12.Size = new-object System.Drawing.Size(738, ($form1.height - 230))
    $list12.FullRowSelect = $true
    $list12.GridLines = $true
    $columnnames = "Name", "DriverName", "Default", "PortName", "Queued,SpoolEnabled,Shared"
    $list12.Columns.Add("Name", 150) | out-null
    $list12.Columns.Add("DriverName", 150) | out-null
    $list12.Columns.Add("Default", 150) | out-null
    $list12.Columns.Add("PortName", 150) | out-null
    $list12.Columns.Add("Queued", 150) | out-null
    $list12.Columns.Add("SpoolEnabled", 150) | out-null
    $list12.Columns.Add("Shared", 150) | out-null
    $list12.visible = $False
    $form1.Controls.Add($list12)
    
    ## Status Bar ##
    $stBar1 = New-Object System.Windows.Forms.StatusBar
    $stBar1.Name = "stBar1"
    $stBar1.Text = "Ready"
    $System_Drawing_Size = New-Object System.Drawing.Size
    $stBar1.Font = New-Object System.Drawing.Font("Verdana", 9, [System.Drawing.FontStyle]::Bold)
    $System_Drawing_Size.Width = 738
    $System_Drawing_Size.Height = 25
    $stBar1.Size = $System_Drawing_Size
    $stBar1.Anchor = "top,left,right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = 158
    $stBar1.Location = $System_Drawing_Point
    $stBar1.BackColor = "lightgray"
    $stBar1.AutoSize = $False
    $stBar1.ForeColor = "lightgray"
    $stBar1.DataBindings.DefaultDataSourceUpdateMode = 0
    $stBar1.TabIndex = 1
    $form1.Controls.Add($stBar1)
    
    
    ## Status Bar ## 
    <#
    $stBar1 = New-Object System.Windows.Forms.Richtextbox
    $stBar1.TabIndex = 8
    $System_Drawing_Size = New-Object System.Drawing.Size
    $stBar1.Font = New-Object System.Drawing.Font("Verdana",10,[System.Drawing.FontStyle]::Bold)
    $System_Drawing_Size.Width = 738
    $System_Drawing_Size.Height = 23
    $stBar1.Size = $System_Drawing_Size
    $stBar1.BorderStyle = 2
    $stBar1.anchor = "bottom, left, top, right"
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = ($form1.height - 502)
    $stBar1.Location = $System_Drawing_Point
    $stBar1.DataBindings.DefaultDataSourceUpdateMode = 0
    $stBar1.Name = "StBar1"
    $stBar1.Text += "Ready"
    $stBar1.BackColor = "lightgray"
    $stBar1.SelectionAlignment = "Center"
    $stBar1.ScrollBars = "None"
    $stBar1.WordWrap = $False
    $stBar1.AutoSize = $True
    $stBar1.Multiline = $True
    $stBar1.Visible = $true
    $form1.Controls.Add($stBar1)#>
    
    ## Progress Bar ##
    $progress1 = New-Object System.Windows.Forms.ProgressBar
    $progress1.DataBindings.DefaultDataSourceUpdateMode = 0
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 230
    $System_Drawing_Size.Height = 30
    $progress1.Size = $System_Drawing_Size
    $progress1.Step = 1
    $progress1.TabIndex = 0
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 5
    $System_Drawing_Point.Y = ($form1.height - 536)
    $progress1.Location = $System_Drawing_Point
    $progress1.Name = "p1"
    $progress1.Visible = $True
    $progress1.text = "Task progress..."
    $form1.Controls.Add($progress1)
    
    #endregion Generated Form Code
    
    $InitialFormWindowState = $form1.WindowState #Save the initial state of the form
    $form1.add_Load($OnLoadForm_StateCorrection) #Init the OnLoad event to correct the initial state of the form
    $form1.ShowDialog() | Out-Null #Show the Form
    
} #End Function GenerateForm
    
# Enable VB messageboxes
$vbmsg = new-object -comobject wscript.shell
    
# Checks to see if RSAT is installed and imports the module
Function ADImport {
    if (Get-Module -list ActiveDirectory) { Import-Module ActiveDirectory }
    
    Elseif (Test-Path "$env:SystemDrive\Admin_Tool\AD_Module" -ErrorAction SilentlyContinue) {
        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\*.dll
        Start-Sleep -Milliseconds 600
        Import-Module $env:SystemDrive\Admin_Tool\AD_Module\ActiveDirectory\*.psd1
    }
    Else {
        $vbmsg1 = $vbmsg.popup("The RSAT modules are not installed. You will not be able to perform Active Directory queries. You can get the RSAT install file from the shared drive or Microsoft website (https://www.microsoft.com/en-us/download/details.aspx?id=45520).", 0, "RSAT Check", 0)
    }
}
ADImport
    
# Create Task Log at Startup #
<#if(!(Test-Path "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log")){
    New-Item "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log" -ItemType File -Force
    "`t`t`t`t Task Logs Performed by Admin_Tool `n`n" | -filepath "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log"
    }#>
    
# Get local user/computer info #
$user = $env:username
# FIXME: Remove $userPC = $env:computername
$userdomain = $env:USERDNSDOMAIN
$lfile = "$env:SystemDrive\Admin_Tool\Task_Logs\logs.log"
$Version = "v7.8.0"
    
# Silence All Errors #
$ErrorActionPreference = 'silentlycontinue'
    
#Call the Function
GenerateForm
