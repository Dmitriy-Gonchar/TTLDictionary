//
//  TTLDictionary.swift
//
//  Created by Jesus++ on 21.05.2023.
//

import Foundation

public struct TTLDictionary<Key: Hashable, Value: Any>: Collection
{
	// private properties:
	private var dictionary = [Key: [(object: Value, createdAt: Double, ttl: Double)]]()
	private var proxyDictionary: DictionaryType { self.dictionary.compactMapValues { $0.first?.object } }
	private var time: TimeInterval { Date().timeIntervalSince1970 }

	// public types:
	public typealias DictionaryType = [Key: Value]
	public typealias IndexDistance = Int
	public typealias Indices = DictionaryType.Indices
	public typealias Iterator = DictionaryType.Iterator
	public typealias SubSequence = DictionaryType.SubSequence
	public typealias Index = DictionaryType.Index

	// public properties:
	public var startIndex: Index { self.proxyDictionary.startIndex }
	public var endIndex: DictionaryType.Index { self.proxyDictionary.endIndex }
	public var indices: Indices { self.proxyDictionary.indices }

	// public methods:
	public func index(after index: Index) -> Index { self.proxyDictionary.index(after: index) }
	public func makeIterator() -> DictionaryType.Iterator { self.proxyDictionary.makeIterator() }
	public subscript(position: Index) -> Iterator.Element { self.proxyDictionary[position] }
	public subscript(bounds: Range<Index>) -> SubSequence { self.proxyDictionary[bounds] }
	public subscript(key: Key) -> Value? { mutating get { self[key, ttl: 0] } set { self[key, ttl: 0] = newValue } }
	public subscript(key: Key, ttl ttl: TimeInterval) -> Value?
	{
		mutating get
		{
			let date = self.time
			self.dictionary[key] = self.dictionary[key]?.filter { $0.createdAt + $0.ttl > date }
			return self.dictionary[key]?.sorted { $1.createdAt > $0.createdAt }.last?.object
		}
		set
		{
			guard let newValue = newValue else { return }
			let obj = (object: newValue, createdAt: self.time, ttl: ttl)
			self.dictionary[key] = [obj] + ((self.dictionary[key]?.isEmpty ?? true) ? [] : self.dictionary[key] ?? [])
		}
	}

	init(with dictionary: DictionaryType)
	{
		self.dictionary = dictionary.compactMapValues { [(object: $0, createdAt: self.time, ttl: .greatestFiniteMagnitude)] }
	}
}

extension Dictionary
{
	func makeTTL() -> TTLDictionary<Self.Key, Self.Value>
	{
		.init(with: self)
	}
}
