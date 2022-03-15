---
title: "First date with AvaloniaUI"
date: 2022-03-14
hero: /images/posts/avalonia.png
categories:
- Development
- writing-posts-category
- Avalonia
---


Wow, it has really been a long time without posting here! 8 months! Lots of (good) things happening in my personal life so I decided to just write here once I really have something to write about. Something that engages me. And here I am!

Last summer I had to hire a new senior developer for my team and during the interview process, one profile got our attention in a particular way. He didn’t ask for extra money, goodies or benefits. He wanted me to evaluate the idea of migrating our application from GTK to Avalonia. He got me. After checking his amazing background with multiplatform front-end frameworks it was just matter of time to start working on this adventure.

As a .Net developer, I have worked with the well (but still not enough) known Xamarin, now called .Net MAUI. I’ve developed a Xamarin application when that framework was on his early stage, having to implement myself lots of things now you can implement with one single line. For example, rounded images. You can check the [LongoMatch](https://longomatch.com/) app on [App Store](https://apps.apple.com/es/app/longomatch/id1303643058) and [Google Play](https://play.google.com/store/apps/details?id=com.longomatch.mobile&gl=US).

My first question was obvious: why Avalonia and not MAUI? Our new developer insisted that it is very similar but in his opinion Avalonia is better. A few checks on the internet and he is not the only developer that stands for giving a good chance to Avalonia. In a nutshell, “*Avalonia is a framework that not only matches WPFs concepts and APIs but in many respects exceeds them. They even fixed some of the bugs and problems that WPF had!”* over Xamarin *“Control customization is much easier and more powerful in Avalonia”.*

Alright then! Let’s investigate and try this UI framework. This will be a quick overview of the official Avalonia documentation which I have recently read, so please have a seat and enjoy this (spoiler) amazing framework that really got me since minute 1:
<br />

---

##### What is Avalonia?

Avalonia UI is an Open Source frontend .NET C# multiplatform framework. It uses XAML code in files with the `.axaml` extension. For now it has a VS for Windows extension to preview your designs. Use ReSharper to also add Intellisense. On the other hand, JetBrains Rider supports Avalonia preview and IntelliSense for macOS and Windows.

You can use the [DevTools](https://www.notion.so/My-first-experience-with-AvaloniaUI-2e6138189fa1433aac589942d0ae10a9) in order to visual develop and debug, which is a multiplatform and Open Source inbuilt window. Avalonia also includes verbose logging on the Visual Studio Output window.

Avalonia is very similar with WPF or UWP so if you develop for one of these frameworks then it shouldn’t be difficult to adapt yourself to Avalonia. Although it is not compatible with them so you cannot use their controls without porting them.

Avalonia is supported on all platforms that support .NET Standard 2.0

<aside>
💡 It is possible to have a dessign DataContext that will allow you to have a fake ViewModel as static resource to reference in your AXAML files to use it during design process.

</aside>

##### AXAML files

AXAML files use XAML markup language to design your application views. Since XAML is XML based, the UI that you compose with it is assembled in a hierarchy of nested elements known as an element tree.

The behaviour of the elements can be implemented in code that is associated to the markup (code behind).

```xml
<Button Name="button" Click="button_Click">Click Me!</Button>
```

```csharp
public void button_Click(object sender, RoutedEventArgs e)
{
    var button = (Button)sender;
    button.Content = "Hello, Avalonia!";
}
```

Avalonia supports the MVVM design pattern so you can separate your views from the application functionality:

```xml
<Button Content="{Binding ButtonText}" Command="{Binding ButtonClicked}"/>
```

```csharp
DataContext = new MainWindowViewModel();

public class MainWindowViewModel : INotifyPropertyChanged
{
    string buttonText = "Click Me!";

    public string ButtonText
    {
        get => buttonText;
        set 
        {
            buttonText = value;
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(ButtonText)));
        }
    }

    public event PropertyChangedEventHandler PropertyChanged;

    public void ButtonClicked()
		{
				ButtonText = "Hello, Avalonia!";
		}
}
```

The data context will usually be set for the top-level control such as `Window` and child controls will inherit this data context.

In order to propagate changes on ViewModels, you can go the easy way and make your application use [ReactiveUI](https://www.reactiveui.net/), which is a MVVM framework for .Net platforms. Your view model class then needs to inherit from `ReactiveObject`. If you don’t want to add a dependency on ReactiveUI, you can always implement `INotifyPropertyChanged` manually.

##### Data binding

Avalonia supports binding between controls and .Net objects (including async tasks results). It supports:

* Multiple binding modes: one way, two way, one-time and one-way to source
* Binding to a `DataContext`
* Binding to other controls
* Binding to `Tasks and Observables`
* Binding converters and negating binding values
* Fallback values (You can use `FallbackValue` to display some loading indicator).

##### Graphics

A cool feature of Avalonia is that it has resolution and device-independent graphics using its `device-independent pixel` which will scale automatically to match the DPI setting of the system it renders on.

It also has advanced graphics and animation support. Avalonia uses Skia rendering scheme by default, so that provides you with a library of 2D shapes and geometries available to use in your AXAML files on a Canvas control. The CSS-like animations support will let you create page transitions and more with property transitions and keyframe animations.

##### Controls

**`Window`**: is the top-leve control in Avalonia. Normally we create a MainWindow class that will contain the views of the application.

**`UserControl`**: represents a view in Avalonia. It is a reusable collection of controls in a predefined layout.

##### Developer Tools

Avalonia has an inbuilt DevTools window which is enabled by calling the attached `AttachDevTools()` method in a `Window` constructor. You ned to add the `Avalonia.Diagnostics` nuget package to your project.

```csharp
public MainWindow()
    {
        this.InitializeComponent();
#if DEBUG
        this.AttachDevTools();
#endif
    }
```

To open the DevTools, press F12, or pass a different `Gesture` to the `this.AttachDevTools()` method.

The DevTools consists of a window with three tabs:

`Logical tree`: displays controls in the window’s logical tree.

`Visual tree`: displays controls in the windows’s visual tree.

`Events`: helps the developer to track the propagation of events.

It allows you to change values of the properties of the controls in runtime.

##### Good things I found on my first steps as Avalonia developer

* The Avalonia community is amazing. Always there to support you. They also have paid support if your project requires it.
* Felt so good programming on XAML back again since the legacy front framework I use to work with in my company is GTK+2. There is a huge difference in terms of fast development and less needed code. The migration will be hard, but I feel really engaged with it.
* I love styling on Avalonia. You can have your custom classes css-like to use it with your controls. Controls will bubble from current control to top container (Window) and then to application level in order to look for defined styles.
* They have an extensive documentation. I have been reading it lastly and I was continually thinking: “oh, good to know I can do that”. They also have a great API with all the stuff in much more detail.
* It is Open Source. That is ALWAYS welcome since you can access the source code in order to see how things are working. That helped to me in order to implement a converter for my custom `Image` implementation to Avalonia’s, for example.

##### Things that I found less practical

* Avalonia is still young and there are some things that need work on them. I am used to it since my company adopted Xamarin practically on its birth for a mobile project and we needed to implement ourselves some needed things like controls that support either SVG or PNG images. That particular thing was not that hard since they already have some support using SKIA and the community helped my providing me examples of custom draw operations in order to implement mask colors over my SVG images.
* Still haven’t been able to work with a designer preview since I work on macOS and seems that the available JetBrains Rider extension is still not compatible with the latest version of the IDE. No support for VS for mac but there is an available extension for VS on Windows.

So basically that’s it. I been working with Avalonia for a couple of months now and I can say that the initial idea of porting a GTK application to this framework keeps on track. Hopefully we will have it for this summer... and also sadly because I love picking Avalonia related stories on our SCRUM board! Still have a lot to learn but I really would empower you to give a chance to it. Great people behind this framework and good quality on their work.

##### Sources

* [http://avaloniaui.net/](http://avaloniaui.net/)
* [https://docs.avaloniaui.net/](https://docs.avaloniaui.net/)
* [http://reference.avaloniaui.net/api/](http://reference.avaloniaui.net/api/)
* [https://gitter.im/AvaloniaUI/Avalonia](https://gitter.im/AvaloniaUI/Avalonia)
* [https://github.com/AvaloniaUI/Avalonia](https://github.com/AvaloniaUI/Avalonia)
---
<br />

What’s next? Well, one of those good things I told you that happened to me is that I am getting married next year, so I am planning to develop a webpage for all my wedding day related stuff. I want to use tools I’ve never or barely touched and I have seen one video tutorial from one of my favourite content creators [Takuya (devaslife)](https://www.youtube.com/c/devaslife) using Next.js, Three.js and Chakra UI. So... as always, if you have something to ask or comment just write it down below. See you in the next post!