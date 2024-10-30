//
//  EndpointTests.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 26.10.2024.
//

import Foundation
import Testing
@testable import Repository

struct EndpointTests {
    @Test func base() async throws {
        let expected = try Endpoint.new().reduceToUrl().get()
        #expect(expected.absoluteString == "https://newsapi.org/v2")
    }
    
    @Test func everything() async throws {
        let sut = try Endpoint.everything.reduceToUrl().get().absoluteString
        
        #expect(sut == "https://newsapi.org/v2/everything")
    }
    
    @Test func topHeadlines() async throws {
        let sut = try Endpoint.topHeadlines.reduceToUrl().get()
        #expect(sut.absoluteString == "https://newsapi.org/v2/top-headlines")
    }
    
    @Test(arguments: Repository.Category.allCases)
    func popular(category: Repository.Category) async throws {
        let sut = try Endpoint
            .popular(category)
            .reduceToUrl()
            .get()
        let expected = "https://newsapi.org/v2/top-headlines?category=\(category)"
        
        #expect(sut.absoluteString == expected)
    }
}
