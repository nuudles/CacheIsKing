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
		XCTAssert(cache.cacheDictionary[AnyKey("123")] as? Int == .some(123))
		XCTAssert(cache[123] == nil)

		cache[234] = "234"

		XCTAssert(cache.cacheDictionary.count == 2)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey(234) == "234")
		XCTAssert(cache.cacheDictionary[AnyKey(234)] as? String == .some("234"))

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
		XCTAssert(cache.itemForKey(floatKey) as Double? == .some(123.456))

		cache[floatKey] = 456.789
		XCTAssert(cache.count == 1)
		XCTAssert(cache[floatKey] as? Double == .some(456.789))

		cache.setItem("123.456", forKey: "123.456")
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey("123.456") as String? == .some("123.456"))

		let boolKey = true
		cache.setItem(true, forKey: boolKey)
		XCTAssert(cache.count == 3)
		XCTAssert(cache.itemForKey(boolKey) as Bool? == .some(true))

		cache.removeItemForKey(boolKey)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.itemForKey(boolKey) as Bool? == .none)
	}

	func testSettingAndGettingEnum() {
		let cache = KingCache()
		cache["ABC"] = TestEnum.abc
		cache["DEF"] = TestEnum.def("BlahBlahBlah")
		cache["GHI"] = TestEnum.ghi(-500)

		guard let abc: TestEnum = cache.itemForKey("ABC"),
			let def: TestEnum = cache.itemForKey("DEF"),
			let ghi: TestEnum = cache.itemForKey("GHI")
			else {
				XCTFail()
				return
			}
		switch (abc, def, ghi) {
		case (.abc, .def(let stringValue), .ghi(let intValue)):
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
		XCTAssert(cache[123] as? Int == .some(123))
		XCTAssert(cache.count == 1)

		cache[123] = nil
		XCTAssert(cache[123] as? Int == .none)
		XCTAssert(cache.count == 0)

		// String subscript
		cache["123"] = 123
		XCTAssert(cache["123"] as? Int == .some(123))
		XCTAssert(cache.count == 1)

		cache["123"] = nil
		XCTAssert(cache["123"] as? Int == .none)
		XCTAssert(cache.count == 0)

		// Float subscript
		let floatKey: Float = 3.14
		cache[floatKey] = 123
		XCTAssert(cache[floatKey] as? Int == .some(123))
		XCTAssert(cache.count == 1)
		
		cache[floatKey] = nil
		XCTAssert(cache[floatKey] as? Int == .none)
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

		NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)

		XCTAssert(cache.count == 0)

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidEnterBackground, object: UIApplication.shared)

		XCTAssert(cache.count == 0)

		cache.setItem(123, forKey: 123)
		cache.setItem(234, forKey: 234)
		cache.setItem(345, forKey: 345)
		cache.setItem(456, forKey: 456)

		XCTAssert(cache.count == 4)

		// Make sure an unknown key doesn't have any weird side effects
		cache[567] = nil

		XCTAssert(cache.count == 4)

		cache.removeItemForKey(999)

		XCTAssert(cache.count == 4)
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

		let oldCache = NSCache<AnyObject, AnyObject>()
		cache.setItem(oldCache, forKey: "InceptionCache")

		guard let _: NSCache<AnyObject, AnyObject> = cache.itemForKey("InceptionCache") else {
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
	case abc
	case def(String)
	case ghi(Int)
}
