# Device

Device provides a platform-agnostic framework for accessing device details, including the device name, model, operating system version, processor count, and thermal state.

In addition, Device includes a Battery class for monitoring the battery level of the device. This class is an observable object with published properties, making it easy to track changes in the battery level, charging state, low power mode, etc. over time.

## Features
* Access to device details such as name, model, and operating system version
* Cross-platform support for macOS, iOS, tvOS, watchOS
* Battery monitoring with the Battery class
* Thermal state monitoring

## Installation
You can add the Device framework to your project via Swift Package Manager. Simply go to File > Swift Packages > Add Package Dependency and enter the following URL: https://github.com/pmanot/Device.

## Usage
To access device details and monitor the battery level, create an instance of the Device class:
swift
```swift
import Device
let device = Device.current
```

You can then access the various properties of the Device class, such as the device name and model:
```swift
print(device.name) // "iPhone" 
print(device.model) // "iPhone"

```

You can also monitor changes in the thermal state of the device:
```swift
device.$thermalState.sink { thermalState in 
      print("Thermal state changed: \(thermalState)")
}
.store(in: &cancellables)
```

Finally, you can monitor the battery level with the Battery class:
```swift
let battery = Battery()

battery.$level.sink { level in 
      print("Battery level changed: \(level)") 
}
.store(in: &cancellables)
```

## Contributing
Contributions are welcome! If you find a bug or have a feature request, please create an issue. If you want to contribute code, please create a pull request.

## License
Device is available under the MIT license. See the LICENSE file for more info.

