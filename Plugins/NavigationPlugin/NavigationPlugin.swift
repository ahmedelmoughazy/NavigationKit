
//
//  NavigationPlugin.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 17.08.25.
//

import PackagePlugin
import Foundation

/// A Swift Package Manager build tool plugin that generates navigation routes from source files.
///
/// This plugin scans Swift source files for views marked with the `@Routable` macro and
/// automatically generates a `NavigationRoute` enum containing all the routable views.
/// The generated file includes view instantiation logic and routing capabilities.
///
/// The plugin supports both Swift Package Manager projects and Xcode projects through
/// separate protocol conformances.
@main
struct NavigationPlugin: BuildToolPlugin {
    
    /// Creates build commands for Swift Package Manager targets.
    ///
    /// This method is called by the Swift Package Manager during the build process.
    /// It sets up the code generation command that will scan the target's source files
    /// and generate the navigation routes.
    ///
    /// - Parameters:
    ///   - context: The plugin context providing access to tools and directories
    ///   - target: The target being built
    /// - Returns: An array of build commands to execute
    /// - Throws: `PluginError` if the target doesn't have a source module, tools are missing, or directory creation fails
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceModule = target.sourceModule else {
            throw PluginError.missingSourceModule
        }
        
        let navigationGenerator: PackagePlugin.PluginContext.Tool
        do {
            navigationGenerator = try context.tool(named: Constants.generatorToolName)
        } catch {
            throw PluginError.toolNotFound(Constants.generatorToolName)
        }
        
        let outputDirectory = context.pluginWorkDirectoryURL
            .appending(path: target.name)
            .appending(path: Constants.generatedFolder)
        
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            throw PluginError.directoryCreationFailed(outputDirectory.path())
        }
        
        let outputFile = outputDirectory.appending(path: Constants.generatedFile)
        
        Diagnostics.remark("[NavigationPlugin] Will generate \(Constants.generatedFile) at: \(outputFile.path())")
        
        return [
            .buildCommand(
                displayName: "\(Constants.pluginDisplayName) For \(target.name)",
                executable: navigationGenerator.url,
                arguments: [
                    sourceModule.directoryURL.path(),
                    outputFile.path()
                ],
                inputFiles: [],
                outputFiles: [outputFile]
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

/// Extension to support Xcode projects.
///
/// This extension allows the NavigationPlugin to work with Xcode projects that include
/// Swift packages. The plugin will run during Xcode builds and generate navigation routes
/// for any targets that depend on this package.
extension NavigationPlugin: XcodeBuildToolPlugin {
    
    /// Creates build commands for Xcode project targets.
    ///
    /// This method is called by Xcode during the build process when building projects
    /// that include this Swift package as a dependency.
    ///
    /// - Parameters:
    ///   - context: The Xcode plugin context providing access to tools and project information
    ///   - target: The Xcode target being built
    /// - Returns: An array of build commands to execute
    /// - Throws: `PluginError` if tools are missing or directory creation fails
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let navigationGenerator: PackagePlugin.PluginContext.Tool
        do {
            navigationGenerator = try context.tool(named: Constants.generatorToolName)
        } catch {
            throw PluginError.toolNotFound(Constants.generatorToolName)
        }
        
        let outputDirectory = context.pluginWorkDirectoryURL
            .appending(path: target.displayName)
            .appending(path: Constants.generatedFolder)
        
        do {
            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            throw PluginError.directoryCreationFailed(outputDirectory.path())
        }
        
        let outputFile = outputDirectory.appending(path: Constants.generatedFile)
        
        Diagnostics.remark("[NavigationPlugin] Will generate \(Constants.generatedFile) at: \(outputFile.path())")
        
        return [
            .buildCommand(
                displayName: "\(Constants.pluginDisplayName) For \(target.displayName)",
                executable: navigationGenerator.url,
                arguments: [
                    context.xcodeProject.directoryURL.path(),
                    outputFile.path()
                ],
                inputFiles: [],
                outputFiles: [outputFile]
            )
        ]
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
    static let generatorToolName = "NavigationCodeGenerator"
    /// The name of the folder where generated files are stored.
    static let generatedFolder = "Generated"
    /// The name of the generated Swift file containing navigation routes.
    static let generatedFile = "NavigationRoutes.swift"
    /// File extension for Swift source files.
    static let swiftFileExtension = ".swift"
    /// The macro annotation that marks views as routable.
    static let routableMacro = "@Routable"
    /// The display name shown in build logs for this plugin.
    static let pluginDisplayName = "Generate Navigation Routes"
}
