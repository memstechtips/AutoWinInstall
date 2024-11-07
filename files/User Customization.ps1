# Check if script is running as Administrator
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Try {
        Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit
    } Catch {
        Write-Host "Failed to run as Administrator. Please rerun with elevated privileges."
        Exit
    }
}

# Disable automatic restart of explorer.exe
reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoRestartShell /t REG_DWORD /d 0 /f
# Set desktop background to black
reg.exe add "HKEY_CURRENT_USER\Control Panel\Colors" /v Background /t REG_SZ /d "0 0 0" /f
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Stop explorer.exe
Stop-Process -Name explorer -Force

# Define the XAML UI as a string
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="User Account Customization" Width="700" Height="500" WindowStyle="None" WindowStartupLocation="CenterScreen"
        Background="Transparent" AllowsTransparency="True" Foreground="#ffffff" FontFamily="Futura">
    
    <WindowChrome.WindowChrome>
        <WindowChrome CaptionHeight="0" ResizeBorderThickness="0" GlassFrameThickness="0"/>
    </WindowChrome.WindowChrome>

    <Window.Resources>
        <!-- Button style when enabled -->
        <Style x:Key="PrimaryButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#FFDE00"/> <!-- Your primary yellow -->
            <Setter Property="Foreground" Value="Black"/> <!-- Contrast text color -->
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="FontFamily" Value="Futura"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="5">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <!-- Hover effect -->
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#FFE533"/> <!-- Lighter yellow on hover -->
                            </Trigger>
                            <!-- Disabled state -->
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Background" Value="#FFEB99"/> <!-- Lighter yellow for disabled -->
                                <Setter Property="Foreground" Value="LightGray"/> <!-- Lighter grey text for disabled -->
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border CornerRadius="15" Background="#202020" Opacity="0.95">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="165*"/>
                <!-- Header Section -->
                <RowDefinition Height="115" />
                <!-- Defender Section -->
                <RowDefinition Height="128*" />
                <!-- UAC Section -->
                <RowDefinition Height="Auto" MinHeight="92.001"/>
                <!-- Restart Button Section -->
            </Grid.RowDefinitions>

            <!-- Header Section -->
            <TextBlock Text="User Account Customization" FontSize="34" HorizontalAlignment="Center" Margin="0,30,0,83" Width="424">
                <TextBlock.Effect>
                    <DropShadowEffect/>
                </TextBlock.Effect>
            </TextBlock>
            
            <StackPanel Orientation="Vertical" Margin="32,97,32,0" VerticalAlignment="Top" Grid.Row="0" Height="58">
                <TextBlock x:Name="StatusMessage" Text="Recommended User settings have been applied successfully ✓" FontSize="20"/>
                <TextBlock Width="634" Text="Visit 'C:\Windows\Setup\Scripts' to Reapply or Revert Settings." FontSize="16" FontStyle="Italic" Height="22" HorizontalAlignment="Left" Margin="0,0,124,-34"/>
            </StackPanel>

            <Rectangle Fill="Gray" Height="2" Width="700" HorizontalAlignment="Center" Margin="0,163,0,0"/>

            <!-- Defender Section in its own StackPanel -->
            <StackPanel Orientation="Vertical" HorizontalAlignment="Center" VerticalAlignment="Top" Height="107" Width="586" Grid.Row="1" Margin="0,10,0,0" Grid.RowSpan="2">
                <TextBlock Text="Checking Windows Defender Status . . ." x:Name="DefenderStatusText" Margin="0,2,0,10" HorizontalAlignment="Center" FontSize="22">
                    <TextBlock.Effect>
                        <DropShadowEffect/>
                    </TextBlock.Effect>
                </TextBlock>
                <TextBlock Width="634" Text="Default=Disabled. If Enabled here or with a script later, it can't be disabled again." FontSize="16" FontStyle="Italic" Height="22" HorizontalAlignment="Left" Margin="0,-8,0,-8"/>
                <Button x:Name="EnableDefenderButton" Content="Enable Defender" Width="150" Height="35" 
                        Style="{StaticResource PrimaryButtonStyle}" HorizontalAlignment="Center" Margin="5,5,5,-65"/>
            </StackPanel>

            <Rectangle Grid.Row="2" Fill="Gray" Height="2" Width="700" HorizontalAlignment="Center" Margin="0,7,0,119"/>

            <!-- UAC Section in its own StackPanel -->
            <StackPanel Orientation="Vertical" HorizontalAlignment="Center" VerticalAlignment="Top" Grid.Row="2" Margin="0,14,0,0" Height="114" Width="586">
                <TextBlock x:Name="UACStatusText" Text="Checking UAC Status . . ." FontSize="22" HorizontalAlignment="Center">
                    <TextBlock.Effect>
                        <DropShadowEffect/>
                    </TextBlock.Effect>
                </TextBlock>
                <TextBlock Width="634" Text="Default=Disabled. Enable UAC here or in Control Panel later if needed." FontSize="16" FontStyle="Italic" Height="22" HorizontalAlignment="Left" Margin="0,-8,0,-40"/>
                <Button x:Name="EnableUACButton" Content="Enable UAC" Width="150" Height="35" 
                        Style="{StaticResource PrimaryButtonStyle}" HorizontalAlignment="Center" Margin="5,5,5,-115" IsEnabled="False"/>
            </StackPanel>

            <Rectangle Grid.Row="3" Fill="Gray" Height="2" Width="700" HorizontalAlignment="Center" Margin="0,10,0,80"/>

            <!-- Restart Button Section -->
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top" Margin="0,65,0,0" Grid.Row="3" Height="0" Width="0"/>
            <Button Content="Restart to Apply Changes" x:Name="RestartButton" Margin="225,25,225,25" Grid.Row="3" 
                    Style="{StaticResource PrimaryButtonStyle}">
                <Button.Triggers>
                    <EventTrigger RoutedEvent="ButtonBase.Click">
                        <BeginStoryboard>
                            <Storyboard>
                                <DoubleAnimation Storyboard.TargetProperty="Opacity" To="0.5" Duration="0:0:0.2"/>
                                <DoubleAnimation Storyboard.TargetProperty="Opacity" To="1.0" BeginTime="0:0:0.2" Duration="0:0:0.2"/>
                            </Storyboard>
                        </BeginStoryboard>
                    </EventTrigger>
                </Button.Triggers>
            </Button>
        </Grid>
    </Border>
</Window>
"@

# Define Unicode characters for checkmark and cross
$checkmark = [char]0x2713  # Unicode for ✓
$cross = [char]0x2717      # Unicode for ✗

# Load XAML
Add-Type -AssemblyName PresentationFramework
[xml]$xamlParsed = $xaml
$xamlWindow = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xamlParsed))

# Applies User Account Settings
Try {

# Uninstall Copilot
Get-AppxPackage -Name 'Microsoft.Copilot' | Remove-AppxPackage
Get-AppxPackage -Name 'Microsoft.Windows.Ai.Copilot.Provider' | Remove-AppxPackage

$MultilineComment = @"
Windows Registry Editor Version 5.00

; EASE OF ACCESS
; disable narrator
[HKEY_CURRENT_USER\Software\Microsoft\Narrator\NoRoam]
"DuckAudio"=dword:00000000
"WinEnterLaunchEnabled"=dword:00000000
"ScriptingEnabled"=dword:00000000
"OnlineServicesEnabled"=dword:00000000
"EchoToggleKeys"=dword:00000000

; disable narrator settings
[HKEY_CURRENT_USER\Software\Microsoft\Narrator]
"NarratorCursorHighlight"=dword:00000000
"CoupleNarratorCursorKeyboard"=dword:00000000
"IntonationPause"=dword:00000000
"ReadHints"=dword:00000000
"ErrorNotificationType"=dword:00000000
"EchoChars"=dword:00000000
"EchoWords"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NarratorHome]
"MinimizeType"=dword:00000000
"AutoStart"=dword:00000000

; disable ease of access settings 
[HKEY_CURRENT_USER\Software\Microsoft\Ease of Access]
"selfvoice"=dword:00000000
"selfscan"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="4194"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"Flags"="2"
"AutoRepeatRate"="0"
"AutoRepeatDelay"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000

; CLOCK AND REGION
; disable notify me when the clock changes
[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000

; APPEARANCE AND PERSONALIZATION
; open file explorer to this pc
; show file name extensions
; disable display file size information in folder tips
; disable show pop-up description for folder and desktop items
; disable show preview handlers in preview pane
; disable show status bar
; disable show sync provider notifications
; disable use sharing wizard
; disable animations in the taskbar
; enable show thumbnails instead of icons
; disable show translucent selection rectangle
; disable use drop shadows for icon labels on the desktop
; more pins personalization start
; disable show account-related notifications
; disable show recently opened items in start, jump lists and file explorer
; left taskbar alignment
; remove chat from taskbar
; remove task view from taskbar
; remove copilot from taskbar
; disable show recommendations for tips shortcuts new apps and more
; disable share any window from my taskbar
; disable snap window settings - SnapAssist to JointResize Entries
; alt tab open windows only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001
"HideFileExt"=dword:00000000
"FolderContentsInfoTip"=dword:00000000
"ShowInfoTip"=dword:00000000
"ShowPreviewHandlers"=dword:00000000
"ShowStatusBar"=dword:00000000
"ShowSyncProviderNotifications"=dword:00000000
"SharingWizardOn"=dword:00000000
"TaskbarAnimations"=dword:0
"IconsOnly"=dword:0
"ListviewAlphaSelect"=dword:0
"ListviewShadow"=dword:0
"Start_Layout"=dword:00000001
"Start_AccountNotifications"=dword:00000000
"Start_TrackDocs"=dword:00000000 
"TaskbarAl"=dword:00000000
"TaskbarMn"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"ShowCopilotButton"=dword:00000000
"Start_IrisRecommendations"=dword:00000000
"TaskbarSn"=dword:00000000
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000
"MultiTaskingAltTabFilter"=dword:00000003

; hide frequent folders in quick access
; disable show files from office.com
; show all taskbar icons on Windows 10
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowFrequent"=dword:00000000
"ShowCloudFilesInQuickAccess"=dword:00000000
"EnableAutoTray"=dword:00000000

; enable display full path in the title bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState]
"FullPath"=dword:00000001

; HARDWARE AND SOUND
; sound communications do nothing
[HKEY_CURRENT_USER\Software\Microsoft\Multimedia\Audio]
"UserDuckingPreference"=dword:00000003

; disable enhance pointer precision
; mouse fix (no accel with epp on)
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="0"
"MouseThreshold1"="0"
"MouseThreshold2"="0"
"MouseSensitivity"="10"
"SmoothMouseXCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	C0,CC,0C,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

; SYSTEM AND SECURITY
; set appearance options to custom
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:3

; disable animate controls and elements inside windows
; disable fade or slide menus into view
; disable fade or slide tooltips into view
; disable fade out menu items after clicking
; disable show shadows under mouse pointer
; disable show shadows under windows
; disable slide open combo boxes
; disable smooth-scroll list boxes
; enable smooth edges of screen fonts
; 100% dpi scaling
; disable fix scaling for apps
; disable menu show delay
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex(2):90,12,03,80,10,00,00,00
"FontSmoothing"="2"
"LogPixels"=dword:00000060
"Win8DpiScaling"=dword:00000001
"EnablePerProcessSystemDPI"=dword:00000000
"MenuShowDelay"="0"

; --IMMERSIVE CONTROL PANEL--
; PRIVACY
; disable show me notification in the settings app
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
"EnableAccountNotifications"=dword:00000000

; disable voice activation
[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationLastUsed"=dword:00000000

; disable other devices 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync]
"Value"="Deny"

; disable let websites show me locally relevant content by accessing my language list 
[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"HttpAcceptLanguageOptOut"=dword:00000001

; disable let windows improve start and search results by tracking app launches  
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

; disable personal inking and typing dictionary
[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
"RestrictImplicitTextCollection"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
"HarvestContacts"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
"AcceptedPrivacyPolicy"=dword:00000000

; feedback frequency never
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000
"PeriodInNanoSeconds"=-

; SEARCH
; disable search highlights
; disable search history
; disable safe search
; disable cloud content search for work or school account
; disable cloud content search for microsoft account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000000
"IsDeviceSearchHistoryEnabled"=dword:00000000
"SafeSearchMode"=dword:00000000
"IsAADCloudSearchEnabled"=dword:00000000
"IsMSACloudSearchEnabled"=dword:00000000

; EASE OF ACCESS
; disable magnifier settings 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ScreenMagnifier]
"FollowCaret"=dword:00000000
"FollowNarrator"=dword:00000000
"FollowMouse"=dword:00000000
"FollowFocus"=dword:00000000

; GAMING
; disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

; disable enable open xbox game bar using game controller
; enable game mode
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000
"AutoGameModeEnabled"=dword:00000001

; other settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000
"AudioEncodingBitrate"=dword:0001f400
"AudioCaptureEnabled"=dword:00000000
"CustomVideoEncodingBitrate"=dword:003d0900
"CustomVideoEncodingHeight"=dword:000002d0
"CustomVideoEncodingWidth"=dword:00000500
"HistoricalBufferLength"=dword:0000001e
"HistoricalBufferLengthUnit"=dword:00000001
"HistoricalCaptureEnabled"=dword:00000000
"HistoricalCaptureOnBatteryAllowed"=dword:00000001
"HistoricalCaptureOnWirelessDisplayAllowed"=dword:00000001
"MaximumRecordLength"=hex(b):00,D0,88,C3,10,00,00,00
"VideoEncodingBitrateMode"=dword:00000002
"VideoEncodingResolutionMode"=dword:00000002
"VideoEncodingFrameRateMode"=dword:00000000
"EchoCancellationEnabled"=dword:00000001
"CursorCaptureEnabled"=dword:00000000
"VKToggleGameBar"=dword:00000000
"VKMToggleGameBar"=dword:00000000
"VKSaveHistoricalVideo"=dword:00000000
"VKMSaveHistoricalVideo"=dword:00000000
"VKToggleRecording"=dword:00000000
"VKMToggleRecording"=dword:00000000
"VKTakeScreenshot"=dword:00000000
"VKMTakeScreenshot"=dword:00000000
"VKToggleRecordingIndicator"=dword:00000000
"VKMToggleRecordingIndicator"=dword:00000000
"VKToggleMicrophoneCapture"=dword:00000000
"VKMToggleMicrophoneCapture"=dword:00000000
"VKToggleCameraCapture"=dword:00000000
"VKMToggleCameraCapture"=dword:00000000
"VKToggleBroadcast"=dword:00000000
"VKMToggleBroadcast"=dword:00000000
"MicrophoneCaptureEnabled"=dword:00000000
"SystemAudioGain"=hex(b):10,27,00,00,00,00,00,00
"MicrophoneGain"=hex(b):10,27,00,00,00,00,00,00

; TIME & LANGUAGE 
; disable show the voice typing mic button
; disable typing insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"IsVoiceTypingKeyEnabled"=dword:00000000
"InsightsEnabled"=dword:00000000

; disable capitalize the first letter of each sentence
; disable play key sounds as i type
; disable add a period after i double-tap the spacebar
; disable show key background
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"EnableAutoShiftEngage"=dword:00000000
"EnableKeyAudioFeedback"=dword:00000000
"EnableDoubleTapSpace"=dword:00000000
"IsKeyBackgroundEnabled"=dword:00000000

; PERSONALIZATION
; dark theme 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"AppsUseLightTheme"=dword:00000000
"SystemUsesLightTheme"=dword:00000000
"EnableTransparency"=dword:00000001

; disable web search in start menu 
[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; Remove meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-
"HideSCAMeetNow"=dword:00000001

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000000

; disable use dynamic lighting on my devices
; disable compatible apps in the forground always control lighting
; disable match my windows accent color
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000
"ControlledByForegroundApp"=dword:00000000
"UseSystemAccentColor"=dword:00000000

; DEVICES
; disable let windows manage my default printer
[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows]
"LegacyDefaultPrinterMode"=dword:00000001

; disable write with your fingertip
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\EmbeddedInkControl]
"EnableInkingWithTouch"=dword:00000000

; SYSTEM
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM]
"UseDpiScaling"=dword:00000000

; disable variable refresh rate & enable optimizations for windowed games
[HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences]
"DirectXUserGlobalSettings"="SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;"

; disable notifications
; Disable Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications]
"ToastEnabled"=dword:00000000
"LockScreenToastEnabled"=dword:00000000

; Disable Allow Notifications to Play Sounds
; Disable Notifications on Lock Screen
; Disable Show Reminders and VoIP Calls Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings]
"NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND"=dword:00000000
"NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK"=dword:00000000
"NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp]
"Enabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000000

; disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; battery options optimize for video quality
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
"VideoQualityOnBattery"=dword:00000001

; UWP Apps
; disable windows input experience preload
[HKEY_CURRENT_USER\Software\Microsoft\input]
"IsInputAppPreloadEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Dsh]
"IsPrelaunchEnabled"=dword:00000000

; disable copilot
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

; DISABLE ADVERTISING & PROMOTIONAL
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"ContentDeliveryAllowed"=dword:00000000
"FeatureManagementEnabled"=dword:00000000
"OemPreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEnabled"=dword:00000000
"PreInstalledAppsEverEnabled"=dword:00000000
"RotatingLockScreenEnabled"=dword:00000000
"RotatingLockScreenOverlayEnabled"=dword:00000000
"SilentInstalledAppsEnabled"=dword:00000000
"SlideshowEnabled"=dword:00000000
"SoftLandingEnabled"=dword:00000000
"SubscribedContent-310093Enabled"=dword:00000000
"SubscribedContent-314563Enabled"=dword:00000000
"SubscribedContent-338388Enabled"=dword:00000000
"SubscribedContent-338389Enabled"=dword:00000000
"SubscribedContent-338393Enabled"=dword:00000000
"SubscribedContent-353694Enabled"=dword:00000000
"SubscribedContent-353696Enabled"=dword:00000000
"SubscribedContent-353698Enabled"=dword:00000000
"SubscribedContentEnabled"=dword:00000000
"SystemPaneSuggestionsEnabled"=dword:00000000

; OTHER
; remove gallery
[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
"System.IsPinnedToNameSpaceTree"=dword:00000000

; restore the classic context menu
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; removes OneDrive Setup
[-HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
"OneDriveSetup"=-

; Hides the Try New Outlook Button
[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Options\General]
"HideNewOutlookToggle"=dword:00000000

; Cleans up Taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband]
"FavoritesRemovedChanges"=dword:00000003
"FavoritesResolve"=hex:31,03,00,00,4c,00,00,00,01,14,02,00,00,00,00,00,c0,00,\
  00,00,00,00,00,46,83,00,80,00,20,00,00,00,be,33,35,e7,d1,24,db,01,be,33,35,\
  e7,d1,24,db,01,25,b3,7a,4d,05,84,da,01,97,01,00,00,00,00,00,00,01,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,a0,01,3a,00,1f,80,c8,27,34,1f,10,5c,10,\
  42,aa,03,2e,e4,52,87,d6,68,26,00,01,00,26,00,ef,be,12,00,00,00,85,35,2b,d7,\
  d1,24,db,01,9b,e4,33,e7,d1,24,db,01,ab,5a,34,e7,d1,24,db,01,14,00,56,00,31,\
  00,00,00,00,00,56,59,b9,b3,11,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,\
  ef,be,56,59,b9,b3,56,59,b9,b3,2e,00,00,00,f2,69,01,00,00,00,04,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,ef,80,fc,00,54,00,61,00,73,00,6b,00,42,00,\
  61,00,72,00,00,00,16,00,0e,01,32,00,97,01,00,00,81,58,c4,3a,20,00,46,49,4c,\
  45,45,58,7e,31,2e,4c,4e,4b,00,00,7c,00,09,00,04,00,ef,be,56,59,b9,b3,56,59,\
  b9,b3,2e,00,00,00,c3,6a,01,00,00,00,02,00,00,00,00,00,00,00,00,00,52,00,00,\
  00,00,00,db,dc,91,00,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,\
  6f,00,72,00,65,00,72,00,2e,00,6c,00,6e,00,6b,00,00,00,40,00,73,00,68,00,65,\
  00,6c,00,6c,00,33,00,32,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,32,00,32,00,\
  30,00,36,00,37,00,00,00,1c,00,22,00,00,00,1e,00,ef,be,02,00,55,00,73,00,65,\
  00,72,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,1c,00,12,00,00,00,2b,00,\
  ef,be,7c,4c,37,e7,d1,24,db,01,1c,00,42,00,00,00,1d,00,ef,be,02,00,4d,00,69,\
  00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,00,2e,00,57,00,69,00,6e,00,64,00,\
  6f,00,77,00,73,00,2e,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,00,\
  00,1c,00,00,00,9a,00,00,00,1c,00,00,00,01,00,00,00,1c,00,00,00,2d,00,00,00,\
  00,00,00,00,99,00,00,00,11,00,00,00,03,00,00,00,0e,76,ea,84,10,00,00,00,00,\
  43,3a,5c,55,73,65,72,73,5c,6d,65,6d,5c,41,70,70,44,61,74,61,5c,52,6f,61,6d,\
  69,6e,67,5c,4d,69,63,72,6f,73,6f,66,74,5c,49,6e,74,65,72,6e,65,74,20,45,78,\
  70,6c,6f,72,65,72,5c,51,75,69,63,6b,20,4c,61,75,6e,63,68,5c,55,73,65,72,20,\
  50,69,6e,6e,65,64,5c,54,61,73,6b,42,61,72,5c,46,69,6c,65,20,45,78,70,6c,6f,\
  72,65,72,2e,6c,6e,6b,00,00,60,00,00,00,03,00,00,a0,58,00,00,00,00,00,00,00,\
  64,65,73,6b,74,6f,70,2d,6e,76,6a,67,69,71,33,00,1e,48,b8,ac,e6,93,44,44,85,\
  d1,06,17,eb,52,3b,ea,cc,41,5d,b0,c4,90,ef,11,b9,08,00,0c,29,5b,06,9a,1e,48,\
  b8,ac,e6,93,44,44,85,d1,06,17,eb,52,3b,ea,cc,41,5d,b0,c4,90,ef,11,b9,08,00,\
  0c,29,5b,06,9a,45,00,00,00,09,00,00,a0,39,00,00,00,31,53,50,53,b1,16,6d,44,\
  ad,8d,70,48,a7,48,40,2e,a4,3d,78,8c,1d,00,00,00,68,00,00,00,00,48,00,00,00,\
  d4,d9,2d,27,b2,34,c5,4f,ad,3b,78,a5,c4,f6,71,2d,00,00,00,00,00,00,00,00,00,\
  00,00,00
"Favorites"=hex:00,a4,01,00,00,3a,00,1f,80,c8,27,34,1f,10,5c,10,42,aa,03,2e,e4,\
  52,87,d6,68,26,00,01,00,26,00,ef,be,12,00,00,00,85,35,2b,d7,d1,24,db,01,9b,\
  e4,33,e7,d1,24,db,01,ab,5a,34,e7,d1,24,db,01,14,00,56,00,31,00,00,00,00,00,\
  56,59,b9,b3,11,00,54,61,73,6b,42,61,72,00,40,00,09,00,04,00,ef,be,56,59,b9,\
  b3,56,59,b9,b3,2e,00,00,00,f2,69,01,00,00,00,04,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,ef,80,fc,00,54,00,61,00,73,00,6b,00,42,00,61,00,72,00,00,\
  00,16,00,12,01,32,00,97,01,00,00,81,58,c4,3a,20,00,46,49,4c,45,45,58,7e,31,\
  2e,4c,4e,4b,00,00,7c,00,09,00,04,00,ef,be,56,59,b9,b3,56,59,b9,b3,2e,00,00,\
  00,c3,6a,01,00,00,00,02,00,00,00,00,00,00,00,00,00,52,00,00,00,00,00,db,dc,\
  91,00,46,00,69,00,6c,00,65,00,20,00,45,00,78,00,70,00,6c,00,6f,00,72,00,65,\
  00,72,00,2e,00,6c,00,6e,00,6b,00,00,00,40,00,73,00,68,00,65,00,6c,00,6c,00,\
  33,00,32,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,32,00,32,00,30,00,36,00,37,\
  00,00,00,1c,00,12,00,00,00,2b,00,ef,be,7c,4c,37,e7,d1,24,db,01,1c,00,42,00,\
  00,00,1d,00,ef,be,02,00,4d,00,69,00,63,00,72,00,6f,00,73,00,6f,00,66,00,74,\
  00,2e,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,2e,00,45,00,78,00,70,00,\
  6c,00,6f,00,72,00,65,00,72,00,00,00,1c,00,26,00,00,00,1e,00,ef,be,02,00,53,\
  00,79,00,73,00,74,00,65,00,6d,00,50,00,69,00,6e,00,6e,00,65,00,64,00,00,00,\
  1c,00,00,00,ff
"FavoritesChanges"=dword:00000002
"FavoritesVersion"=dword:00000002

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\AuxilliaryPins]
"MailPin"=dword:00000000
"TFLPin"=dword:00000000
"CopilotPWAPin"=dword:00000000
"@
                Set-Content -Path "$env:TEMP\Optimize_User_Registry.reg" -Value $MultilineComment -Force
                
                # Import registry file silently
                Regedit.exe /S "$env:TEMP\Optimize_User_Registry.reg"

# Set Wallpaper
$defaultWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img0_3840x2160.jpg"
$darkModeWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img19_1920x1200.jpg"

function Set-Wallpaper ($wallpaperPath) {
    reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "$wallpaperPath" /f | Out-Null
    # Notify the system of the change
    rundll32.exe user32.dll, UpdatePerUserSystemParameters
}

# Check Windows version
$windowsVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild

# Apply appropriate wallpaper based on Windows version or existence of dark mode wallpaper
if ($windowsVersion -ge 22000) {  # Assuming Windows 11 starts at build 22000
    if (Test-Path $darkModeWallpaperPath) {
        Set-Wallpaper -wallpaperPath $darkModeWallpaperPath
    }
} else {
    # Apply default wallpaper for Windows 10
    Set-Wallpaper -wallpaperPath $defaultWallpaperPath
}

    # Update the XAML TextBlock with the success message
    $xamlWindow.FindName("StatusMessage").Text = "Recommended User settings have been applied successfully $checkmark"
} Catch {
    # Update the XAML TextBlock with the failure message
    $xamlWindow.FindName("StatusMessage").Text = "Failed to apply Recommended User settings $cross"
}

# Check Windows Defender status by inspecting the registry key
$defenderStatus = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" -Name "Start" -ErrorAction SilentlyContinue

If ($defenderStatus.Start -eq 4) {
    # Windows Defender is disabled, update the Defender TextBlock and make button available
    $xamlWindow.FindName("DefenderStatusText").Text = "Windows Defender is Disabled."
    $xamlWindow.FindName("EnableDefenderButton").IsEnabled = $true  # Enable the button
} Else {
    # Windows Defender is enabled, update the Defender TextBlock and disable the button
    $xamlWindow.FindName("DefenderStatusText").Text = "Windows Defender is Enabled."
    $xamlWindow.FindName("EnableDefenderButton").IsEnabled = $false  # Disable the button
}

# Check UAC status by inspecting the registry key
$uacStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue

If ($uacStatus.EnableLUA -eq 0) {
    # UAC is disabled, update the UAC TextBlock and make button available
    $xamlWindow.FindName("UACStatusText").Text = "User Account Control is Disabled."
    $xamlWindow.FindName("EnableUACButton").IsEnabled = $true  # Enable the button
} Else {
    # UAC is enabled, update the UAC TextBlock and disable the button
    $xamlWindow.FindName("UACStatusText").Text = "User Account Control is Enabled."
    $xamlWindow.FindName("EnableUACButton").IsEnabled = $false  # Disable the button
}

# Define Event Handlers for Defender and UAC
$xamlWindow.FindName("EnableDefenderButton").Add_Click({
    $result = [System.Windows.MessageBox]::Show("Are you sure you want to enable Windows Defender?", "Confirm Action", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    If ($result -eq 'Yes') {
        Try {
            $MultilineComment = @"
Windows Registry Editor Version 5.00

; Enables Windows Defender to start in Windows Security
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Sense]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdBoot]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdFilter]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisDrv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WdNisSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend]
"Start"=dword:00000002
"@
Set-Content -Path "$env:TEMP\Enable_Windows_Defender.reg" -Value $MultilineComment -Force
# edit reg file
$path = "$env:TEMP\Enable_Windows_Defender.reg"
(Get-Content $path) -replace "\?","$" | Out-File $path
# import reg file
Regedit.exe /S "$env:TEMP\Enable_Windows_Defender.reg"
            [System.Windows.MessageBox]::Show("Windows Defender has been enabled. Restart to Apply Changes.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        } Catch {
            [System.Windows.MessageBox]::Show("Failed to enable Windows Defender.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    }
})

$xamlWindow.FindName("EnableUACButton").Add_Click({
    $result = [System.Windows.MessageBox]::Show("Are you sure you want to enable UAC?", "Confirm Action", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    If ($result -eq 'Yes') {
        Try {
            Write-Output "Enable UAC Button Clicked"
            cmd.exe /c reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 3 /f
            [System.Windows.MessageBox]::Show("User Account Control (UAC) has been successfully enabled.", "Success", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        } Catch {
            [System.Windows.MessageBox]::Show("Failed to enable UAC.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    }
})

$xamlWindow.FindName("RestartButton").Add_Click({
    $result = [System.Windows.MessageBox]::Show("Are you sure you want to restart your computer?", "Confirm Restart", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    If ($result -eq 'Yes') {
        Try {
            Write-Output "Restart Button Clicked"
            reg.exe add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoRestartShell /t REG_DWORD /d 1 /f
            Start-Process -FilePath "shutdown.exe" -ArgumentList "/r /t 1" -NoNewWindow
        } Catch {
            [System.Windows.MessageBox]::Show("Failed to restart the computer.", "Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    }
})
# Show the Window
$xamlWindow.ShowDialog()
