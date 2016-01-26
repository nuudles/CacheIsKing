# CacheIsKing

<a href="https://github.com/Carthage/Carthage/issues/179">
    <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
</a>

`CacheIsKing` is a simple cache that allows you to store any item, including objects, pure Swift structs, enums (with associated values), etc. Simply put, it's designed to act like an `NSCache` for everything, including Swift variables.

## Features

- Simply set, get, and remove items based on any key that is `Hashable`
- The cache is cleared when the app receives a memory warning
- Similar to `NSCache`, the cache is cleared when the app enters the background
- Subscripts are supported for `String`, `Int`, and `Float` keys
- `itemForKey` uses generics so you don't have to cast the return value when the type is inferred correctly
- Similar to `NSCache`, the cache can have a `countLimit` set to ensure that the cache doesn't get too large

## Requirements

- iOS 8.0+
- tvOS 9.0+
- Xcode 7+

## Installation using CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

Because `CacheIsKing ` is written in Swift, you must use frameworks.

To integrate `CacheIsKing ` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'CacheIsKing'
```

Then, run the following command:

```bash
$ pod install
```

## Installation using Carthage

Add this to your `Cartfile`:

```
github "nuudles/CacheIsKing"
```

## Usage

Simply use the `KingCache` class similar to how you'd use a `NSCache`. Using the `setItem` and `itemForKey` methods allow you to use type inference to get the values you want.

```swift
let cache = KingCache()
cache.setItem(123, forKey: "123")

if let item: Int = cache.itemForKey(456) {
	doSomethingWithItem(item)
}
```

You can also use subscripts to set/get items from the cache. Unfortunately since Swift doesn't support subscript methods with generics yet, you'll have to cast your items as necessary. Also currently only `String`, `Int`, and `Float` keys are supported:

```swift
let cache = KingCache()
cache["123"] = 123

if let item = cache[456] as? Int {
	doSomethingWithItem(item)
}
```

The `KingCache` also has a `countLimit` property, which allows you to set the maximum number of items in the cache. It currently evicts randomly until the `countLimit` is met.

```swift
let cache = KingCache()
cache.countLimit = 2

cache[123] = 123
cache[234] = 234
cache[345] = 345

print("\(cache.count)") // shows a count of 2
```

## TODO

- Refine eviction algorithm (currently evicts randomly)
- Update with better subscript support once Swift supports subscripts with generics