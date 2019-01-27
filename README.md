#  UIKit.js

Build powerful native iOS or tvOS apps using JavaScript backend services.

**Note: This framework is currently a proof-of-concept—if you like the idea, let me know
at [@hnryjms][twitter-hnryjms] or my [personal website][hnryjms].**

UIKit.js adds mappings and extensions to make [JavaScriptCore][jscore] easier to use when
building advanced Swift apps with JavaScript backend services. That means sharing more code
from web and mobile 🌈

- **View Controllers** 📱 - Create and map any view controller to JavaScript to change properties
  about the rendered screen, or push to new screens within JavaScript code.
  - [x] `UIViewController`
  - [x] `UINavigationController`
  - [ ] Others coming soon
- **UI Components** 🎛 - Create and map any UI component to JavaScript to observe and change
  properties about the element, or add elements to the UI dynamically within JavaScript code.
  - [x] `UINavigationBar`
  - [ ] Others coming soon
- **Browser Helpers** 🌍 - Utilize browser-addons within JavaScript code.
  - [x] `fetch()` - Perform basic network requests.
  - [ ] Others coming soon
- **Device Helpers** 📁 - Utilize device-specific functionality within JavaScript code.
  - [ ] `FileSystem` - Read and write disk files (coming soon)
  - [ ] Others coming soon

This project is not a comparable tool to [React Native][react-native]—our purpose is to enable
JavaScript code for connecting and manipulating native UI elements. The React Native framework
has moved away from this model, instead using custom-built look-alike UI components to mimic
iOS behavior.

## Getting Started

### Installation

You can install UIKit.js using [Carthage][carthage] for iOS or tvOS.

1. Add the `UIKit.js` project to your Cartfile:
    ```
    github "hnryjms/UIKit.js" ~> 0.1
    ```
1. Run `carthage update`
1. Drag the built `.framework` binaries from `Carthage/Build/<platform>` into your
  application’s Xcode project.
1. On your application targets' _Build Phases_ settings tab, click the _+_ icon and choose
  _New Run Script Phase_. Create a Run Script in which you specify your shell (ex: `/bin/sh`),
  add the following contents to the script area below the shell:
    ```sh
    /usr/local/bin/carthage copy-frameworks
    ```
- Add the paths to the frameworks you want to use under "Input Files". For example:
    ```
    $(SRCROOT)/Carthage/Build/iOS/UIKitJS.framework
    ```
- Add the paths to the copied frameworks to the "Output Files". For example:
    ```
    $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/UIKitJS.framework
    ```

Source: [Carthage][carthage] Quick Start guide.

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

- [ ] Guide coming soon

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
    static let bridge: JSBridge = {
        let modules = [ MyModule() ]
        return try! JSBridge(Bundle.main.url(forResource: "main", withExtension: "js"), modules: modules)
    }()
}
```

### Advanced Usage; Exposing Native UI Components

You can expose UI entry points through the JavaScript bridge to allow some UI component rendering
and handling inside JS code.

- [ ] Guide coming soon

## Example Project

You can find an example project inside UIKit.js, built for iOS. You can run it from any clone of this
repository by simply opening the `UIKit.js.xcodeproj` file in Xcode.

[twitter-hnryjms]: https://twitter.com/hnryjms
[jscore]: https://developer.apple.com/documentation/javascriptcore
[hnryjms]: https://hnryjms.io
[react-native]: https://github.com/facebook/react-native
[carthage]: https://github.com/Carthage/Carthage
