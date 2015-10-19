# SwiftServerExamples

Server side application ([isucon5](https://github.com/isucon/isucon5-qualify)) implementations in Swift. Under development.

Note: Since I haven't figured out an easy way to connect to db in Swift only dummy data is used instead of real data..

## Usage

### Setup

```sh
pod install
carthage update
```

### Run

```sh
xcrun swift -F Carthage/Build/Mac -F Rome swifterServer.swift

# or

xcrun swift -F Carthage/Build/Mac -F Rome taylorServer.swift
```

