$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path
$Log_File = "c:\windows\debug\display_notif.log"

$Notif_Config_XML = "$Current_Folder\Notif_Config.xml"
$Get_Notif_Content = ([xml](get-content $Notif_Config_XML)).Toast_Notif
$Notification_folder = $Get_Notif_Content.Notif_Folder	

Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"	
		write-host  "$MyDate - $Message_Type : $Message"				
	}
	
If(!(test-path $Log_File)){new-item $Log_File -type file -force}
If(!(test-path $Notification_folder)){new-item $Notification_folder -type Directory -force}
	
Try
	{
		copy-item "$Current_Folder\*" $Notification_folder -recurse -force
		Write_Log -Message_Type "SUCCESS" -Message "Folder content $Current_Folder has been successfully copied"												
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Folder content $Current_Folder has not been copied"													
	}
	
Try
	{
		import-module "$Notification_folder\RunasUser"
		Write_Log -Message_Type "SUCCESS" -Message "Importation du module RunasUser avec succès"
		$RunasUser_Module_imported = $True
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "Erreur ^pendant l'importation du module RunasUser"				
		$RunasUser_Module_imported = $False
	}
	
	
If($RunasUser_Module_imported -eq $True)
	{
		$scriptblock = {
		powershell -ExecutionPolicy Bypass -NoProfile "C:\ProgramData\intune_notif\Notif_User.ps1"														
		}			
		
		Try
			{
				Invoke-AsCurrentUser -ScriptBlock $scriptblock | out-null
				Write_Log -Message_Type "SUCCESS" -Message "The script has been successfully executed in user context"															
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "An issue occured while executing the script in user context"															
			}					
	}	