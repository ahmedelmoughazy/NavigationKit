//
//  main.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 17.08.25.
//
import Foundation

/// Code generator that scans source files and generates navigation routes
@main
struct NavigationCodeGenerator {
    
    static func main() throws {
        let arguments = Array(CommandLine.arguments.dropFirst())
        
        guard arguments.count >= 2 else {
            print(LogConstants.usageMessage)
            return
        }
        
        let sourceRoot = arguments[0]
        let outputPath = arguments[1]
        
        print(LogConstants.scanningMessage + sourceRoot)
        
        let views = try scanForNavigableViews(in: sourceRoot)
        print(String(format: LogConstants.foundMessage, views.count))
        
        if views.isEmpty { return }
        
        let generatedCode = generateNavigationCode(from: views)
        try generatedCode.write(toFile: outputPath, atomically: true, encoding: .utf8)
        print(LogConstants.generatedMessage + outputPath)
    }
    
    static func scanForNavigableViews(in sourceRoot: String) throws -> [ViewInfo] {
        let fileManager = FileManager.default
        var views: [ViewInfo] = []
        func scanDirectory(_ path: String) throws {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for item in contents {
                let itemPath = "\(path)/\(item)"
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        if !["build", ".build", "Generated", ".git"].contains(item) {
                            try scanDirectory(itemPath)
                        }
                    } else if item.hasSuffix(".swift") {
                        if let content = try? String(contentsOfFile: itemPath) {
                            views.append(contentsOf: extractNavigableViews(from: content))
                        }
                    }
                }
            }
        }
        try scanDirectory(sourceRoot)
        return views
    }
    
    static func extractNavigableViews(from content: String) -> [ViewInfo] {
        let lines = content.components(separatedBy: .newlines)
        var views: [ViewInfo] = []
        var isRoutable = false
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "@Routable" {
                isRoutable = true
                continue
            }
            if isRoutable && (trimmed.contains("struct") || trimmed.contains("class")) && trimmed.contains("View") {
                if let viewName = extractViewName(from: trimmed) {
                    let parameters = extractParameters(for: viewName, in: lines, startingFrom: index)
                    views.append(ViewInfo(name: viewName, parameters: parameters))
                }
                isRoutable = false
            }
        }
        return views
    }
    
    static func extractViewName(from line: String) -> String? {
        let patterns = [
            #"struct\s+(\w+)\s*:"#,
            #"class\s+(\w+)\s*:"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)),
               let range = Range(match.range(at: 1), in: line) {
                return String(line[range])
            }
        }
        return nil
    }
    
    static func extractParameters(for viewName: String, in lines: [String], startingFrom index: Int) -> [ViewInfo.Parameter] {
        var parameters: [ViewInfo.Parameter] = []
        var foundExplicitInit = false
        var braceDepth = 0
        for i in index..<min(index + 50, lines.count) {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.contains("{") { braceDepth += 1 }
            if line.contains("}") {
                braceDepth -= 1
                if braceDepth <= 0 { break }
            }
            if line.contains("body:") && line.contains("some View") {
                continue
            }
            if line.contains("init(") {
                foundExplicitInit = true
                parameters = parseInitParameters(from: line)
                break
            }
            if !foundExplicitInit, let property = parseStoredProperty(from: line) {
                parameters.append(property)
            }
        }
        return parameters
    }
    
    static func parseInitParameters(from line: String) -> [ViewInfo.Parameter] {
        guard let paramListStart = line.firstIndex(of: "(") else { return [] }
        guard let paramListEnd = line.lastIndex(of: ")") else { return [] }
        let paramsString = line[paramListStart...paramListEnd]
        let params = paramsString.dropFirst().dropLast().split(separator: ",")
        var result: [ViewInfo.Parameter] = []
        for param in params {
            let paramStr = param.trimmingCharacters(in: .whitespaces)
            if paramStr.contains("@EnvironmentObject") {
                continue
            }
            let pattern = #"(?:\w+\s+)?(\w+)\s*:\s*([^=]+)(?:\s*=\s*[^,]+)?"#
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: paramStr, range: NSRange(location: 0, length: paramStr.utf16.count)),
               let nameRange = Range(match.range(at: 1), in: paramStr),
               let typeRange = Range(match.range(at: 2), in: paramStr) {
                let name = String(paramStr[nameRange])
                let type = String(paramStr[typeRange]).trimmingCharacters(in: .whitespaces)
                let hasDefault = paramStr.contains("=")
                result.append(ViewInfo.Parameter(name: name, type: type, hasDefaultValue: hasDefault))
            }
        }
        return result
    }
    
    static func parseStoredProperty(from line: String) -> ViewInfo.Parameter? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.contains("@EnvironmentObject") {
            return nil
        }
        let pattern = #"(?:let|var)\s+(\w+)\s*:\s*([^=\n{]+)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count)),
           let nameRange = Range(match.range(at: 1), in: trimmed),
           let typeRange = Range(match.range(at: 2), in: trimmed) {
            let name = String(trimmed[nameRange])
            let type = String(trimmed[typeRange]).trimmingCharacters(in: .whitespaces)
            let hasDefault = trimmed.contains("=")
            return ViewInfo.Parameter(name: name, type: type, hasDefaultValue: hasDefault)
        }
        return nil
    }
    
    static func generateNavigationCode(from views: [ViewInfo]) -> String {
        var output = """
// Generated by Navigation package - do not edit manually
// Generated at: \(Date())
import SwiftUI
import Navigation

public enum NavigationRoute: Hashable, Identifiable, CustomStringConvertible, View {

"""
        for view in views {
            output += "    \(view.enumCaseDeclaration)\n"
        }
        output += """

    public var id: String {
        description
    }

"""
        output += """

    public var description: String {
        switch self {

"""
        for view in views {
            output += "        \(view.switchCaseDescription)\n"
        }
        output += """
        }
    }

"""
        output += """

    @ViewBuilder
    public var body: some View {
        switch self {

"""
        for view in views {
            output += "        \(view.switchCase)\n"
        }
        output += """
        }
    }
}

"""
        return output
    }
}

private enum LogConstants {
    static let usageMessage = "Usage: NavigationCodeGenerator <source-root> <output-path>"
    static let scanningMessage = "🔍 Scanning for @Routable views in: "
    static let foundMessage = "📱 Found %d routable views"
    static let generatedMessage = "✅ Generated navigation routes at: "
}
