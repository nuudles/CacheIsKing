//
//  AnyKey.swift
//  CacheIsKing
//
//  Created by Christopher Luu on 1/26/16.
//
//

import Foundation

/// This code was taken from:
/// http://stackoverflow.com/questions/24119624/how-to-create-dictionary-that-can-hold-anything-in-key-or-all-the-possible-type
///
/// `AnyKey` is a simple struct that conforms to `Hashable` to allow any other
/// `Hashable` key to be used in the cache dictionary
struct AnyKey: Hashable {
	/// The underlying value
	let underlying: Any
	/// The hashing function
	fileprivate let hashValueFunc: () -> Int
	/// The equality function
	fileprivate let equalityFunc: (Any) -> Bool

	init<T: Hashable>(_ key: T) {
		underlying = key
		// Capture the key's hashability and equatability using closures.
		// The Key shares the hash of the underlying value.
		hashValueFunc = { key.hashValue }

		// The Key is equal to a Key of the same underlying type,
		// whose underlying value is "==" to ours.
		equalityFunc = {
			if let other = $0 as? T {
				return key == other
			}
			return false
		}
	}

	/// `Hashable` protocol conformance
	var hashValue: Int { return hashValueFunc() }
}

func == (lhs: AnyKey, rhs: AnyKey) -> Bool {
	return lhs.equalityFunc(rhs.underlying)
}
