//
//  Source.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//


public struct Source: Codable, Sendable, Hashable {
    public let id: String?
    public let name: String
    
    public init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
}
