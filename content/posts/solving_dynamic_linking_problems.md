---
title: "Sherlock 'otool' Holmes"
date: 2021-06-30
hero: /images/posts/debugging.jpeg
categories:
- Development
- Debugging
---

Have you ever had the feeling that something really magic has happened to your computer because of a thing that was working suddenly, out of nowhere, stopped working? Wait, maybe I made some changes, let’s go back to master... mmh no... it isn’t working anymore… but how? This code is working on other machines! It worked on mine like 20 minutes ago! This is impossible, nothing changed and it is not working anymore. Well… maybe I performed a little change that is not related at all with this but... I just a couple of things through `brew`... Could that be the issue? IMPOSSIBLE!

Well... impossible is nothing so let me relate how I spent a good afternoon to solve this little but disturbing issue!

<br />

---
##### Scenario:

Working on a branch, everything is fine and just about to clean up some commit messages to create the pull request. I perform some things non-related to that code while passing the tests and after that I just want to check the functionality once again. Maybe performing some minor changes that will improve the code. I press the “Run” button and it compiles like a charm. The application starts opening and… boom! You have a nice runtime crash waiting there for you. Maybe those minor changes I performed after running the tests, so I stash the changes and try to run again. Nothing. Change to master, perform a full cleanup and build again from scratch. No big prize.

But I didn’t perform any change... my setup is correct. Only updated Visual Studio for Mac. Could that be the issue? Weird... but let’s have a look.

##### First steps to get any clue:

The first thing I would do to approach the problem is to check if the application is really self-contained or if it is loading some dependencies from non desired paths. The philosophy of my applications is that only operating system libraries should be loaded from the original path, the rest should be distributed with the installer.

The first thing that comes to my mind is to use the `otool` command to check the dependencies of each library, but there are other libraries that are loaded in runtime through `dllimport` so running the app through console using `MONO_LOG_LEVEL=debug` and using `grep` to filter the output to print all the text that contains `DllImport loaded library`. Bingo:

`Mono: DllImport loaded library ‘/Library/Frameworks/Mono.framework/Libraries/libgtk-quartz-2.0.0.dylib’’.`

I know that `libgtk-quartz-2.0.0.dylib` should be copied from a Nuget package to the output directory and be loaded from there on runtime. Now it’s time to guess why it is failing loading the library from there in the first instance. For that I will just run again the application with the `MONO_LOG_LEVEL=debug` and print all the output looking for `libgtk-quartz`:

```
Mono: DllImport error loading library '/Users/dfernandez/Development/MyApp/src/SampleAppDemo.GTK/bin/Debug/libgtk-quartz-2.0.0.dylib': 'dlopen(/Users/dfernandez/Development/MyApp/src/SampleAppDemo.GTK/bin/Debug/libgtk-quartz-2.0.0.dylib, 9): Library not loaded: @rpath/libpangocairo-1.0.0.dylib
 Referenced from: /Users/dfernandez/Development/MyApp/src/SampleAppDemo.GTK/bin/Debug/libgtk-quartz-2.0.0.dylib
 Reason: Incompatible library version: libgtk-quartz-2.0.0.dylib requires version 4204.0.0 or later, but libpangocairo-1.0.0.dylib provides version 3501.0.0'.
```

We are in the good way to solve the issue.

##### What is causing the issue:

So, it turns out that our `libgtk-quartz` library needs `libpangocairo-1.0.0.dylib` version 4204 or higher, but the one that is loaded has the 3501 version.

`otool -L` tells me that the `libpangocairo-1.0.0.dylib` located in my output directory has the correct version: 4204, so that library is being loaded from another path. The same library on the Mono installation path has the 3501 version. Also, the `libgtk-quartz` ends up being loaded from the Mono installation path. Same for all the GTK libraries. But why? We are closer to the issue.

My application uses a GTK nuget package that I compile and upload to my own server, so I would like to check if the dynamic linking of my GTK libraries is working properly. For that I will first check the dynamic dependencies of `libgtk-quartz`, which is the library we started investigating this issue with, but it could work with any other GTK library:

```
$ otool -L /Users/dfernandez/Development/MyApp/src/SampleAppDemo.GTK/bin/Debug/libgtk-quartz-2.0.0.dylib
/Users/dfernandez/Development/MyApp/src/SampleAppDemo.GTK/bin/Debug/libgtk-quartz-2.0.0.dylib:
	/opt/gtk-sharp-nuget/dist/darwin_x86_64/lib/libgtk-quartz-2.0.0.dylib (compatibility version 2401.0.0, current version 2401.32.0)
	@rpath/libpangocairo-1.0.0.dylib (compatibility version 4204.0.0, current version 3501.0.0)
...
..
.
```

Now I will check if the @rpath is being replaced for the correct values using `otool -l` over the `libgtk-quartz` library:

```
Load command 43
     cmd LC_DATA_IN_CODE
 cmdsize 16
 dataoff 3828808
datasize 2584
Load command 44
         cmd LC_RPATH
     cmdsize 16
        path . (offset 12)
Load command 45
         cmd LC_RPATH
     cmdsize 32
        path @loader_path/.. (offset 12)
Load command 46
         cmd LC_RPATH
     cmdsize 32
        path @executable_path/.. (offset 12)
Load command 47
         cmd LC_RPATH
     cmdsize 32
        path @loader_path/../lib (offset 12)
Load command 48
         cmd LC_RPATH
     cmdsize 40
        path @executable_path/../lib (offset 12)
```

Everything seems fine, we have 5 different `LC_RPATH` to replace `@rpath` for, but let’s debug again our application printing a line each time dyld expands an `@rpath` variable saying if it was successful or not. For that we will set the `DYLD_PRINT_RPATHS` environment variable before running our application again through the terminal. Let’s see what we got now:

```
Mono: DllImport attempting to load: 'libgtk-quartz-2.0.0.dylib'.
RPATH failed expanding     @rpath/libpangocairo-1.0.0.dylib to: /Users/dfernandez/Development/MyApp/src/libpangocairo-1.0.0.dylib
RPATH failed expanding     @rpath/libpangocairo-1.0.0.dylib to: /Users/dfernandez/Development/MyApp/src/SampleApp/SampleAppDemo.GTK/bin/Debug/../libpangocairo-1.0.0.dylib
RPATH failed expanding     @rpath/libpangocairo-1.0.0.dylib to: /Library/Frameworks/Mono.framework/Versions/6.12.0/bin/../libpangocairo-1.0.0.dylib
RPATH failed expanding     @rpath/libpangocairo-1.0.0.dylib to: /Users/dfernandez/Development/MyApp/src/SampleApp/SampleAppDemo.GTK/bin/Debug/../lib/libpangocairo-1.0.0.dylib
RPATH successful expansion of @rpath/libpangocairo-1.0.0.dylib to: /Library/Frameworks/Mono.framework/Versions/6.12.0/bin/../lib/libpangocairo-1.0.0.dylib
```

There is the problem! In this case `@executable_path` is the path of `mono`, since I am running the app through it (remember that macOS cannot run `.exe` files by itself), so that is why we are using the native mono installation path. If we were running the application executable through mono in the output directory instead of the repository source code root directory, then the `”.”` rpath would have done the trick, but thanks to that we can see that we have a relocation issue. Also, `@loader_path`, which is the path where the library that links to `libpangocairo` is located (the output directory in this case) is going one folder back as its rpath is defined as `@loader_path/..`. That doesn’t make sense in my case.

So all I need to do is to relocate properly my GTK libraries removing that `/..` from my `@rpath`s

##### Final thoughts:

Turns out that the software I installed with `brew` also installed some dependencies that changed my Mono framework installation. So that was not the issue but the thing that made my bug come to light. My program was working because the Mono version I already had installed was completely compatible with it. But a good application has to be self-contained!

I still need some guidance through this kind of low level debugging but it really gives me the sensation that this makes you understand very well how a lot of things work. I consider this as important (or even more) as mastering a specific framework or knowing if `foo.Count != 0` is less complex than using `foo.Any ()` [kisses for that technical recruiter who put his chest out of it in an interview]. Most of the developers work with already built Nuget packages or don’t need to modify open source projects so they don't need to deal with these kinds of errors on a daily basis. I think that is why some of them could not give that much importance to the fact that you can deal with library/assembly low level problems.

##### Sources:

* https://wincent.com/wiki/@executable_path,_@load_path_and_@rpath

---
<br />

I can completely understand that this kind of debugging is not as loved as just debugging code, but for some developers it just turns as tedious as sweet because the fact of getting clues letting you get to the issue more and more is just satisfying. It is as addictive as eating sunflower seeds.

Please let me know if you have some questions or suggestions for this post. See you all in the next post!
