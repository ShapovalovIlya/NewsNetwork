//
//  Category.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 30.10.2024.
//

import Foundation

/// Варианты категории новостей
public enum Category: String, CaseIterable, Sendable {
    case business, entertainment, general, health, science, sports, technology
}
