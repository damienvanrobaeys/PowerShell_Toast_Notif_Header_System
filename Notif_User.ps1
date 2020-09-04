$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path

$Notif_Config_XML = "$Current_Folder\Notif_Config.xml"
$Get_Notif_Content = ([xml](get-content $Notif_Config_XML)).Toast_Notif
$Title = $Get_Notif_Content.Notif_Title
$Message = $Get_Notif_Content.Notif_Text
$Attribution = $Get_Notif_Content.Notif_Attribution	
$HeaderLogo = $Get_Notif_Content.Notif_Picture
$NotifFolder = $Get_Notif_Content.Notif_Folder	
$NotifScenario = $Get_Notif_Content.Notif_Scenario	

$Scenario          = "$NotifScenario" 
$LogoType		   = "crop"
$HeroImage         = "$NotifFolder\$HeaderLogo"
[xml]$Toast = @"
<toast scenario="$Scenario">
    <visual>
    <binding template="ToastGeneric">
		<image placement="hero" src="$HeroImage"/>		
        <text placement="attribution">$Attribution</text>
		<text>$Title</text>
		<text>$Message</text>	
    </binding>
    </visual>
</toast>
"@
$Load = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$Load = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$AppID =  "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($Toast.OuterXml)		
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID).Show($ToastXml)