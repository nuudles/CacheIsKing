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
		cache.set(item: 123, for: "123")

		XCTAssert(cache.cacheDictionary.count == 1)
		XCTAssert(cache.count == 1)
		XCTAssert(cache.item(for: "123") == 123)
		XCTAssert(cache.cacheDictionary[AnyKey("123")] as? Int == .some(123))
		XCTAssert(cache[123] == nil)

		cache[234] = "234"

		XCTAssert(cache.cacheDictionary.count == 2)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.item(for: 234) == "234")
		XCTAssert(cache.cacheDictionary[AnyKey(234)] as? String == .some("234"))

		// Test setting/getting an array
		let array = [1, 2, 3, 4, 5]
		cache[5] = array

		XCTAssert(cache.cacheDictionary.count == 3)
		XCTAssert(cache.count == 3)
		if let fetchedArray: [Int] = cache.item(for: 5) {
			XCTAssert(fetchedArray == array)
		} else {
			XCTFail("Expected an int array")
		}

		let testStruct = TestStruct(name: "Testing", value: Int(arc4random_uniform(100000)))
		cache["TestingStruct"] = testStruct

		guard let fetchedStruct: TestStruct = cache.item(for: "TestingStruct") else {
			XCTFail()
			return
		}
		XCTAssert(testStruct.name == fetchedStruct.name)
		XCTAssert(testStruct.value == fetchedStruct.value)
	}

	func testDifferentKindsOfKeys() {
		let cache = KingCache()

		let floatKey: Float = 123.456
		cache.set(item: 123.456, for: floatKey)
		XCTAssert(cache.item(for: floatKey) as Double? == .some(123.456))

		cache[floatKey] = 456.789
		XCTAssert(cache.count == 1)
		XCTAssert(cache[floatKey] as? Double == .some(456.789))

		cache.set(item: "123.456", for: "123.456")
		XCTAssert(cache.count == 2)
		XCTAssert(cache.item(for: "123.456") as String? == .some("123.456"))

		let boolKey = true
		cache.set(item: true, for: boolKey)
		XCTAssert(cache.count == 3)
		XCTAssert(cache.item(for: boolKey) as Bool? == .some(true))

		cache.remove(for: boolKey)
		XCTAssert(cache.count == 2)
		XCTAssert(cache.item(for: boolKey) as Bool? == .none)
	}

	func testSettingAndGettingEnum() {
		let cache = KingCache()
		cache["ABC"] = TestEnum.abc
		cache["DEF"] = TestEnum.def("BlahBlahBlah")
		cache["GHI"] = TestEnum.ghi(-500)

		guard let abc: TestEnum = cache.item(for: "ABC"),
			let def: TestEnum = cache.item(for: "DEF"),
			let ghi: TestEnum = cache.item(for: "GHI")
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
		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 4)

		cache.remove(for: 123)

		XCTAssert(cache.count == 3)
		XCTAssert(cache[123] == nil)

		cache[234] = nil

		XCTAssert(cache.count == 2)
		XCTAssert(cache[234] == nil)

		cache.removeAll()

		XCTAssert(cache.count == 0)

		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 4)

		NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
		                                object: UIApplication.shared)

		XCTAssert(cache.count == 0)

		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 4)

		NotificationCenter.default.post(name: NSNotification.Name.UIApplicationDidEnterBackground,
		                                object: UIApplication.shared)

		XCTAssert(cache.count == 0)

		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 4)

		// Make sure an unknown key doesn't have any weird side effects
		cache[567] = nil

		XCTAssert(cache.count == 4)

		cache.remove(for: 999)

		XCTAssert(cache.count == 4)
	}

	func testRemoveMatching() {
		let cache = KingCache()
		cache.set(item: 123, for: "123")
		cache.set(item: 1234, for: "1234")
		cache.set(item: 12345, for: "12345")
		cache.set(item: 234, for: "234")
		cache.set(item: 345, for: "345")

		XCTAssertEqual(cache.count, 5)

		// Filter out all keys with prefix "1"
		cache.remove { (key: String) -> Bool in
			return key.hasPrefix("1")
		}

		XCTAssertEqual(cache.count, 2)
		XCTAssertNil(cache.item(for: "123"))
		XCTAssertNil(cache.item(for: "1234"))
		XCTAssertNil(cache.item(for: "12345"))
		XCTAssertEqual(cache.item(for: "234"), .some(234))
		XCTAssertEqual(cache.item(for: "345"), .some(345))

		// Filtering with a different kind of key should have no effect
		cache.remove { (_: Int) -> Bool in
			return true
		}

		XCTAssertEqual(cache.count, 2)
		XCTAssertEqual(cache.item(for: "234"), .some(234))
		XCTAssertEqual(cache.item(for: "345"), .some(345))

		// Filtering with just true should remove all
		cache.remove { (_: String) -> Bool in
			return true
		}

		XCTAssertEqual(cache.count, 0)
		XCTAssertNil(cache.item(for: "234"))
		XCTAssertNil(cache.item(for: "345"))
	}

	func testCountLimit() {
		let cache = KingCache()
		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 4)

		cache.countLimit = 3

		XCTAssert(cache.count == 3)

		cache.removeAll()

		XCTAssert(cache.count == 0)

		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

		XCTAssert(cache.count == 3)

		cache[567] = 567
		XCTAssert(cache.count == 3)

		cache.removeAll()

		cache.set(item: 123, for: 123)
		cache.set(item: 234, for: 234)
		cache.set(item: 345, for: 345)
		cache.set(item: 456, for: 456)

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
		cache.set(item: oldCache, for: "InceptionCache")

		guard let _: NSCache<AnyObject, AnyObject> = cache.item(for: "InceptionCache") else {
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
