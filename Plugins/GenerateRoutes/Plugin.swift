//
//  Plugin.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 17.08.25
//  Copyright © 2025 Ahmed Elmoghazy. All rights reserved.
//

import PackagePlugin
import Foundation

/// A Swift Package Manager command plugin that generates navigation routes from source files.
///
/// This plugin scans Swift source files for views marked with the `@Routable` macro and
/// automatically generates a `NavigationRoute` enum containing all the routable views.
/// The generated file includes view instantiation logic and routing capabilities.
///
/// The plugin supports both Swift Package Manager projects and Xcode projects through
/// separate protocol conformances.
@main
struct GenerateRoutesPlugin: CommandPlugin {
    
    /// Performs the command for Swift Package Manager targets.
    ///
    /// This method is called by the Swift Package Manager when the command is executed.
    /// It sets up the code generation command that will scan the target's source files
    /// and generate the navigation routes.
    ///
    /// - Parameters:
    ///   - context: The plugin context providing access to tools and directories
    ///   - arguments: Command line arguments passed to the plugin
    /// - Throws: `PluginError` if tools are missing or directory creation fails
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let navigationGenerator: PackagePlugin.PluginContext.Tool
        do {
            navigationGenerator = try context.tool(named: Constants.generatorToolName)
        } catch {
            throw PluginError.toolNotFound(Constants.generatorToolName)
        }
        
        // Parse route name from arguments, fallback to default
        let routeName = parseRouteName(from: arguments)
        
        for target in context.package.targets {
            guard let sourceModule = target.sourceModule else {
                continue
            }
            
            let outputDirectory = context.pluginWorkDirectoryURL
                .appending(path: target.name)
                .appending(path: Constants.generatedFolder)
            
            do {
                try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
            } catch {
                throw PluginError.directoryCreationFailed(outputDirectory.path())
            }
            
            let outputFile = outputDirectory.appending(path: "\(routeName).swift")
            
            Diagnostics.remark("[GenerateRoutes] Will generate \(routeName).swift at: \(outputFile.path())")
            
            let process = Process()
            process.executableURL = navigationGenerator.url
            process.arguments = [
                sourceModule.directoryURL.path(),
                outputFile.path()
            ]
            
            try process.run()
            process.waitUntilExit()
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

/// Extension to support Xcode projects.
///
/// This extension allows the GenerateRoutesPlugin to work with Xcode projects that include
/// Swift packages. The plugin will run during Xcode builds and generate navigation routes
/// for any targets that depend on this package.
extension GenerateRoutesPlugin: XcodeCommandPlugin {
    
    /// Performs the command for Xcode project targets.
    ///
    /// This method is called by Xcode when the command is executed from projects
    /// that include this Swift package as a dependency.
    ///
    /// - Parameters:
    ///   - context: The Xcode plugin context providing access to tools and project information
    ///   - arguments: Command line arguments passed to the plugin
    /// - Throws: `PluginError` if tools are missing or directory creation fails
    func performCommand(context: XcodeProjectPlugin.XcodePluginContext, arguments: [String]) throws {
        let navigationGenerator: PluginContext.Tool
        do {
            navigationGenerator = try context.tool(named: Constants.generatorToolName)
        } catch {
            throw PluginError.toolNotFound(Constants.generatorToolName)
        }
        
        // Parse route name from arguments, fallback to default
        let routeName = parseRouteName(from: arguments)
        
        for target in context.xcodeProject.targets {
            let outputDirectory = context.xcodeProject.directoryURL
                .appending(path: target.displayName)
                .appending(path: Constants.generatedFolder)
            
            do {
                try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
            } catch {
                throw PluginError.directoryCreationFailed(outputDirectory.path())
            }
            
            let outputFile = outputDirectory.appending(path: "\(routeName).swift")
            
            Diagnostics.remark("[GenerateRoutes] Will generate \(routeName).swift at: \(outputFile.path())")
            
            let process = Process()
            process.executableURL = navigationGenerator.url
            process.arguments = [
                context.xcodeProject.directoryURL.path(),
                outputFile.path()
            ]
            
            try process.run()
            process.waitUntilExit()
        }
    }
}
#endif

/// Errors that can occur during plugin execution.
///
/// These errors provide detailed information about what went wrong during
/// the plugin's execution, making debugging easier for developers.
// Enum to define possible plugin errors
private enum PluginError: Error, LocalizedError {
    /// The target does not have a source module, which is required for code generation.
    case missingSourceModule
    /// The specified tool could not be found in the plugin context.
    case toolNotFound(String)
    /// Failed to create the required directory for generated files.
    case directoryCreationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingSourceModule:
            return "Target does not have a source module"
        case .toolNotFound(let toolName):
            return "Could not find tool: \(toolName)"
        case .directoryCreationFailed(let path):
            return "Failed to create directory at: \(path)"
        }
    }
}

/// Constants used throughout the plugin.
///
/// These constants centralize all string literals and configuration values
/// used by the plugin, making maintenance easier and reducing the risk of typos.
private enum Constants {
    /// The name of the code generator tool executable.
    static let generatorToolName = "RouteGenerator"
    /// The name of the folder where generated files are stored.
    static let generatedFolder = "Generated"
    /// The default name for the generated route type when no custom name is provided.
    static let defaultRouteName = "Route"
}

/// Helper function to parse route name from command line arguments.
///
/// Looks for arguments in the format "--name=CustomName" or "--name CustomName"
/// and returns the specified name, or falls back to the default route name.
///
/// - Parameter arguments: Command line arguments passed to the plugin
/// - Returns: The route name to use for the generated file
private func parseRouteName(from arguments: [String]) -> String {
    for i in 0..<arguments.count {
        let arg = arguments[i]
        
        // Handle --name=CustomName format
        if arg.hasPrefix("--name=") {
            let name = String(arg.dropFirst("--name=".count))
            return name.isEmpty ? Constants.defaultRouteName : name
        }
        
        // Handle --name CustomName format
        if arg == "--name" && i + 1 < arguments.count {
            let name = arguments[i + 1]
            return name.isEmpty ? Constants.defaultRouteName : name
        }
    }
    
    return Constants.defaultRouteName
}
