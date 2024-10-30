//
//  Sorting.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//


/// The order to sort the news articles in.
///
/// Default sorting: `publishedAt`
public enum Sorting: String {
    
    /// Articles more closely related to query come first.
    case relevancy
    
    /// Articles from popular sources and publishers come first.
    case popularity
    
    /// Newest articles come first.
    case publishedAt
}
