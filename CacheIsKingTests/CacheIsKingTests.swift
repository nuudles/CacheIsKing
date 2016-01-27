//
//  CacheIsKingTests.swift
//  CacheIsKingTests
//
//  Created by Christopher Luu on 1/26/16.
//
//

import XCTest
@testable import CacheIsKing

class CacheIsKingTests: XCTestCase {
	func testSettingAndGettingItems() {
		let cache = KingCache()
		cache.setItem(123, forKey: "123")

		XCTAssert(cache.cacheDictionary.count == 1)
		XCTAssert(cache.count == 1)
		XCTAssert(cache.itemForKey("123") == 123)
		XCTAssert(cache.cacheDictionary[AnyKey("123")] as? Int == .Some(123))
		XCTAssert(cache[123] == nil)

		cache[234] = "234"

		XCTAssert(cache.cacheDictionary.count == 2)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey(234) == "234")
		XCTAssert(cache.cacheDictionary[AnyKey(234)] as? String == .Some("234"))

		// Test setting/getting an array
		let array = [1, 2, 3, 4, 5]
		cache[5] = array

		XCTAssert(cache.cacheDictionary.count == 3)
		XCTAssert(cache.count == 3)
		if let fetchedArray: [Int] = cache.itemForKey(5) {
			XCTAssert(fetchedArray == array)
		}
		else {
			XCTFail("Expected an int array")
		}

		let testStruct = TestStruct(name: "Testing", value: Int(arc4random_uniform(100000)))
		cache["TestingStruct"] = testStruct

		guard let fetchedStruct: TestStruct = cache.itemForKey("TestingStruct") else {
			XCTFail()
			return
		}
		XCTAssert(testStruct.name == fetchedStruct.name)
		XCTAssert(testStruct.value == fetchedStruct.value)
	}

	func testDifferentKindsOfKeys() {
		let cache = KingCache()

		let floatKey: Float = 123.456
		cache.setItem(123.456, forKey: floatKey)
		XCTAssert(cache.itemForKey(floatKey) as Double? == .Some(123.456))

		cache[floatKey] = 456.789
		XCTAssert(cache.count == 1)
		XCTAssert(cache[floatKey] as? Double == .Some(456.789))

		cache.setItem("123.456", forKey: "123.456")
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey("123.456") as String? == .Some("123.456"))

		let boolKey = true
		cache.setItem(true, forKey: boolKey)
		XCTAssert(cache.count == 3)
		XCTAssert(cache.itemForKey(boolKey) as Bool? == .Some(true))

		cache.removeItemForKey(boolKey)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey(boolKey) as Bool? == .None)
	}

	func testSettingAndGettingEnum() {
		let cache = KingCache()
		cache["ABC"] = TestEnum.ABC
		cache["DEF"] = TestEnum.DEF("BlahBlahBlah")
		cache["GHI"] = TestEnum.GHI(-500)

		guard let abc: TestEnum = cache.itemForKey("ABC"),
			def: TestEnum = cache.itemForKey("DEF"),
			ghi: TestEnum = cache.itemForKey("GHI")
			else {
				XCTFail()
				return
			}
		switch (abc, def, ghi) {
		case (.ABC, .DEF(let stringValue), .GHI(let intValue)):
			XCTAssert(stringValue == "BlahBlahBlah")
			XCTAssert(intValue == -500)
		default:
			XCTFail()
		}
	}

	func testSubscripts() {
		let cache = KingCache()

		// Int subscript
		cache[123] = 123
		XCTAssert(cache[123] as? Int == .Some(123))
		XCTAssert(cache.count == 1)

		cache[123] = nil
		XCTAssert(cache[123] as? Int == .None)
		XCTAssert(cache.count == 0)

		// String subscript
		cache["123"] = 123
		XCTAssert(cache["123"] as? Int == .Some(123))
		XCTAssert(cache.count == 1)

		cache["123"] = nil
		XCTAssert(cache["123"] as? Int == .None)
		XCTAssert(cache.count == 0)

		// Float subscript
		let floatKey: Float = 3.14
		cache[floatKey] = 123
		XCTAssert(cache[floatKey] as? Int == .Some(123))
		XCTAssert(cache.count == 1)
		
		cache[floatKey] = nil
		XCTAssert(cache[floatKey] as? Int == .None)
		XCTAssert(cache.count == 0)
	}

	func testRemovingItems() {
		let cache = KingCache()
		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		cache.removeItemForKey(123)

		XCTAssert(cache.count == 3)
		XCTAssert(cache[123] == nil)

		cache[234] = nil

		XCTAssert(cache.count == 2)
		XCTAssert(cache[234] == nil)

		cache.removeAllItems()

		XCTAssert(cache.count == 0)

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidReceiveMemoryWarningNotification, object: UIApplication.sharedApplication())

		XCTAssert(cache.count == 0)

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication())

		XCTAssert(cache.count == 0)
	}

	func testCountLimit() {
		let cache = KingCache()
		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		cache.countLimit = 3

		XCTAssert(cache.count == 3)

		cache.removeAllItems()

		XCTAssert(cache.count == 0)

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 3)

		cache[567] = 567
		XCTAssert(cache.count == 3)

		cache.removeAllItems()

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		cache.countLimit = 2

		XCTAssert(cache.count == 2)
	}

	func testEmptyEviction() {
		// Make sure that an eviction on an empty dictionary doesn't crash
		let cache = KingCache()
		cache.evictItemsIfNeeded()
	}

	func testObjCObjects() {
		let cache = KingCache()

		let oldCache = NSCache()
		cache.setItem(oldCache, forKey: "InceptionCache")

		guard let _: NSCache = cache.itemForKey("InceptionCache") else {
			XCTFail("Expected an NSCache object")
			return
		}
	}
}

private struct TestStruct {
	let name: String
	let value: Int
}

private enum TestEnum {
	case ABC
	case DEF(String)
	case GHI(Int)
}
