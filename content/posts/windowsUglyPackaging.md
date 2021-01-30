---
title: "Packaging adventures volume II: Windows"
date: 2021-01-30
hero: /images/posts/windowspkg.png
# categories:
# - writing-posts
# - writing-posts-category
---

So here we are with the second part of the packaging adventures. If you remember, we already talked about [macOS packaging](https://www.theimpostersyndrome.dev/posts/macospackaging/) a few months ago and now it's time to show you how to do it on Windows. Windows has many ways to package your applications and I am currently using another one for my production packages, but that will be explained in a third part of this packaging adventures. Let's start with one of the most basic ways to achieve it. Let's go!

---
##### What are we going to use?

* Visual Studio for Windows (2019 version in my case, but you can also use 2015 and 2017)
* [Visual Studio installer projects extension](https://marketplace.visualstudio.com/items?itemName=visualstudioclient.MicrosoftVisualStudio2017InstallerProjects)
* The project solution we want to package

##### First setup:

After first adding the [Visual Studio installer projects extension](https://marketplace.visualstudio.com/items?itemName=visualstudioclient.MicrosoftVisualStudio2017InstallerProjects) to our Visual Studio installation by installing the extension in the link provided, we need to open our project in Visual Studio and right-click on the solution, then add a new "Setup Project".

After that, you will get a new setup project with an "Application folder". You need to visualize the "Application folder" as the installation resulting directory in the target machine that is installing your application. In my case, my application needs some subfolders so I just need to add them by right-clicking on that directory and selecting the add directory option.

**`Note: This last step creating the sub-directories structure is optional. Add inside them whatever you need by right-clicking on them and selecting the "Add" option.`

##### Copying the application output into our Application Folder:

This is the most important step in order to get the build output inside our application folder to have it on the target machine after the installation. For that:

* Select the "Application Folder" inside the Setup Project and select the "Add >> Project Output" option.
* Select your main project (startup project) on the "project" dropdown.
* Select "Primary output" on the list in order to indicate that your main project output will be the main output of your application.
* Leave the "configuration" as active by default if you want to generate packages depending on the active configuration or select the desired one if you just need to create debug or release installers.
* Click OK

You can repeat this process but selecting "Add >> Assembly" in order to add any extra assembly to your output.

On the Visual Studio top menu bar, select "Build >> Configuration Manager" and make sure you check on each "Build" checkbox you want to build when building the whole solution, this will avoid building projects you do don't really need for the final application like a unit tests project. This applies for the selected "Active solution configuration", so keep an eye on that because we can be missing a build of any important project for our application when changing the configuration.

##### Adding dependencies to the installer bootstrapper:

Probably you will also need to include any dependency like the C++ redistributable files. In this case you can do this by getting its merge module by your own and adding them to your setup project by right-clicking the "setup project in your solution >> Add >> Merge Module".

Another way to add common Microsoft prerequisites is by accessing the Setup project properties by right-clicking on it and selecting the prerequisites option. In my case I have selected .NET Framework 4.7.2 (which is pre-selected) and the C++ runtime libraries for x64 architecture processors.

##### Adding a desktop shortcut:

Easy peasy, just select the "Application Folder" and then find and right-click on the "Primary output from <your project name>". This will generate a "Shortcut to primary output from <your project name>" and you just need to rename it as you wish, for example "MyProject shortcut". Then drag and drop it to the "User's Desktop" directory (maybe you want to have it on your User's Programs Menu, also).

##### Custom final installed program setups:

I have set up some other properties for my final project. For this we are going to use the Visual Studio Properties Window (VS top menu >> View >> Properties Window):

> Application Folder
>> * `DefaultLocation` ->> Set your installer's default install location on the target machine.

> Properties of your program's shortcut (created in previous steps)
>> * `Name` ->> Set the shortcut name.
>> * `Icon` ->> Set an icon for the shortcut.

> Setup project properties
>> * `Author` ->> Your name or your company's name.
>> * `Manufacturer` ->> Your company's name.
>> * `AddRemoveProgramsIcon` ->> Set the icon that your application will show on the Microsoft's "Add or Remove Programs" window.
>> * `TargetPlatform` ->> Important to specify if your target platform is x86 or x64 bit.
>> * `Version` ->> Your application's version

##### Customize your setup wizard:

Now that we have all our project setup we maybe have some questions like: Will the install wizard have a default license agreement? Can I put my super cool banner on it? How many steps does the wizard have? Don't worry, I got you covered.

Select the Setup project in your solution explorer and "right-click on it >> View >> User interface". Here you are. The user interface for the installation wizard! You can add or remove some views and customize them through the VS properties window. For example, in order to add a license agreement you need to add a "License Agreement" dialog to the "Start" group and you can drag and drop it on the wizard sequence in order to make it appear whenever you want. You will need to encode your license file as an RTF file and name it `license.rtf`

**`Banner advise: Not sure if there is another way, but the best image size I have found for the banner is 500x70`

##### Installer generation:

Just build your solution and check out for the output directory (usually bin/Debug or bin/Release) when finished. You should have a `Setup.exe` file and a `MyProject.msi` that you can now distribute!

##### Conclusions:

As you may notice by reading this article, this process is maybe useful for mini projects or a one-time installer generation, but a lot of questions came up on my mind while investigating this. How are we going to automate this? Is the installation wizard going to be that ugly-old-fashion style? How can I add conditions and pre or post-installation actions? How do I get a single `.exe` file instead a bootstrapper and a `.msi` file?

I have some notes that I took while investigating trying to answer some of these questions, like using IExpress to get a single `.exe` or using the "custom actions" for pre-installation actions. One good thing is that IExpress translates your actions into a single command that you can use to automate this in your CI/CD pipeline, but I just find this so tedious so I started looking for more modern alternatives. That's how I found Wix and it is just great.

##### Sources:

* https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2010/2kt85ked(v%3dvs.100)
* https://docs.microsoft.com/en-us/dotnet/framework/wcf/whats-wcf
* https://docs.microsoft.com/en-us/cpp/windows/walkthrough-deploying-a-visual-cpp-application-by-using-a-setup-project?view=msvc-160&viewFallbackFrom=vs-2019
* https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.3.0/com.ibm.zos.v2r3.ikya100/steps_installer.htm
* https://stackoverflow.com/questions/4182364/how-to-add-licence-agreement-in-the-setup-project

---
<br />

As I mentioned before, this is just one of many other ways to package a Windows application and I will explain the way I use Wix to create my production and stage packages. I just find this VS package generation procedure good to understand what we are actually doing and what we achieve doing it. Wix packaging coming on adventure III!

As always, if you find something that is not well explained or that is wrong, please let me know in the comments below. See you all in the next post!
