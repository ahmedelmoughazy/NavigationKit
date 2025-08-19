//
//  ViewInfo.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 20.08.25.
//
import Foundation

struct ViewInfo {
    let name: String
    let parameters: [Parameter]
    
    struct Parameter {
        let name: String
        let type: String
        let hasDefaultValue: Bool
    }
    
    var enumCaseName: String {
        name.prefix(1).lowercased() + name.dropFirst()
    }
    
    var enumCaseDeclaration: String {
        if parameters.isEmpty {
            return "case \(enumCaseName)"
        } else {
            let params = parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
            return "case \(enumCaseName)(\(params))"
        }
    }
    
    var switchCase: String {
        if parameters.isEmpty {
            return "case .\(enumCaseName): \(name)()"
        } else {
            let bindings = parameters.map { "let \($0.name)" }.joined(separator: ", ")
            let params = parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            return "case .\(enumCaseName)(\(bindings)): \(name)(\(params))"
        }
    }
    
    var switchCaseDescription: String {
        "case .\(enumCaseName): \"\(enumCaseName)\""
    }
}
