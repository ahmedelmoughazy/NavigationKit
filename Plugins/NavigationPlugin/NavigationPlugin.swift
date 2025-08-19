
//
//  plugin.swift
//  Navigation
//
//  Created by Ahmed Elmoughazy on 17.08.25.
//

import PackagePlugin
import Foundation

@main
struct NavigationPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let navigationGenerator = try context.tool(named: Constants.generatorToolName)
        
        guard let sourceModule = target.sourceModule else {
            throw PluginError.missingSourceModule
        }
        
        let outputDirectory = context.pluginWorkDirectoryURL.appending(path: target.name).appending(path: Constants.generatedFolder)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        let outputFile = outputDirectory.appending(path: Constants.generatedFile)
        
        Diagnostics.remark("[NavigationPlugin] Will generate NavigationRoutes.swift at: \(outputFile.path())")
        
        return [
            .buildCommand(
                displayName: "Generate Navigation Routes For \(target.name)",
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

extension NavigationPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodeProjectPlugin.XcodePluginContext, target: XcodeProjectPlugin.XcodeTarget) throws -> [PackagePlugin.Command] {
        let navigationGenerator = try context.tool(named: Constants.generatorToolName)
        let outputDirectory = context.pluginWorkDirectoryURL.appending(path: target.displayName).appending(path: Constants.generatedFolder)
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        let outputFile = outputDirectory.appending(path: Constants.generatedFile)
        
        Diagnostics.remark("[NavigationPlugin] Will generate NavigationRoutes.swift at: \(outputFile.path())")
        
        return [
            .buildCommand(
                displayName: "Generate Navigation Routes For \(target.displayName)",
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

// Enum to define possible plugin errors
private enum PluginError: Error {
    case missingSourceModule // Error for missing source module
}

private enum Constants {
    static let generatorToolName = "NavigationCodeGenerator"
    static let generatedFolder = "Generated"
    static let generatedFile = "NavigationRoutes.swift"
}
