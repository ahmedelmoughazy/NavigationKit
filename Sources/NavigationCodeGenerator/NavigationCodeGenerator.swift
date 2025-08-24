//
//  NavigationCodeGenerator.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 17.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import Foundation

// MARK: - NavigationCodeGenerator

/// Main entry point for the navigation code generation tool.
///
/// This executable scans Swift source files for views marked with @Routable
/// and generates a comprehensive NavigationRoute enum that provides type-safe
/// navigation throughout the application.
///
/// Usage: NavigationCodeGenerator <source-root> <output-path>
@main
struct NavigationCodeGenerator {
    
    // MARK: - Main Entry Point
    
    /// Main execution function for the code generator.
    ///
    /// Processes command line arguments, scans for routable views, and generates
    /// the navigation code files for each unique route name.
    ///
    /// - Throws: Various errors related to file operations or invalid arguments
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
        
        // Determine if outputPath is a directory or file
        let outputFilePath: String
        if outputPath.hasSuffix(".swift") {
            // Legacy mode: single file output
            outputFilePath = outputPath
            print("🔧 DEBUG: Single file mode - outputFilePath: \(outputFilePath)")
        } else {
            // New mode: directory output - create a single file with all routes
            outputFilePath = URL(fileURLWithPath: outputPath).appendingPathComponent("NavigationRoutes.swift").path
            print("🔧 DEBUG: Directory mode - outputFilePath: \(outputFilePath)")
        }
        
        // Group views by route names
        let routeGroups = groupViewsByRoute(views)
        
        // Generate a single file containing all route enums
        let generatedCode = generateAllNavigationCode(from: routeGroups)
        try generatedCode.write(toFile: outputFilePath, atomically: true, encoding: String.Encoding.utf8)
        print(LogConstants.generatedMessage + outputFilePath)
    }
    
    /// Groups views by their route names, handling multi-route views.
    ///
    /// Views that belong to multiple routes will appear in multiple groups.
    ///
    /// - Parameter viewsWithRoutes: Array of (ViewInfo, [String]) tuples to group
    /// - Returns: Dictionary mapping route names to arrays of views
    private static func groupViewsByRoute(_ viewsWithRoutes: [(ViewInfo, [String])]) -> [String: [ViewInfo]] {
        var routeGroups: [String: [ViewInfo]] = [:]
        
        for (view, routeNames) in viewsWithRoutes {
            for routeName in routeNames {
                if routeGroups[routeName] == nil {
                    routeGroups[routeName] = []
                }
                routeGroups[routeName]?.append(view)
            }
        }
        
        return routeGroups
    }
}

// MARK: - File Scanning
extension NavigationCodeGenerator {
    
    /// Recursively scans a directory tree for Swift files containing @Routable views.
    ///
    /// This method traverses the source directory structure, excluding build artifacts
    /// and other non-source directories, and extracts view information from all
    /// Swift files found.
    ///
    /// - Parameter sourceRoot: The root directory path to start scanning from
    /// - Returns: Array of (ViewInfo, [String]) tuples representing all discovered routable views with their route names
    /// - Throws: FileManager errors if directory access fails
    static func scanForNavigableViews(in sourceRoot: String) throws -> [(ViewInfo, [String])] {
        let fileManager = FileManager.default
        var views: [(ViewInfo, [String])] = []
        
        /// Recursively scans a directory for Swift files
        func scanDirectory(_ path: String) throws {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for item in contents {
                let itemPath = "\(path)/\(item)"
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // Skip build and generated directories
                        if !DirectoryConstants.excludedDirectories.contains(item) {
                            try scanDirectory(itemPath)
                        }
                    } else if item.hasSuffix(FileConstants.swiftExtension) {
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
}

// MARK: - View Extraction
extension NavigationCodeGenerator {
    
    /// Extracts @Routable views from Swift source code content.
    ///
    /// Parses the source code line by line to find views decorated with the
    /// @Routable macro and extracts their structural information including
    /// route names for multi-route support.
    ///
    /// - Parameter content: The Swift source code content to parse
    /// - Returns: Array of (ViewInfo, [String]) tuples with views and their route names
    static func extractNavigableViews(from content: String) -> [(ViewInfo, [String])] {
        let lines = content.components(separatedBy: .newlines)
        var views: [(ViewInfo, [String])] = []
        var accumulatedRouteNames: [String] = []
        var foundRoutableWithoutArgs = false
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check for @Routable macro
            if trimmed == MacroConstants.routableMacro {
                // @Routable without arguments - should go to NavigationRoute
                foundRoutableWithoutArgs = true
                continue
            } else if let routeNames = extractRouteNames(from: trimmed) {
                // @Routable with arguments
                accumulatedRouteNames.append(contentsOf: routeNames)
                continue
            }
            
            // Check for view declaration following @Routable(s)
            if (foundRoutableWithoutArgs || !accumulatedRouteNames.isEmpty) && isViewDeclaration(trimmed) {
                if let viewName = extractViewName(from: trimmed) {
                    let parameters = extractParameters(for: viewName, in: lines, startingFrom: index)
                    let viewInfo = ViewInfo(name: viewName, parameters: parameters)
                    
                    // Determine route names
                    let finalRouteNames: [String]
                    if foundRoutableWithoutArgs && accumulatedRouteNames.isEmpty {
                        finalRouteNames = ["NavigationRoute"]
                    } else if !accumulatedRouteNames.isEmpty {
                        finalRouteNames = accumulatedRouteNames
                    } else {
                        finalRouteNames = ["NavigationRoute"]
                    }
                    
                    views.append((viewInfo, finalRouteNames))
                }
                
                // Reset state
                foundRoutableWithoutArgs = false
                accumulatedRouteNames.removeAll()
            }
            
            // Reset accumulated state if we encounter a non-empty line that's not @Routable or a view declaration
            if !trimmed.isEmpty && !trimmed.hasPrefix("@Routable") && !isViewDeclaration(trimmed) {
                foundRoutableWithoutArgs = false
                accumulatedRouteNames.removeAll()
            }
        }
        
        return views
    }
    
    /// Extracts route names from a @Routable macro annotation.
    ///
    /// Supports various formats:
    /// - @Routable -> ["NavigationRoute"] (default)
    /// - @Routable("CustomRoute") -> ["CustomRoute"]
    /// - @Routable("Route1", "Route2") -> ["Route1", "Route2"]
    ///
    /// - Parameter line: The trimmed source code line to parse
    /// - Returns: Array of route names if found, nil otherwise
    private static func extractRouteNames(from line: String) -> [String]? {
        // Simple @Routable without parameters
        if line == MacroConstants.routableMacro {
            return ["NavigationRoute"]
        }
        
        // @Routable with parameters: @Routable("Route1", "Route2", ...)
        let pattern = #"@Routable\s*\(\s*"([^"]+)""#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: line, range: NSRange(location: 0, length: line.utf16.count))
            if !matches.isEmpty {
                var routeNames: [String] = []
                for match in matches {
                    if let range = Range(match.range(at: 1), in: line) {
                        routeNames.append(String(line[range]))
                    }
                }
                
                // If we found at least one match, also look for additional comma-separated strings
                let allStringsPattern = #""([^"]+)""#
                if let allStringsRegex = try? NSRegularExpression(pattern: allStringsPattern) {
                    let allMatches = allStringsRegex.matches(in: line, range: NSRange(location: 0, length: line.utf16.count))
                    var allRouteNames: [String] = []
                    for match in allMatches {
                        if let range = Range(match.range(at: 1), in: line) {
                            allRouteNames.append(String(line[range]))
                        }
                    }
                    return allRouteNames.isEmpty ? routeNames : allRouteNames
                }
                return routeNames
            }
        }
        
        return nil
    }
    
    /// Checks if a line contains a SwiftUI view declaration.
    ///
    /// - Parameter line: The trimmed source code line to check
    /// - Returns: True if the line declares a struct or class that conforms to View
    private static func isViewDeclaration(_ line: String) -> Bool {
        return (line.contains(KeywordConstants.structKeyword) || line.contains(KeywordConstants.classKeyword)) 
            && line.contains(KeywordConstants.viewKeyword)
    }
}

// MARK: - Name Extraction
extension NavigationCodeGenerator {
    
    /// Extracts the view name from a Swift struct or class declaration.
    ///
    /// Uses regular expressions to parse struct or class declarations and
    /// extract the type name.
    ///
    /// - Parameter line: The source code line containing the declaration
    /// - Returns: The extracted view name, or nil if parsing fails
    static func extractViewName(from line: String) -> String? {
        let patterns = RegexPatterns.viewNamePatterns
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)),
               let range = Range(match.range(at: 1), in: line) {
                return String(line[range])
            }
        }
        
        return nil
    }
}

// MARK: - Parameter Extraction
extension NavigationCodeGenerator {
    
    /// Extracts parameter information for a view within a limited scope.
    ///
    /// Analyzes the view's source code to determine its initialization parameters,
    /// either from an explicit init method or from stored properties.
    ///
    /// - Parameters:
    ///   - viewName: The name of the view to extract parameters for
    ///   - lines: All source code lines
    ///   - index: The starting line index where the view was found
    /// - Returns: Array of Parameter objects representing the view's requirements
    static func extractParameters(for viewName: String, in lines: [String], startingFrom index: Int) -> [ViewInfo.Parameter] {
        var parameters: [ViewInfo.Parameter] = []
        var foundExplicitInit = false
        var braceDepth = 0
        
        // Scan within a reasonable scope around the view declaration
        let scanLimit = min(index + ParseConstants.maxLinesToScan, lines.count)
        
        for i in index..<scanLimit {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            
            // Track brace depth to avoid scanning outside the view
            if line.contains(BraceConstants.openBrace) { braceDepth += 1 }
            if line.contains(BraceConstants.closeBrace) {
                braceDepth -= 1
                if braceDepth <= 0 { break }
            }
            
            // Skip the body property
            if isBodyProperty(line) { continue }
            
            // Check for explicit initializer
            if line.contains(KeywordConstants.initKeyword) {
                foundExplicitInit = true
                parameters = parseInitParameters(from: line)
                break
            }
            
            // Extract stored properties if no explicit init found
            if !foundExplicitInit, let property = parseStoredProperty(from: line) {
                parameters.append(property)
            }
        }
        
        return parameters
    }
    
    /// Checks if a line contains the body property declaration.
    ///
    /// - Parameter line: The source code line to check
    /// - Returns: True if the line contains a body property with some View return type
    private static func isBodyProperty(_ line: String) -> Bool {
        return line.contains(PropertyConstants.bodyProperty) && line.contains(PropertyConstants.someView)
    }
}

// MARK: - Initializer Parsing
extension NavigationCodeGenerator {
    
    /// Parses parameters from an explicit init method declaration.
    ///
    /// Extracts parameter names, types, and default value information from
    /// an initializer method signature.
    ///
    /// - Parameter line: The source code line containing the init declaration
    /// - Returns: Array of Parameter objects parsed from the initializer
    static func parseInitParameters(from line: String) -> [ViewInfo.Parameter] {
        guard let paramListStart = line.firstIndex(of: ParameterConstants.openParen),
              let paramListEnd = line.lastIndex(of: ParameterConstants.closeParen) else { 
            return [] 
        }
        
        let paramsString = line[paramListStart...paramListEnd]
        let params = paramsString.dropFirst().dropLast().split(separator: ParameterConstants.separator)
        var result: [ViewInfo.Parameter] = []
        
        for param in params {
            let paramStr = param.trimmingCharacters(in: .whitespaces)
            
            // Skip environment objects
            if paramStr.contains(MacroConstants.environmentObject) { continue }
            
            if let parameter = parseParameterString(paramStr) {
                result.append(parameter)
            }
        }
        
        return result
    }
    
    /// Parses a single parameter string into a Parameter object.
    ///
    /// - Parameter paramStr: The trimmed parameter string to parse
    /// - Returns: A Parameter object if parsing succeeds, nil otherwise
    private static func parseParameterString(_ paramStr: String) -> ViewInfo.Parameter? {
        let pattern = RegexPatterns.parameterPattern
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: paramStr, range: NSRange(location: 0, length: paramStr.utf16.count)),
           let nameRange = Range(match.range(at: 1), in: paramStr),
           let typeRange = Range(match.range(at: 2), in: paramStr) {
            
            let name = String(paramStr[nameRange])
            let type = String(paramStr[typeRange]).trimmingCharacters(in: .whitespaces)
            let hasDefault = paramStr.contains(ParameterConstants.defaultValueIndicator)
            
            return ViewInfo.Parameter(name: name, type: type, hasDefaultValue: hasDefault)
        }
        
        return nil
    }
}

// MARK: - Property Parsing
extension NavigationCodeGenerator {
    
    /// Parses a stored property declaration into a Parameter object.
    ///
    /// Extracts property information from let/var declarations that could
    /// be used as view initialization parameters.
    ///
    /// - Parameter line: The source code line containing the property declaration
    /// - Returns: A Parameter object if the property is valid, nil otherwise
    static func parseStoredProperty(from line: String) -> ViewInfo.Parameter? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        
        // Skip environment objects
        if trimmed.contains(MacroConstants.environmentObject) { return nil }
        
        let pattern = RegexPatterns.storedPropertyPattern
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count)),
           let nameRange = Range(match.range(at: 1), in: trimmed),
           let typeRange = Range(match.range(at: 2), in: trimmed) {
            
            let name = String(trimmed[nameRange])
            let type = String(trimmed[typeRange]).trimmingCharacters(in: .whitespaces)
            let hasDefault = trimmed.contains(ParameterConstants.defaultValueIndicator)
            
            return ViewInfo.Parameter(name: name, type: type, hasDefaultValue: hasDefault)
        }
        
        return nil
    }
}

// MARK: - Code Generation
extension NavigationCodeGenerator {
    
    /// Generates a single file containing all navigation route enums.
    ///
    /// Creates a comprehensive Swift file with separate enums for each route group,
    /// including conformances to necessary protocols and implementations
    /// for view instantiation and string representation.
    ///
    /// - Parameter routeGroups: Dictionary mapping route names to arrays of views
    /// - Returns: Complete Swift source code containing all navigation route enums
    static func generateAllNavigationCode(from routeGroups: [String: [ViewInfo]]) -> String {
        var output = CodeTemplates.multiRouteFileHeader(date: Date())
        
        for (routeName, views) in routeGroups.sorted(by: { $0.key < $1.key }) {
            output += generateSingleRouteEnum(from: views, routeName: routeName)
            output += "\n"
        }
        
        return output
    }
    
    /// Generates a single route enum within a multi-route file.
    ///
    /// - Parameters:
    ///   - views: Array of ViewInfo objects to generate code for
    ///   - routeName: The name of the route enum to generate
    /// - Returns: Swift source code for a single route enum
    static func generateSingleRouteEnum(from views: [ViewInfo], routeName: String) -> String {
        var output = "public enum \(routeName): Hashable, Identifiable, CustomStringConvertible, View {\n"
        
        // Add enum cases
        for view in views {
            output += "    \(view.enumCaseDeclaration)\n"
        }
        
        output += CodeTemplates.idProperty
        output += CodeTemplates.descriptionSwitchHeader
        
        // Add description cases
        for view in views {
            output += "        \(view.switchCaseDescription)\n"
        }
        
        output += CodeTemplates.bodySwitchHeader
        
        // Add view instantiation cases
        for view in views {
            output += "        \(view.switchCase)\n"
        }
        
        output += CodeTemplates.enumFooter
        
        return output
    }
}

// MARK: - Constants

/// Constants for logging messages displayed during code generation
private enum LogConstants {
    static let usageMessage = "Usage: NavigationCodeGenerator <source-root> <output-path>"
    static let scanningMessage = "🔍 Scanning for @Routable views in: "
    static let foundMessage = "📱 Found %d routable views"
    static let generatedMessage = "✅ Generated navigation routes at: "
}

/// Constants for directory and file handling
private enum DirectoryConstants {
    static let excludedDirectories = ["build", ".build", "Generated", ".git"]
}

/// Constants for file operations
private enum FileConstants {
    static let swiftExtension = ".swift"
}

/// Constants for Swift macro names
private enum MacroConstants {
    static let routableMacro = "@Routable"
    static let environmentObject = "@EnvironmentObject"
}

/// Constants for Swift keywords
private enum KeywordConstants {
    static let structKeyword = "struct"
    static let classKeyword = "class"
    static let viewKeyword = "View"
    static let initKeyword = "init("
}

/// Constants for property parsing
private enum PropertyConstants {
    static let bodyProperty = "body:"
    static let someView = "some View"
}

/// Constants for parameter parsing
private enum ParameterConstants {
    static let openParen: Character = "("
    static let closeParen: Character = ")"
    static let separator: Character = ","
    static let defaultValueIndicator = "="
}

/// Constants for brace tracking
private enum BraceConstants {
    static let openBrace = "{"
    static let closeBrace = "}"
}

/// Constants for parsing limits
private enum ParseConstants {
    static let maxLinesToScan = 50
}

/// Regular expression patterns for code parsing
private enum RegexPatterns {
    static let viewNamePatterns = [
        #"struct\s+(\w+)\s*:"#,
        #"class\s+(\w+)\s*:"#
    ]
    static let parameterPattern = #"(?:\w+\s+)?(\w+)\s*:\s*([^=]+)(?:\s*=\s*[^,]+)?"#
    static let storedPropertyPattern = #"(?:let|var)\s+(\w+)\s*:\s*([^=\n{]+)"#
}

/// Code generation templates
private enum CodeTemplates {
    static func fileHeader(date: Date, routeName: String) -> String {
        return """
// Generated by Navigation package - do not edit manually
// Generated at: \(date)
import SwiftUI
import Navigation

public enum \(routeName): Hashable, Identifiable, CustomStringConvertible, View {

"""
    }
    
    static func multiRouteFileHeader(date: Date) -> String {
        return """
// Generated by Navigation package - do not edit manually
// Generated at: \(date)
import SwiftUI
import Navigation

"""
    }
    
    static let idProperty = """

    public var id: String {
        description
    }

"""
    
    static let descriptionSwitchHeader = """

    public var description: String {
        switch self {

"""
    
    static let bodySwitchHeader = """
        }
    }

    @ViewBuilder
    public var body: some View {
        switch self {

"""
    
    static let fileFooter = """
        }
    }
}

"""
    
    static let enumFooter = """
        }
    }
}

"""
}
