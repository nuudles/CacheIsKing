//
//  KingCache.swift
//  CacheIsKing
//
//  Created by Christopher Luu on 1/26/16.
//
//

import Foundation

/// `KingCache` is a simple cache that can hold anything, including Swift structs, enums, and values.
/// It is designed to work similar to the `NSCache`, but with native Swift support.
///
open class KingCache {
	// MARK: - Private variables
	/// An array of `NSNotificationCenter` observers that need to be removed upon deinitialization
	fileprivate var notificationObservers: [NSObjectProtocol] = []

	// MARK: - Internal variables
	/// The dictionary that holds the cached values
	var cacheDictionary: [AnyKey: Any] = [:]

	// MARK: - Public variables
	/// The number of items in the cache
	open var count: Int {
		return cacheDictionary.count
	}
	/// The limit of the amount of items that can be held in the cache. This defaults to 0, which means there is no limit.
	open var countLimit: UInt = 0 {
		didSet {
			evictItemsIfNeeded()
		}
	}

	// MARK: - Initialization methods
	public init() {
		let removalBlock = { [unowned self] (_: Notification) in
			self.cacheDictionary.removeAll()
		}

		var notificationObserver = NotificationCenter.default
			.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
				object: UIApplication.shared,
				queue: nil,
				using: removalBlock)
		notificationObservers.append(notificationObserver)
		notificationObserver = NotificationCenter.default
			.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground,
				object: UIApplication.shared,
				queue: nil,
				using: removalBlock)
		notificationObservers.append(notificationObserver)
	}

	deinit {
		notificationObservers.forEach {
			NotificationCenter.default.removeObserver($0)
		}
	}

	// MARK: - Internal methods
	/// Evicts items if the `countLimit` has been reached.
	/// This currently uses a random eviction policy, kicking out random items until the `countLimit` is satisfied.
	///
	func evictItemsIfNeeded() {
		if countLimit > 0 && cacheDictionary.count > Int(countLimit) {
			// TODO: Evict items with more rhyme or reason
			var keys = Array(cacheDictionary.keys)
			while cacheDictionary.count > Int(countLimit) {
				let randomIndex = Int(arc4random_uniform(UInt32(keys.count)))
				let key = keys.remove(at: randomIndex)
				cacheDictionary.removeValue(forKey: key)
			}
		}
	}

	// MARK: - Public methods
	/// Adds an item to the cache for any given `Hashable` key.
	///
	/// - parameter item: The item to be cached
	/// - parameter key: The key with which to cache the item
	///
	open func setItem<K: Hashable>(_ item: Any, forKey key: K) {
		cacheDictionary[AnyKey(key)] = item
		evictItemsIfNeeded()
	}

	/// Gets an item from the cache if it exists for a given `Hashable` key.
	/// This method uses generics to infer the type that should be returned.
	///
	/// Note: Even if an item exists for the key, but does not match the given type, it will return `nil`.
	///
	/// - parameter key: The key whose item should be fetched
	/// - returns: The item from the cache if it exists, or `nil` if an item could not be found
	///
	open func itemForKey<T, K: Hashable>(_ key: K) -> T? {
		if let item = cacheDictionary[AnyKey(key)] as? T {
			return item
		}
		return nil
	}

	/// Discards an item for a given `Hashable` key.
	///
	/// - parameter key: The key whose item should be removed
	///
	open func removeItemForKey<K: Hashable>(_ key: K) {
		cacheDictionary[AnyKey(key)] = nil
	}

	/// Clears the entire cache.
	///
	open func removeAllItems() {
		cacheDictionary.removeAll()
	}

	// MARK: - Subscript methods
	// TODO: Consolidate these subscript methods once subscript generics with constraints are supported
	/// A subscript method that allows `Int` key subscripts.
	///
	open subscript(key: Int) -> Any? {
		get {
			return itemForKey(key)
		}
		set {
			if let newValue = newValue {
				setItem(newValue, forKey: key)
			}
			else {
				removeItemForKey(key)
			}
		}
	}

	/// A subscript method that allows `Float` key subscripts.
	///
	open subscript(key: Float) -> Any? {
		get {
			return itemForKey(key)
		}
		set {
			if let newValue = newValue {
				setItem(newValue, forKey: key)
			}
			else {
				removeItemForKey(key)
			}
		}
	}

	/// A subscript method that allows `String` key subscripts.
	///
	open subscript(key: String) -> Any? {
		get {
			return itemForKey(key)
		}
		set {
			if let newValue = newValue {
				setItem(newValue, forKey: key)
			}
			else {
				removeItemForKey(key)
			}
		}
	}
}
