---
title: ".NET Framework vs .NET Core"
date: 2020-12-28
hero: /images/posts/ecosystem.png
# categories:
# - writing-posts
# - writing-posts-category
---

First things first, I know I’ve been out for a couple of months without posting any article on my site. Sorry for that! I’ve been busy finishing up my computer science degree and I wanted to boost my final project by giving it my free time as much as possible. Thanks to that I have written down some Xamarin things to investigate and share them here, also. Now let’s get back to work!

Continuing the .NET clarifications, one question I was asked for in an interview was: “Why are you using .NET Framework and not .NET Core for your application?”. I did not answered quite well. I knew there are main differences but I didn’t know which ones, so I wrote that down to check it once I got home, and here you are some quick indications that might be helpful for you and also will make you understand better the differences between these two frameworks:

---
#### What are .NET Core and .NET Framework?

.NET Framework and .NET Core are software development frameworks that share a common essential librares set (.NET Standard) for any application to run (runtime and compiler libraries, data types, etc.). See the image below to understand the .NET Ecosystem:

{{< img src="/images/posts/ecosystem.png">}}

##### .NET Core:

###### PROS

* .NET Core is a subset of the .NET Framework. So it is more modularized and helps you create apps with only needed libraries, since it is delivered as a set of NuGet packages and the developer can include libraries per need. That is what makes it flexible and lightweight, which gives you support for working with command line interface (CLI).
* Its major key areas are performance and scalability so it supports very well micro services based apps due to its flexible and lightweight structure. It makes easy to deploy your apps into a container working good with Azure and Docker. It allows deployment of micro services in different languages, mixing technologies.
* All mentioned makes .NET Core a truly cross platform development framework.
* .NET Core is Open source.

###### CONS

* .NET Core has a more complex learning curve than .NET Framework due to being a subset of it. That makes the developer have to invest time for example on finding what libraries does his application need.
* It does not support desktop development (it focuses on Web and Windows mobile apps).
* It only supports REST APIs development.

##### .NET Framework:

###### PROS

* Supports Windows and Web applications letting use WPF, UWP and Windows Forms for building apps with it. ASP.NET MVC is used to build web apps with .NET Framework
* .NET Framework is more stable since it provides all the basic requirements for the development of an application (DB management, connectivity, services, APIs, etc.) 
* It is used for Desktop and Web apps development.
*  It supports [Windows Communication Foundation](https://docs.microsoft.com/en-us/dotnet/framework/wcf/whats-wcf) services and REST APIs
*  .NET Framework is too heavy for that and developers need to work with an IDE.

###### CONS

* It is packaged as a whole and even if you do not use any library for your application it still comes as part of the package. It relieves the developer of the need to find out which libraries he needs.
* It is not open source (but you can read the code)
* Despite being also designed for developing applications for all operating system, it ends up favoriting Windows.
* It does not support creation and deployment of micro services in different languages
* It is so heavy that developers need to work with an IDE. It does not support working with CLI

##### The brand new .NET 5:

Microsoft has been working on all these differences within their frameworks ecosystem and they released .NET 5 (https://dotnet.microsoft.com/download/dotnet/5.0) last November. .NET Core and .NET Framework have been developed simultaneously until now that have been unified bringing the best features of both into a single framework. From now on, Microsoft will continue updating this framework and not .NET Core and .Net Framework. Between all of the new features I would like to remark two of them:

###### C# 9

* Top-level statements: Useful for simplifying code like no specifying the namespace will assume you are declaring it in the global namespace, writing code outside any method in a simple project will assume that it belongs to the `main()` method. In my opinion this is a very dangerous weapon if not used properly.
* Record types: This is an immutable complex reference type. If we define a record type object, then its properties cannot be changed once initialized. This is very helpful when we compare two record types; if their properties have the same values, then the objects are equal. This does not happen with reference types, that only return true when we compare two references to the same instance.
* Init-only setters: This is a very useful feature since it lets you to set an object's property value on its initialization without the need of declaring a constructor that takes those values. This improves the readability of the code in my honest opinion.

###### .NET MAUI:

The new .NET Multi-platform App UI (MAUI) will let you use the same code for defining Android, iOS, macOS and Windows user interfaces, all in one project. This becomes the evolution of Xamarin and it supports modern patterns as MVVM and MVU.

Right now i’ve read a lot of comments from brave developers that have migrated their projects to the new .NET 5 framework and most of them agree on that the process have been surprisingly easier than they thought. I want to perform a proof of concept project using .NET 5 and .NET MAUI to have my own impressions.


##### Conclusions:

Besides the evident differences between the platform your app is going to be targeted to (micro services, web, desktop, …), porting from .NET Framework to .NET Core requires work so if your application already exists, is stable with .NET Framework and there are no major upgrades planned, there is no need to migrate to .NET Core. By the other hand, if your application needs to be built from scratch (and there is not a deadline since you need to analyze and check what libraries you need) then .NET Core is the right choice, then check if migrating to .NET 5 is worth a look. In case you don’t have a hard deadline and you want to experiment I would definitely give a try to .NET 5 from scratch if the project needs to be build from there. Mono and Microsoft teams have been working hard and there are still some things that need to be fitted in this new framework but I think their work deserves a chance.


##### Sources:

* https://www.c-sharpcorner.com/article/difference-between-net-framework-and-net-core/
* https://www.educba.com/dot-net-core-vs-dot-net-framework/
* https://dotnettec.com/dot-net-core-vs-dot-net-framework/
* https://docs.microsoft.com/en-us/dotnet/standard/choosing-core-framework-server
* https://www.c-sharpcorner.com/article/future-of-dot-net/
* https://www.youtube.com/watch?v=79UWvR734wI
* https://samwalpole.com/exciting-new-features-in-net-5
* https://devblogs.microsoft.com/dotnet/introducing-net-multi-platform-app-ui/

---
<br />

As you can see, the .NET environment is a little bit complex but if you get the main differences between the different frameworks it becomes less complex. Also thanks to .NET 5 the complexity to understand it will be less and I really hope that this fact will increase the expertise of all the .NET developers out there. Great times are coming!

As always, if you find something that is not well explained or that is wrong, please let me know in the comments below. See you all in the next post!