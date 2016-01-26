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
struct AnyKey: Hashable {
	private let underlying: Any
	private let hashValueFunc: () -> Int
	private let equalityFunc: (Any) -> Bool

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

	var hashValue: Int { return hashValueFunc() }
}

func ==(x: AnyKey, y: AnyKey) -> Bool {
	return x.equalityFunc(y.underlying)
}
