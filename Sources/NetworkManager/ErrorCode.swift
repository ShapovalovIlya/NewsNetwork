//
//  ErrorCode.swift
//  NewsNetwork
//
//  Created by Илья Шаповалов on 28.10.2024.
//


public enum ErrorCode: String {
    /// Your API key has been disabled.
    case apiKeyDisabled
    
    /// Your API key has no more requests available.
    case apiKeyExhausted
    
    /// Your API key hasn't been entered correctly. Double check it and try again.
    case apiKeyInvalid
    
    /// Your API key is missing from the request. Append it to the request with one of these methods.
    case apiKeyMissing
    
    /// You've included a parameter in your request which is currently not supported.
    /// Check the message property for more details.
    case parameterInvalid
    
    /// Required parameters are missing from the request and it cannot be completed.
    /// Check the message property for more details.
    case parametersMissing
    
    /// You have been rate limited. Back off for a while before trying the request again.
    case rateLimited
    
    /// You have requested too many sources in a single request.
    /// Try splitting the request into 2 smaller requests.
    case sourcesTooMany
    
    /// You have requested a source which does not exist.
    case sourceDoesNotExist
    
    /// This shouldn't happen, and if it does then it's our fault, not yours.
    /// Try the request again shortly.
    case unexpectedError
}