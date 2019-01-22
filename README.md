#  UIKit.js

Build powerful native iOS or tvOS apps using JavaScript backend services.

**Note: This framework is currently a proof-of-concept—if you like the idea, let me know
at [@hnryjms][twitter-hnryjms] or my [personal website][hnryjms].**

This framework provides tools and methods for sharing data between JavaScript and native
code, but still allows (and even relies) on many powerful features of native apps built with
Xcode, such as Storyboards and UI Components.

Unlike [React Native][react-native], this project seeks solely to bridge existing properties of
Interface Builder components to the JavaScript environment, rather than reconstruct them
as look-alike JS components.

## Getting Started

### Installation

You can install UIKit.js using [Carthage][carthage] for iOS or tvOS.

```sh
$ echo 'github "hnryjms/UIKit.js" ~> 0.1' >> Cartfile
$ carthage update
```

Then, drag the `Carthage/Build/iOS/UIKitJS.framework` file into your project (make sure
to deselect the `Copy items if needed` option), and ensure the framework is added to your
app/target's `Embedded Binaries` and `Linked Frameworks and Libraries` section.

(note: you may want to check out the [Carthage][carthage] Quick Start guide on their project
README for a complete setup guide, including several `copy-framework` improvements).

### Setup

Once the framework is linked, you will create a single `JSBridge()` instance for moving data
between JavaScript and native code. Typically, a singleton can live anywhere in your application,
such as on your `AppDelegate` class.

```swift
import UIKitJS

@UIApplicationMain
class AppDelegate {
    static let bridge = try! JSBridge(Bundle.main.url(forResource: "main", withExtension: "js"))
}
```

You can also used more advanced implementations, such as a `var bridge: JSBridge?` on
the instance of your `AppDelegate` (accessable by `(UIApplication.delegate as! AppDelegate).bridge`),
such as the example under `Advanced Usage; Custom Modules`

### Usage

The core functionality of UIKit.js is using backend services, such as network requests and data
storage in JavaScript. Assuming your UIs are built in an Interface Builder storyboard, you can
load information from JS with a single call.

```swift
import UIKit
import UIKitJS

class MyViewController: UIViewController {
    func viewDidLoad() {
        AppDelegate.bridge.invoke(JSOperation("MyJSModule.loadData()")!, withArguments: ["hello"]) { result, error in
            // write your code here...
        }
    }
}
```

And you can write `MyJSModule` with vanilla ES6 formatting, as supported by JavascriptCore,
the framework underneith WebKit (i.e. Safari & Mobile Safari).

```js
class MyJSModule {
   static async loadData() {
       const data = await fetch("https://hnryjms.io/");
       return data.text();
    }
}

// Note: the root `this` property exposes JS objects to native code.
this.MyJSModule = MyJSModule;
```

### Advanced Usage; Webpack Bundler

You can use the Webpack bundler to build the JavaScript entrypoint for your native app code.

(guide coming soon)

### Advanced Usage; Custom Modules

You can create custom native modules that are accessable in JavaScript code. This means you
can create custom API Request implementations (such as `fetch()`), or host navigation routing
code within JavaScript files.

```swift
@objc protocol MyModuleExports: JSExport {
    func exportedFunc()
}

class MyModule: NSObject, JSModule, MyModuleExports {
    let name = "MyModule"
    
    func exportedFunc() {
        // write your code here...
    }
}
```

Then you will pass your module into the `JSBridge()` as it is created, and the module is available
to all JavaScript code as the first line starts executing.

```swift
import UIKitJS

@UIApplicationMain
class AppDelegate {
    static let bridge = {
        let modules = [ MyModule() ]
        return try! JSBridge(Bundle.main.url(forResource: "main", withExtension: "js"), modules: modules)
    }()
}
```

### Advanced Usage; Exposing Native UI Components

You can expose UI entry points through the JavaScript bridge to allow some UI component rendering
and handling inside JS code.

(guide coming soon)

## Example Project

You can find an example project inside UIKit.js, built for iOS. You can run it from any clone of this
repository by simply opening the `UIKit.js.xcodeproj` file in Xcode.

[twitter-hnryjms]: https://twitter.com/hnryjms
[hnryjms]: https://hnryjms.io
[react-native]: https://github.com/facebook/react-native
[carthage]: https://github.com/Carthage/Carthage
