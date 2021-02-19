---
title: "Packaging adventures volume I: macOS"
date: 2020-08-20
hero: /images/posts/awesomepkgmac.png
categories:
- Packaging
- macOS
---

If I had to define working (right) as a macOS developer out of the bounds of Xcode IDE with one expression I would do it as: "Oh, there is one more easy not easy thing Apple wants us to do to make it work properly". Lately I've been working and struggling hard with packaging the multiplatform application I work on. When Apple released macOS Catalina they introduced a lot of security changes and a lot of applications suddenly stopped working turning App Store outsider developers lifes in a little nightmare.

In our case the problem was that our application uses the webcam and as a user you need to grant permissions, but for that you need to define why you application needs permissions in the `Info.plist` file, but for Catalina to relate the reason you defined for using the camera with your application you can not use a script that calls the `.exe` file as main executable file (which was our case), but for that you need a bundle file, but for that... That is the reason I'm constantly saying "Oh, there is one more easy not easy thing,...", because it seems like a grave you never quit digging.

During this long trip properly packaging our application I've been taking notes to somehow document it. Enjoy:

---
#### Directories arrangement:

**`Note: I am going to document how I packaged MY APPLICATION so maybe you will need to perform extra steps or change some things in order to fit this tutorial to your needs. Also, for this example I am going to call "MyApplication" the application we are packaging.`**

First of all we need to create a root directory called `MyApplication.app` and inside the of it you need to create another directory called `Contents`. Inside of `Contents` we need to create:

- The `MacOS` directory where the application bundle will go in.
- The `Info.plist` file where the application info will go in. [More info here](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Introduction/Introduction.html).
- The `Resources` directory where the application icon file and our developer public key will go in.
- The `Frameworks`directory where we will place some `dylib's, dll's and third party FrameWorks` our application will use.

For further information about where to place each file our application uses, visit the [nested code section](https://developer.apple.com/library/archive/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919-CH1-TNTAG201) in the code signing in depth Apple documentation.

#### Granting permissions to the application:

In this point remains our main reason for why we needed to perform a whole new process for creating a bundle and installer properly. We use Visual Studio for Mac and when you build your project, the IDE generates a `MyApplication.exe` file that you can simly run with `mono MyApplication.exe`. And that's what we were doing for a lot of years using a script into the mentioned `MacOS` that was running that command besides setting up some environment variables for a proper execution.

Doing that is just fine if you do not use something that Apple wants the user to grant permissions for (i.e.: full disk access, camera or microphone usage, etc.). But if your application needs permissions for something you will need to add a description message to display it to the user when asking for them in the `Info.plist` file. In our case it was:

> `<key>NSCameraUsageDescription</key>`<br />
> `<string>MyApplication needs to look at your pretty face using the camera.</string>`<br />
> `<key>NSDesktopFolderUsageDescription</key>`<br />
> `<string>MyApplication wants to look for candy into your desktop folder.</string>`

Between the key value pairs in the `Info.plist` file you also need to specify the [CFBundleExecutable](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html) to identify the name of the bundle's main executable file. What is the problem at this point? Easy: the `Info.plist` file is for the script that executes the `MyApplication.exe` file but not for the exe file per se, so when the application tries to acces the camera or the desktop directory macOS Catalina kills the execution with no information (unless you have a little knowledge reading the Console.app logs). No `Info.plist` file with permission description, no party. *Please, if you have any other way to keep using the script and the `.exe` file don't hesitate to comment down below*

Another thing we noticed using the upcoming macOS Big Sur beta operative system is that your application will have the same crash if it does not have also the proper [Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_device_camera) set up. We will tell you how to add them in the `code signing` step. In our case we created an `Entitlements.plist` file and we added:

> `<key>com.apple.security.device.camera</key>`<br />
> `<true/>`

#### Bundle creation:

In order to stop using a script for executing the `MyApplication.exe` file we need a bundle file generated by mono and place it in the `MacOS` folder inside our application. For that we used the next command:

> `mkbundle <PROJECT_OUTPUT_BIN_DIR>/MyApplication.exe -o <PROJECT_OUTPUT_BIN_DIR>/MyApplication --runtime <MONO_PATH>/bin/mono-sgen64 --simple`

In our case we needed to add some extra things like setting up the `$PKG_CONFIG_PATH` environment variable with the `<MONO_PATH>/lib/pkgconfig` before running the `mkbundle` command. We also added the:

- `-L <LIBRARY_PATH>` command option to also bundle project libraries Visual Studio generates at the build output, the mono 4.5 libraries and Facades libraries.
- `--machine-config` command option for for specifying the mono 4.5 `machine.config` file as machine configuration.
- `--config <CONFIGURATION_FILE_PATH>` command option for adding a dll map config file our application needs.
- `--deps` command option to automatically include all the dependencies referenced by our application.

For further information visit the [mkbundle command documentation](https://www.mono-project.com/docs/tools+libraries/tools/mkbundle/) or use the man command.

Make sure the generated bundle runs your application and try out double clicking the `MyApplication.app` directory we created at the beginning of this post (remember to set `MyApplication` as value to the `CFBundleExecutable` key in the `Info.plist` file).

#### Code signing for Apple notarization:

**`NOTE: there is currently an issue with Mono that prevents code signing bundles in macOS. Once the bundle is signed it turns unusable.` [Checkout this link for further information](https://github.com/mono/mono/pull/19580)`.`**

Here we are facing another easy not easy thing Apple wants you to perform if you do not want 20 messages per day in your support portal inbox asking why your installer pops up a message saying your application might be malware, only letting you install it by right clicking it and selecting the "Open" option: Apple Notarization (which requires most of your libraries and binaries to be signed). In order to not codesign every single file in your application I recommend you to first create a package and perform a first notarization in order to know which files need to be signed and which ones not.

Once you know which files you need to sign you will need to create a "Developer ID Application" certificate and use it with the `codesign` command for signing everything Apple asks for. For further information visit the [codesign command man page](https://www.manpagez.com/man/1/codesign/). I basically use this command to sign each file:

> `codesign --timestamp --deep --keychain /Users/$(USER)/Library/Keychains/login.keychain --sign "Developer ID Application: David Fernandez (93H7PWN2SA)" <FILE_PATH>`

As a last step we codesign the entire `MyApplication.app` directory with the next command (remember the `Entitlements.plist` file we mentioned before? Here is were it comes into play):

> `codesign --timestamp --deep --entitlements Entitlements.plist --keychain /Users/$(USER)/Library/Keychains/login.keychain --sign "Developer ID Application: David Fernandez (93H7PWN2SA)" MyApplication.app -f -o runtime`

#### Installer creation:

Let's create a temporal installer for our application into an output path we are going to call `<RESOURCES_PATH>`. In our case we also want the installer to perform some things before starting and after finishing and for that we will have a path with a `preinstall` and `postinstall` bash scripts we are going to place in a dedicated directory. For that we are going to run the next command:

> `pkgbuild --identifier 'com.myapplication.x86_64.dfernandez' --root MyApplication.app --version <VERSION> --scripts <PRE_AND_POST_INSTALL_SCRIPTS_PATH> --install-location '/Applications' <RESOURCES_PATH>/MyApplication.pkg`

This command will create a `.pkg` file into the `<RESOURCES_PATH>` directory where we are also going to place (in case we want) other resources our installer will install (let's say a license manager application called `MyLicenseManager.pkg`) and other resources like the terms and conditions text file, a background image for the installer, etc. We also need a `Distribution.xml` file where we are going to define some installer parameters and what `.pkg` files we are going to ask it to install ([check this link for more information](https://developer.apple.com/library/archive/documentation/DeveloperTools/Reference/DistributionDefinitionRef/Chapters/Introduction.html)). It is important the output path of the next command is not the same as `<RESOURCES_PATH>`:

> `productbuild --distribution <DISTRIBUTION_FILE_PATH> <OUTPUT_PATH>/MyApplication.pkg --package-path <RESOURCES_PATH>`

If you wonder how our distribution file would look like here you have it:

```XML
<?xml version="1.0"?>
<installer-gui-script minSpecVesion="1">
  <options require-scripts="false"/>
  <background alignment="left" file="[RESOURCES_PATH]/background.png" scaling="none" mime-type="image/png"/>
  <background-darkAqua  alignment="left" file="[RESOURCES_PATH]/background.png" scaling="none" mime-type="image/png"/>
  <license file="[RESOURCES_PATH]/license.txt"/>
  <domains enable_anywhere="false" enable_currentUserHome="false" enable_localSystem="true"/>
  <title>My Application</title>
  <choices-outline>
    <line choice="com.myapplication.x86_64.dfernandez"/>
  </choices-outline>
  <choice description="default" id="com.myapplication.x86_64.dfernandez" start_enabled="false" title="default">
    <pkg-ref id="com.mylicensemanager.thirdpartycompanyname.driver"/>
    <pkg-ref id="com.myapplication.x86_64.dfernandez"/>
  </choice>
  <pkg-ref id="com.myapplication.x86_64.dfernandez" version="1.0.0">[RESOURCES_PATH]/MyApplication.pkg</pkg-ref>
  <pkg-ref id="com.mylicensemanager.thirdpartycompanyname.driver" version="6.40">[RESOURCES_PATH]/MyLicenseManager.pkg</pkg-ref>
</installer-gui-script>
```

With all these things we have generated a final `.pkg` file with a custom installer and we have added the extra `MyLicenseManager` software to be also installed with it. Now we need to sign our package and for that we need to have a "Developer ID Installer" certificate in our keychain. First we need to  unlock it:

> `security unlock-keychain -p <USERNAME> /Users/<USERNAME>/Library/Keychains/login.keychain`

Then we sign it with the next command:

> `productsign --keychain /Users/<USERNAME>/Library/Keychains/login.keychain --sign "Developer ID Installer: David Fernandez (93H7PWN2SA)" MyApplication.pkg MyApplication-signed.pkg`

#### Package notarization:

In order to let Apple check if your application is trustable by the OS, you need to perform what they call a [notarization](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution). For that please follow these steps:

1. Run the `xcrun altool --notarize-app ...` command to send your application installer to Apple for notarization. [Please read this](https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow#3087734) in order to know how to use this command. If everything goes well it will give you a request UUID. *Keep in mind that you need to complete the **Installer creation** step first in order to have an installer to send it to Apple*
2. Run the `xcrun altool --notarization-info <REQUEST_UUID> -u <APPSTORE_CONNECT_USER> -p <APPSTORE_CONNECT_PASSWORD>` command with the provided request UUID to check the status of the notarization. Once finished it will provide you a link with the results.
3. Check the link provided and perform a `codesign` for every file they ask you to sign.
4. If the notarization is successful, run the `xcrun stapler staple MyApplication-Installer.pkg` command to staple the result to your installer file.
5. Distribute your application!

---
<br />

I really hope this can help you if you are currently facing one or more of the problems I've faced with. If you have better ways to solve some situations or extra steps that would be useful please write them down and I will complete this guide and also apply them for my automated process. I also have documented the packaging adventures volume II in Windows and I will post it in the future (besides it is quite easier than macOS).

See you all in the next post!