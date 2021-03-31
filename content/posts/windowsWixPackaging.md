---
title: "Packaging adventures volume III: Wix"
date: 2021-03-30
hero: /images/posts/wixpkg.png
categories:
- Packaging
- Windows
---

Third and final chapter of the packaging adventures. The previous post about [Windows packaging](https://www.theimpostersyndrome.dev/posts/windowsuglypackaging/) was posted a couple of months ago and we learned how to create a simple Windows installer thanks to a Visual Studio extension. If you remember properly, there were some inconvenient like having two different installers (an MSI file for the app and an EXE file for the setup installer with the required extra components for our application). If you need a single EXE file, more modern-looking and cover the deficiencies of the previous packaging system, keep reading. I’ve got something for you!

---
##### What are we going to use?

* WiX toolset build tools that you can [download here](https://wixtoolset.org/releases/)
* Terminal

*`For this kind of process I use Python scripts but it is obviously not necessary. I just like to automate things and let my CI/CD Jenkins node do the magic on each build.`*

<br />

##### First setup:

What we really need to have as first step is your project's bin directory with all your application libraries and needed assemblies, resources, etc. So let’s assume you already have successfully compiled your application. Let’s also assume you have already installed the WiX toolset build tools on your Windows machine.

<br />

##### Copy the application's output to a temp directory:

This step could be ignored but I think it is good to have a temp directory where we can delete some files we know we don't need in the final application but maybe are important for your original project output directory. In my honest opinion, this can help you to have a big picture of how your final application installation directory will look like.

1. The first thing would be to create a temporal directory that we will use to create the package.
2. Second, copy your project’s output directory content to the temporal directory we just created in the previous step.
3. (Optional) Remove content you know you won’t need for your package like tests libraries.
4. (Optional) Copy other resources or external libraries you know your package will include.

<br />

##### Create a merge module for your application:

Wait, what is a merge module? In a nutshell, it is another kind of installer that contains your application’s components. In fact, it is not an installer but more like a database with the components your final installer will use at installation time. It helps you to modularize your software installation. This way you can use your merge module in different installers.

For this step, we will need what I call "utils" WXS file. There are tons of combinations to create your utils file, so I recommend you to check [WiX documentation](https://wixtoolset.org/documentation/manual/v3/overview/files.html) and create a file that fits your application needs. In my case, I am using this `utils.wxs` for each installer generation that, in a nutshell, indicates the full path for:

* Visual Studio project templates directory.
* Visual Studio devenv.exe file path. DevEnv stands for Visual Studio Integrated Development Environment or IDE.
* Visual Studio vcexpress.exe file path. It is the Microsoft Visual C++ express edition.

<details>
<summary>
Click here to expand the utils.wxs example file
</summary>

```XML
<?xml version="1.0" encoding="UTF-8"?>                                                                                                                                                                        
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension">                                                                                                                                                     

   <Fragment>                                                                                                                                                                                                 
       <Property Id="VS2010_PROJECTTEMPLATES_DIR">                                                                                                                                                            
           <RegistrySearch Id="VS2010DevEnvForProjectTemplatesSearch" Root="HKLM" Key="SOFTWARE\Microsoft\VisualStudio\10.0\Setup\VS" Name="EnvironmentDirectory" Type="raw">                                 
               <DirectorySearch Id="VS2010ProjectTemplatesPathSearch" Path="ProjectTemplates" Depth="1" />                                                                                                    
           </RegistrySearch>                                                                                                                                                                                  
       </Property>                                                                                                                                                                                            
       <Property Id="VS_PROJECTTEMPLATES_DIR">                                                                                                                                                                
           <RegistrySearch Id="VC2010DevEnvForProjectTemplatesSearch" Root="HKLM" Key="SOFTWARE\Microsoft\VisualStudio\SxS\VC7" Name="10.0" Type="directory">                                                 
               <DirectorySearch Id="VS2010ProjectsExpress" Path="Express" Depth="1">                                                                                                                          
                   <DirectorySearch Id="VS2010ProjectTemplatesPathSearch" Path="VCProjects" Depth="1" />                                                                                                      
               </DirectorySearch>                                                                                                                                                                             
           </RegistrySearch>                                                                                                                                                                                  
       </Property>                                                                                                                                                                                            
   </Fragment>                                                                                                                                                                                                
                                                                                                                                                                                                              
   <Fragment>                                                                                                                                                                                                 
       <Property Id="VS_WIZARDS_DIR">                                                                                                                                                                         
           <RegistrySearch Id="VS2010DevEnvForWIzardsSearch" Root="HKLM" Key="SOFTWARE\Microsoft\VisualStudio\SxS\VC7" Name="10.0" Type="directory">                                                          
               <DirectorySearch Id="VS2010WizardsPathSearch" Path="VCWizards" Depth="1" />                                                                                                                    
           </RegistrySearch>                                                                                                                                                                                  
       </Property>                                                                                                                                                                                            
   </Fragment>                                                                                                                                                                                                
                                                                                                                                                                                                              
   <Fragment>                                                                                                                                                                                                 
       <Property Id="VS2010DEVENV">                                                                                                                                                                           
           <RegistrySearch Id="VS2010DevEnvSearch" Root="HKLM" Key="SOFTWARE\Microsoft\VisualStudio\10.0\Setup\VS" Name="EnvironmentPath" Type="raw" />                                                       
       </Property>                                                                                                                                                                                            
   </Fragment>                                                                                                                                                                                                
                                                                                                                                                                                                              
   <Fragment>                                                                                                                                                                                                 
       <Property Id="VC2010EXPRESS_IDE">                                                                                                                                                                      
           <ComponentSearch Id="SearchForVcExpressIde2010Component" Guid="B455E8D3-90CB-47F6-AB7B-9B31E5DE6266" Type="file">                                                                                  
               <FileSearch Id="VcExpressIde2010" Name="vcexpress.exe"/>                                                                                                                                       
           </ComponentSearch>                                                                                                                                                                                 
       </Property>                                                                                                                                                                                            
   </Fragment>                                                                                                                                                                                                
                                                                                                                                                                                                              
   <Fragment>                                                                                                                                                                                                 
       <CustomAction Id="VS2010InstallVSTemplates" Property="VS2010DEVENV" ExeCommand="/InstallVSTemplates" Execute="deferred" Return="ignore" Impersonate="no" />                                            
       <PropertyRef Id="VS2010DEVENV" />                                                                                                                                                                      
                                                                                                                                                                                                              
       <InstallExecuteSequence>                                                                                                                                                                               
           <Custom Action="VS2010InstallVSTemplates" Before="InstallFinalize" Overridable="yes">VS2010DEVENV</Custom>                                                                                         
       </InstallExecuteSequence>                                                                                                                                                                              
   </Fragment>                                                                                                                                                                                                
                                                                                                                                                                                                              
   <Fragment>                                                                                                                                                                                                 
       <CustomAction Id="VC2010InstallVSTemplates" Property="VC2010EXPRESS_IDE" ExeCommand="/InstallVSTemplates" Execute="deferred" Return="ignore" Impersonate="no" />                                       
       <PropertyRef Id="VC2010EXPRESS_IDE" />                                                                                                                                                                 
                                                                                                                                                                                                              
       <InstallExecuteSequence>                                                                                                                                                                               
           <Custom Action="VC2010InstallVSTemplates" Before="InstallFinalize" Overridable="yes">VC2010EXPRESS_IDE</Custom>                                                                                    
       </InstallExecuteSequence>                                                                                                                                                                              
   </Fragment>                                                                                                                                                                                                
</Wix>
```

</details>
<br />

In addition, we are going to create our own WXS file listing all the files of our application that WiX will use to create the merge module. This `myapplication_msm.wxs` file will contain the next information:

* Module information: Which indicates an identifier, a language code (1033 for English) and the application version.
* Package information: Contained by the module node. It indicates the description of the application, an identifier and the manufacturer.
* Installation root directory: Contained by the module node.
* Application files list: Contained by the installation root directory node. It contains a series of `Component` nodes for each application file. It also can contain as much subdirectories as our application needs. Remember to use the path of the temp directory where your copied files are but, again, if you prefer to use the original application's output directory feel free to use it instead.

<details>
<summary>
Click here to expand the myapplication_msm.wxs example file
</summary>

```XML

<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension">
	<Module Id="_aa6621ec4f2z741k40513fccf98594e9" Language="1033" Version="1.0.0.0">
		<Package Comments="default" Description="My Application" Id="5f444669-4065-511f-0000-e8f2a895p853" Manufacturer="Fluendo S.A." />
		<Directory Id="TARGETDIR" Name="SourceDir">
			<Component Guid="cd1d08ha-8e8e-11eb-8b37-acbc32c4836a" Id="_6941f435t801b2bf0a07f95243999710">
				<File Id="_14e9914f04cbfdb44215b0057945591a" Name="myapplication.exe" Source="..\TheTempDirectoryWheMentionedBefore\myapplication.exe" />
			</Component>
			<Component Guid="cd2d08cb-8e5e-11eb-aa89-acbc67c4836a" Id="_d43gc53f70192c4941920aca8e7820ba">
				<File Id="_07f29056014c7f9567v08f88666e7553" Name="myapplication.dll" Source="..\TheTempDirectoryWheMentionedBefore\myapplication.dll" />
			</Component>
			<Directory Id="_8d777f385d3dftc4815d20f7496026dc" Name="data">
				<Component Guid="cd2f6bb7-8e5e-11eb-a82b-acbl35c4806b" Id="_513c13fd90d46ah30a51c2855b3095f3">
					<File Id="_dda569ac774j42e8f9515617ye62da01" Name="myapplication_logo.png" Source="..\TheTempDirectoryWheMentionedBefore\data\myapplication_logo.png" />
				</Component>
			</Directory>
		</Directory>
	</Module>
</Wix>

```

</details>
<br />

Hands on! Now we have all the necessary stuff to start. Let’s use the WiX toolset to generate the merge module. These are the commands we need:

> <WIX_TOOLSET_BIN_PATH>/candle.exe myapplication_msm.wxs utils.wxs
>> This command will generate a `utils.wixobj` and a `myapplication.wixobj` file that the next command will use.

> <WIX_TOOLSET_BIN_PATH>/light.exe myapplication_msm.wixobj utils.wixobj -o myapplication.msm -sval
>> This command will generate a `myapplication.msm` file. This is the merge module!

<br />

##### Create your application MSI file:

Let's create the simple installer file for our application. This file is an MSI file which will contain our application. We can also add some custom actions that will be applied pre or post installing our software. For that, we first need a `Config.wxi` file with some important information about the application:

<details>
<summary>
Click here to expand the Config.wxi example file
</summary>

```XML

<?xml version="1.0" encoding="utf-8"?>
<Include>

<?define ProductID = "*" ?>
<?define UpgradeCode = "22ge08b2-1234-415w-8287-e8faa740pt53" ?>
<?define Language = "1033" ?>
<?define Manufacturer = "My Company S.A." ?>
<?define Version = "1.0.0" ?>
<?define PackageComments = "default" ?>
<?define Description = "My Application Software" ?>
<?define WebSiteName = "https://www.myapplication.org/" ?>
<?define UserManualURL = "https://www.myapplication.com/en/help/" ?>
<?define ProductName = "My Application" ?>
<?define PlatformProgramFilesFolder = "ProgramFiles64Folder" ?>
<?define Platform = "x64" ?>
<?define UIType = "WixUI_InstallDir" ?>
<?define PrefixDir = "<PREFIX_DIRECTORY>" ?>
<?define PackageName = "myapplication" ?>

</Include>

```

</details>
<br />

Note that there is a field called `PrefixDir` to be defined. I have done this because you need to set there a path of your choice to place there some resources our installer will use (logo, banners, icons, etc.). It is also important to place the next `myapplication_msi.wxs` file in the same directory where `Config.wxi` is placed, since the WXS file will use the config WXI file to fulfill all that information where is required (check for all the `"$(var.foo)"` values).

<details>
<summary>
Click here to expand the myapplication_msi.wxs example file
</summary>

```XML

<?xml version="1.0" ?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension">
        <?include Config.wxi?>
        <Product Id="$(var.ProductID)" Language="$(var.Language)" Manufacturer="$(var.Manufacturer)" Name="$(var.ProductName)" UpgradeCode="$(var.UpgradeCode)" Version="$(var.Version)">
                <Package Comments="$(var.PackageComments)" Compressed="yes" Description="$(var.Description)" InstallPrivileges="elevated" InstallerVersion="405" Manufacturer="$(var.Manufacturer)"/>
                <Media Cabinet="product.cab" EmbedCab="yes" Id="1"/>
                <MajorUpgrade AllowSameVersionUpgrades="yes" DowngradeErrorMessage="A later version of [ProductName] is already installed. Setup will now exit"/>
                <Upgrade Id="24fe67b2-4065-411f-8287-e8faa892f853">
                        <UpgradeVersion Maximum="10.0.0" Minimum="0.0.0" Property="OLDAPPFOUND"/>
                </Upgrade>
                <Property Id="ARPPRODUCTICON" Value="MainIcon"/>
                <Property Id="ARPCONTACT" Value="$(var.Manufacturer)"/>
                <Property Id="ARPURLINFOABOUT" Value="$(var.WebSiteName)"/>
                <Property Id="ALLUSERS">1</Property>
                <CustomAction Execute="firstSequence" Id="SetWixUIInstallDir" Property="WIXUI_INSTALLDIR" Value="INSTALLDIR"/>
                <InstallUISequence>
                        <Custom Action="SetWixUIInstallDir" Before="CostInitialize"/>
                </InstallUISequence>
                <Property Id="WIXUI_INSTALLDIR" Value="INSTALLDIR"/>
                <UIRef Id="$(var.UIType)"/>
                <DirectoryRef Id="TARGETDIR">
                        <Directory Id="DesktopFolder" Name="Desktop">
                                <Component Guid="*" Id="ApplicationShortcutDesktop">
                                        <Condition>INSTALLDESKTOPSHORTCUT=1</Condition>
                                        <Shortcut Description="$(var.Description)" Icon="MainIcon" Id="ApplicationDesktopShortcut" Name="$(var.ProductName)" Target="[INSTALLDIR]myapplication.exe" WorkingDirectory="INSTALLDIR"/>
                                        <RemoveFolder Id="DesktopFolder" On="uninstall"/>
                                        <RegistryValue Key="Software/$(var.ProductName)" KeyPath="yes" Name="installed" Root="HKCU" Type="integer" Value="1"/>
                                </Component>
                        </Directory>
                </DirectoryRef>
                <Feature AllowAdvertise="no" Display="expand" Id="Desktop" Level="1" Title="Desktop Shortcut">
                        <ComponentRef Id="ApplicationShortcutDesktop"/>
                </Feature>
                <SetProperty After="CostFinalize" Id="CMRBIN" Value="[BIN.A961A077_4BD0_4C98_86BC_EE4A98CE550D]"/>
                <CustomAction Id="SetTARGETDIR" Property="TARGETDIR" Value="[ProgramFiles64Folder]\[ProductName]" Execute="firstSequence" />
                <Property Id="WixShellExecTarget" Value="[INSTALLDIR]myapplication.exe"/>
                <CustomAction BinaryKey="WixCA" DllEntry="WixShellExec" Id="LaunchApplication" Impersonate="yes" Return="ignore"/>
                <InstallExecuteSequence>
                        <Custom Action="SetTARGETDIR" Before="CostFinalize">TARGETDIR=""</Custom>
                        <Custom Action="LaunchApplication" After="InstallFinalize">(LAUNCHAPPLICATION = 1) AND (NOT Intalled OR UPGRADINGPRODUCTCODE)</Custom>
                </InstallExecuteSequence>
                <WixVariable Id="WixUIBannerBmp" Value="$(var.PrefixDir)/resources/installer-resources/banner.bmp"/>
                <WixVariable Id="WixUILicenseRtf" Value="$(var.PrefixDir)/resources/installer-resources/license.rtf"/>
                <Icon Id="MainIcon" SourceFile="$(var.PrefixDir)/resources/installer-resources/icon.ico"/>
                <PropertyRef Id="VS2010DEVENV"/>
                <PropertyRef Id="VC2010EXPRESS_IDE"/>
                <Directory Id="TARGETDIR" Name="SourceDir">
                        <Directory Id="$(var.PlatformProgramFilesFolder)" Name="ProgramFiles64Folder">
                                <Directory Id="INSTALLDIR" Name="$(var.ProductName)">
                                        <Directory Id="INSTALLBINDIR" Name="bin"/>
                                        <Merge DiskId="1" Id="_858186a923d8041fcb6283a1f2e368b4" Language="$(var.Language)" SourceFile="$(var.PackageName).msm"/>
                                </Directory>
                        </Directory>
                        <Directory Id="ProgramMenuFolder">
                                <Directory Id="ApplicationProgramsFolder" Name="$(var.ProductName)"/>
                        </Directory>
                </Directory>
                <Feature AllowAdvertise="no" ConfigurableDirectory="INSTALLDIR" Display="expand" Id="_408625b27785b1ffe76948c214d73f7e" Level="1" Title="myapplication">
                        <Feature Absent="disallow" Display="expand" Id="_858186a923d8041fcb6283a1f2e368b4" Level="1" Title="$(var.ProductName)">
                                <MergeRef Id="_858186a923d8041fcb6283a1f2e368b4"/>
                        </Feature>
                        <ComponentRef Id="ApplicationShortcut"/>
                </Feature>
                <DirectoryRef Id="ApplicationProgramsFolder">
                        <Component Guid="3d58b1b0-4293-11ea-9d8a-525400dd0bd4" Id="ApplicationShortcut">
                                <Shortcut Description="$(var.Description)" Icon="MainIcon" Id="ApplicationStartMenuShortcut" Name="$(var.ProductName)" Target="[INSTALLDIR]myapplication.exe" WorkingDirectory="INSTALLDIR"/>
                                <RemoveFolder Id="ApplicationProgramsFolder" On="uninstall"/>
                                <RegistryValue Key="Software\myapplication\1.0\x64" Name="InstallDir" Root="HKLM" Type="string" Value="[INSTALLDIR]"/>
                        </Component>
                </DirectoryRef>
                <Property Id="INSTALLDIR">
                        <RegistrySearch Id="InstallDirRegistrySearc" Key="Software\myapplication\1.0\x64" Name="InstallDir" Root="HKLM" Type="raw"/>
                </Property>
        </Product>
</Wix>

```

</details>
<br />

In this `myapplication_msi.wxs` file we have set a lot of important information of our application like:

* A `Product` node that contains the product information.
* A parameter that will check if there are already newer versions of our software already installed.
* A setup for the desktop shortcut.
* A custom action to launch the application after installing it.
* A custom action to set the installation directory.
* A setup for the banner, icon and readme sections.
* A setup for the execution of the merge module in the selected installation directory and setting a program menu folder with your application on it

Again. Let’s use the WiX toolset to generate the MSI file. These are the commands we need:

> <WIX_TOOLSET_BIN_PATH>/candle.exe myapplication_msi.wxs utils.wxs -ext WixUIExtension -ext WixUtilExtension -ext WixBalExtension
>> This command will generate again the `utils.wixobj` and a `myapplication_msi.wixobj` file that the next command will use.

> <WIX_TOOLSET_BIN_PATH>/light.exe myapplication_msi.wixobj utils.wixobj -o myapplication.msi -ext WixUIExtension -ext WixUtilExtension -ext WixBalExtension -sval
>> This command will generate a `myapplication.msi` file.

<br />

##### Create your application EXE file:

For this final step, we will need a `myapplication_burn.wxs` file. Please also note that we are using again the same `Config.wxi` file we used in the previous step for the MSI file generation. It basically contains: 

* Information about the application bundle.
* Detection for existing VC++ libraries already installed. *(Only if your application needs it)*
* A customization of the installation bootstrapper using two files called `SidebarTheme.wxl` and `SidebarTheme.xml`.
* Installer options like adding desktop shortcut, launch app after install or see user manual.
* Installation of the distributed VC++ redist file. *(Only if your application needs it. I have removed the part where the myapplication_msm.wxs and myapplication_msi.wxs files should use them)*
* Location of the previously created `myapplication.msi` file.

<details>
<summary>
Click here to expand the myapplication_burn.wxs example file
</summary>

```XML

<?xml version="1.0" ?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi" xmlns:bal="http://schemas.microsoft.com/wix/BalExtension" xmlns:util="http://schemas.microsoft.com/wix/UtilExtension">
    <?include Config.wxi?>
    <Bundle IconSourceFile="$(var.PrefixDir)/resources/installer-resources/icon.ico" Manufacturer="$(var.Manufacturer)" Name="$(var.ProductName)" UpgradeCode="$(var.UpgradeCode)" Version="$(var.Version)">
        <util:FileSearch Id="GetVC14X64Exists" Condition="VersionNT64" Variable="vc14x64Exists" Path="[System64Folder]vcruntime140.dll" Result="exists"/>

        <BootstrapperApplicationRef Id="WixStandardBootstrapperApplication.RtfLicense">
            <Payload SourceFile="$(var.PrefixDir)/resources/installer-resources/sidebar_windows.png"/>
            <bal:WixStandardBootstrapperApplication LicenseFile="$(var.PrefixDir)/resources/installer-resources/license.rtf" LocalizationFile="$(var.PrefixDir)/resources/installer-resources/SidebarTheme.wxl" LogoFile="$(var.PrefixDir)/resources/installer-resources/sidebar_windows.png" SuppressOptionsUI="yes" ThemeFile="$(var.PrefixDir)/resources/installer-resources/SidebarTheme.xml"/>
        </BootstrapperApplicationRef>

        <Variable Name="InstallDesktopShortcut" Value="1" bal:Overridable="yes"/>
        <Variable Name="LaunchApplication" Value="1" bal:Overridable="yes"/>
        <Variable Name="UserManualURL" Value="$(var.UserManualURL)" bal:Overridable="yes"/>

        <Chain>
            <ExePackage Cache="no" Compressed="yes" DetectCondition="vc14x64Exists" InstallCommand="/install /passive /norestart" PerMachine="yes" Permanent="yes" SourceFile="$(var.PrefixDir)/resources/merge-modules/vc140_redist.x64.exe" Vital="no">
                <ExitCode Behavior="success" Value="1638"/>
            </ExePackage>
          
            <MsiPackage SourceFile="$(var.PrefixDir)/Scripts/$(var.PackageName).msi">
                <MsiProperty Name="INSTALLDESKTOPSHORTCUT" Value="[InstallDesktopShortcut]"/>
                <MsiProperty Name="LAUNCHAPPLICATION" Value="[LaunchApplication]"/>
            </MsiPackage>
        </Chain>
    </Bundle>
</Wix>

```

</details>
<br />

For the `SidebarTheme.xml` and `SidebarTheme.wxl` files we have customized our installer step by step editing all what the user can see during the installation process. You can find plenty of SidebarTheme files on the internet since the installer is highly customizable. The wxl file contains the customization of the messages the installer will contain. The xml file will contain the visual customization of the views the installer will contain.

<details>
<summary>
Click here to expand the SidebarTheme.wxl example file
</summary>

```XML

<?xml version="1.0" encoding="utf-8"?>
<WixLocalization Culture="en-us" Language="1033" xmlns="http://schemas.microsoft.com/wix/2006/localization">
  <String Id="Caption">[WixBundleName] Setup</String>
  <String Id="Title">[WixBundleName]</String>
  <String Id="ConfirmCancelMessage">Are you sure you want to cancel?</String>
  <String Id="HelpHeader">Setup Help</String>
  <String Id="HelpText">/install | /repair | /uninstall | /layout [directory] - installs, repairs, uninstalls or
   creates a complete local copy of the bundle in directory. Install is the default.

/passive | /quiet -  displays minimal UI with no prompts or displays no UI and
   no prompts. By default UI and all prompts are displayed.

/norestart   - suppress any attempts to restart. By default UI will prompt before restart.
/log log.txt - logs to a specific file. By default a log file is created in %TEMP%.</String>
  <String Id="HelpCloseButton">&amp;Close</String>
  <String Id="InstallAcceptCheckbox">I &amp;agree to the license terms and conditions</String>
  <String Id="InstallOptionsButton">&amp;Options</String>
  <String Id="InstallInstallButton">&amp;Install</String>
  <String Id="InstallCloseButton">&amp;Close</String>
  <String Id="OptionsHeader">Setup Options</String>
  <String Id="OptionsLocationLabel">Install location:</String>
  <String Id="OptionsBrowseButton">&amp;Browse</String>
  <String Id="OptionsOkButton">&amp;OK</String>
  <String Id="OptionsCancelButton">&amp;Cancel</String>
  <String Id="ProgressHeader">Setup Progress</String>
  <String Id="ProgressLabel">Processing:</String>
  <String Id="OverallProgressPackageText">Initializing...</String>
  <String Id="ProgressCancelButton">&amp;Cancel</String>
  <String Id="ModifyHeader">Modify Setup</String>
  <String Id="ModifyRepairButton">&amp;Repair</String>
  <String Id="ModifyUninstallButton">&amp;Uninstall</String>
  <String Id="ModifyCloseButton">&amp;Close</String>
  <String Id="SuccessHeader">Setup Successful</String>
  <String Id="SuccessLaunchButton">&amp;Launch</String>
  <String Id="SuccessRestartText">You must restart your computer before you can use the software.</String>
  <String Id="SuccessRestartButton">&amp;Restart</String>
  <String Id="SuccessCloseButton">&amp;Finish</String>
  <String Id="FailureHeader">Setup Failed</String>
  <String Id="FailureHyperlinkLogText">One or more issues caused the setup to fail. Please fix the issues and then retry setup. For more information see the &lt;a href="#"&gt;log file&lt;/a&gt;.</String>
  <String Id="FailureRestartText">You must restart your computer to complete the rollback of the software.</String>
  <String Id="FailureRestartButton">&amp;Restart</String>
  <String Id="FailureCloseButton">&amp;Close</String>
  <String Id="WillInstall">[WixBundleName] will be installed on your device</String>
  <String Id="InstallLicenseLinkText">By installing you accept these &lt;a href="#"&gt;license terms&lt;/a&gt;</String>
  <String Id="AddDesktopShortcut">Add desktop shortcut</String>
  <String Id="LaunchApp">Launch [WixBundleName]</String>
  <String Id="UserManual">Click  &lt;a href="[UserManualURL]"&gt;here&lt;/a&gt; to view the user manual</String>
</WixLocalization>

```

</details>

<details>
<summary>
Click here to expand the SidebarTheme.xml example file
</summary>

```XML

<?xml version="1.0" encoding="utf-8"?>
<Theme xmlns="http://wixtoolset.org/schemas/thmutil/2010">
  <!-- This is set to Height="341" so that the side bar can be height=312 -->
  <Window Width="550" Height="450" HexStyle="100a0000" FontId="0">#(loc.Caption)</Window>
  <Font Id="0" Height="-12" Weight="500" Foreground="000000" Background="F0F0F0" >Segoe UI</Font>
  <Font Id="1" Height="-24" Weight="500" Foreground="000000">Segoe UI</Font>
  <Font Id="2" Height="-22" Weight="500" Foreground="000000" Background="F0F0F0">Segoe UI</Font>
  <Font Id="3" Height="-12" Weight="500" Foreground="000000" Background="F0F0F0" >Segoe UI</Font>
  <Font Id="4" Height="-12" Weight="500" Foreground="ff0000" Background="F0F0F0"  Underline="yes">Segoe UI</Font>
  <Font Id="5" Height="-24" Weight="500" Foreground="000000" Background="E0E0E0">Segoe UI</Font>
  <Image X="0" Y="0" Width="140" Height="521" ImageFile="sidebar_windows.png" Visible="yes"/>
  <Page Name="Help">
    <Button Name="HelpCancelButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.HelpCloseButton)</Button>
  </Page>
  <Page Name="Install">
    <Richedit Name="EulaRichedit" X="150" Y="80" Width="-11" Height="-100" TabStop="yes" FontId="0" HexStyle="0x800000" />
    <Checkbox Name="EulaAcceptCheckbox" X="150" Y="-80" Width="260" Height="20" TabStop="yes" FontId="3" HideWhenDisabled="yes">#(loc.InstallAcceptCheckbox)</Checkbox>
    <Text X="150" Y="0" Width="-11" Height="80" FontId="2" DisablePrefix="yes">#(loc.WillInstall)</Text>
    <Checkbox Name="InstallDesktopShortcut" X="150" Y="-60" Width="-11" Height="20" TabStop="yes" FontId="3">#(loc.AddDesktopShortcut)</Checkbox>
    <Checkbox Name="LaunchApplication" X="150" Y="-40" Width="-11" Height="20" TabStop="yes" FontId="3">#(loc.LaunchApp)</Checkbox>
    <Button Name="InstallButton" X="-91" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.InstallInstallButton)</Button>
    <Button Name="WelcomeCancelButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.InstallCloseButton)</Button>
  </Page>
  <Page Name="Options">
  </Page>
  <Page Name="Progress">
    <Text X="150" Y="30" Width="-11" Height="30" FontId="2" DisablePrefix="yes">#(loc.ProgressHeader)</Text>
    <Text X="150" Y="71" Width="70" Height="17" FontId="3" DisablePrefix="yes">#(loc.ProgressLabel)</Text>
    <Text Name="OverallProgressPackageText" X="150" Y="71" Width="-11" Height="17" FontId="3" DisablePrefix="yes">#(loc.OverallProgressPackageText)</Text>
    <Progressbar Name="OverallCalculatedProgressbar" X="150" Y="93" Width="-11" Height="15" />
    <Button Name="ProgressCancelButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.ProgressCancelButton)</Button>
  </Page>
  <Page Name="Modify">
    <Text X="150" Y="30" Width="-11" Height="100" FontId="2" DisablePrefix="yes">#(loc.ModifyHeader)</Text>
    <Button Name="RepairButton" X="-171" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0" HideWhenDisabled="yes">#(loc.ModifyRepairButton)</Button>
    <Button Name="UninstallButton" X="-91" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.ModifyUninstallButton)</Button>
    <Button Name="ModifyCancelButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.ModifyCloseButton)</Button>
  </Page>
  <Page Name="Success">
    <Text X="150" Y="30" Width="-11" Height="100" FontId="2" DisablePrefix="yes">#(loc.SuccessHeader)</Text>
    <Hypertext X="150" Y="120" Width="-11" Height="100" FontId="3" DisablePrefix="yes">#(loc.UserManual)</Hypertext>
    <Button Name="LaunchButton" X="-91" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0" HideWhenDisabled="yes">#(loc.SuccessLaunchButton)</Button>
    <Text Name="SuccessRestartText" X="150" Y="-51" Width="-11" Height="34" FontId="3" HideWhenDisabled="yes" DisablePrefix="yes">#(loc.SuccessRestartText)</Text>
    <Button Name="SuccessRestartButton" X="-91" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0" HideWhenDisabled="yes">#(loc.SuccessRestartButton)</Button>
    <Button Name="SuccessCancelButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.SuccessCloseButton)</Button>
  </Page>
  <Page Name="Failure">
    <Text X="150" Y="30" Width="-11" Height="30" FontId="2" DisablePrefix="yes">#(loc.FailureHeader)</Text>
    <Hypertext Name="FailureLogFileLink" X="150" Y="71" Width="-11" Height="51" FontId="3" TabStop="yes" HideWhenDisabled="yes">#(loc.FailureHyperlinkLogText)</Hypertext>
    <Hypertext Name="FailureMessageText" X="150" Y="131" Width="-11" Height="110" FontId="3" TabStop="yes" HideWhenDisabled="yes" />
    <Button Name="FailureCloseButton" X="-11" Y="-11" Width="75" Height="23" TabStop="yes" FontId="0">#(loc.FailureCloseButton)</Button>
  </Page>
</Theme>

```

</details>
<br />

Again and again! Let’s use the WiX toolset to generate the final EXE file. These are the commands we need:

> <WIX_TOOLSET_BIN_PATH>/candle.exe myapplication_burn.wxs utils.wxs -ext WixUIExtension -ext WixUtilExtension -ext WixBalExtension
>> This command will generate again the `utils.wixobj` and a `myapplication_burn.wixobj` file that the next command will use.

> <WIX_TOOLSET_BIN_PATH>/light.exe myapplication_burn.wixobj utils.wixobj -o myapplication.exe -ext WixUIExtension -ext WixUtilExtension -ext WixBalExtension -sval
>> This command will generate a `myapplication.exe` file.

<br />

##### Conclusions:

Just a few minutes after starting writing this post I realized that until now this was going to be the largest one by far, so it is very provable that maybe I removed or skipped a little step I consider not that much important that maybe could help someone else. If so please let me know and I will try to review it, but probably the best way to go is searching on the internet as I did the first time I created this installer EXE file generation, because there is a lot information out there about this topic that can help you.

WiX is by far the method I like the most to generate a Windows installer since generating it with the Visual Studio Installer projects extension lacks a lot of customizations that WiX doesn’t. Also is totally automatable and once you rule your process it is super easy to maintain it and rarely you will touch it again if it works as expected.

<br />

##### Sources:

* https://wixtoolset.org/releases/
* https://en.wikipedia.org/wiki/Merge_Module
* https://wixtoolset.org/documentation/manual/v3/overview/files.html
* https://wixtoolset.org/documentation/manual/v3/customactions/wixvsextension.html
* http://www.differencebetween.net/technology/software-technology/difference-between-msi-and-exe/

---
<br />

So this is another way to package your Windows applications and actually the one I'm currently using on my projects. This has been a really big post, you must be exhausted! I hope this WiX installer creation process helps a lot of people. Of course you can use the WiX installer creation wizard for a better understanding and a little of help but in order to automate things and actually controlling everything in your package creation, scripting the process is a very good way to go. Automate for the win!

Do you know any other method to create automatable and also customizable installer files for Windows? I would like to know some other experiences with other interesting packagers! As always, if you have any tip to improve this process or you have any question, please let me know in the comments below. See you all in the next post. Happy hacking!
