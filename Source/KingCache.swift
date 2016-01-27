//
//  KingCache.swift
//  CacheIsKing
//
//  Created by Christopher Luu on 1/26/16.
//
//

import Foundation

public class KingCache {
	// MARK: - Private variables
	private var notificationObservers: [NSObjectProtocol] = []

	// MARK: - Internal variables
	var cacheDictionary: [AnyKey: Any] = [:]

	// MARK: - Public variables
	public var count: Int {
		return cacheDictionary.count
	}
	public var countLimit: UInt = 0 {
		didSet {
			evictItemsIfNeeded()
		}
	}

	// MARK: - Initialization methods
	public init() {
		let removalBlock = { [unowned self] (_: NSNotification) in
			self.cacheDictionary.removeAll()
		}

		var notificationObserver = NSNotificationCenter.defaultCenter()
			.addObserverForName(UIApplicationDidReceiveMemoryWarningNotification,
				object: UIApplication.sharedApplication(),
				queue: nil,
				usingBlock: removalBlock)
		notificationObservers.append(notificationObserver)
		notificationObserver = NSNotificationCenter.defaultCenter()
			.addObserverForName(UIApplicationDidEnterBackgroundNotification,
				object: UIApplication.sharedApplication(),
				queue: nil,
				usingBlock: removalBlock)
		notificationObservers.append(notificationObserver)
	}

	deinit {
		notificationObservers.forEach {
			NSNotificationCenter.defaultCenter().removeObserver($0)
		}
	}

	// MARK: - Internal methods
	func evictItemsIfNeeded() {
		if countLimit > 0 && cacheDictionary.count > Int(countLimit) {
			// TODO: Evict items with more rhyme or reason
			var keys = cacheDictionary.keys.flatMap { $0 }
			while cacheDictionary.count > Int(countLimit) {
				let randomIndex = Int(arc4random_uniform(UInt32(keys.count)))
				let key = keys.removeAtIndex(randomIndex)
				cacheDictionary.removeValueForKey(key)
			}
		}
	}

	// MARK: - Public methods
	public func setItem<K: Hashable>(item: Any, forKey key: K) {
		cacheDictionary[AnyKey(key)] = item
		evictItemsIfNeeded()
	}

	public func itemForKey<T, K: Hashable>(key: K) -> T? {
		if let item = cacheDictionary[AnyKey(key)] as? T {
			return item
		}
		return nil
	}

	public func removeItemForKey<K: Hashable>(key: K) {
		cacheDictionary[AnyKey(key)] = nil
	}

	public func removeAllItems() {
		cacheDictionary.removeAll()
	}

	// MARK: - Subscript methods
	// TODO: Consolidate these subscript methods once subscript generics with constraints are supported
	public subscript(key: Int) -> Any? {
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

	public subscript(key: Float) -> Any? {
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

	public subscript(key: String) -> Any? {
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
