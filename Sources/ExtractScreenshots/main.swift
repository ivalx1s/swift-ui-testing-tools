//
//  main.swift
//  ExtractScreenshots
//
//  CLI tool to extract screenshots from xcresult and organize into folders.
//
//  Usage: extract-screenshots <path-to-xcresult> [output-dir]
//

import Foundation

// MARK: - Models

struct TestAttachments: Codable {
    let testIdentifier: String
    let attachments: [AttachmentInfo]
}

struct AttachmentInfo: Codable {
    let exportedFileName: String
    let suggestedHumanReadableName: String
}

// MARK: - Entry Point

func printUsage() {
    print("""
    Usage: extract-screenshots <path-to-xcresult> [output-dir]

    Extracts screenshots from xcresult and organizes into folders.

    Screenshot naming format:
      Run_{session}__Test_{name}__Step_{NN}__{timestamp}__{description}

    Output structure:
      output-dir/
        Run_2026-01-15_17-49-00/
          Test_testBothButtons/
            Step_01__17-49-03-348__app_launched.png
    """)
}

guard CommandLine.arguments.count >= 2 else {
    printUsage()
    exit(1)
}

let xcresultPath = CommandLine.arguments[1]
let outputDir = CommandLine.arguments.count >= 3 ? CommandLine.arguments[2] : "./screenshots"

guard FileManager.default.fileExists(atPath: xcresultPath) else {
    print("Error: xcresult not found: \(xcresultPath)")
    exit(1)
}

print("Extracting from: \(xcresultPath)")
print("Output dir: \(outputDir)")

// Create temp directory for raw export
let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: tempDir) }

// Export all attachments
print("Exporting attachments...")
let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
task.arguments = ["xcresulttool", "export", "attachments", "--path", xcresultPath, "--output-path", tempDir.path]
task.standardOutput = FileHandle.nullDevice
task.standardError = FileHandle.nullDevice

try? task.run()
task.waitUntilExit()

guard task.terminationStatus == 0 else {
    print("Failed to export attachments")
    exit(1)
}

// Read manifest (array of test attachments)
let manifestPath = tempDir.appendingPathComponent("manifest.json")
guard let manifestData = try? Data(contentsOf: manifestPath),
      let testAttachments = try? JSONDecoder().decode([TestAttachments].self, from: manifestData) else {
    print("Failed to read manifest")
    exit(1)
}

// Collect all attachments with Run_ prefix
var screenshots: [(att: AttachmentInfo, testId: String)] = []
for test in testAttachments {
    for att in test.attachments where att.suggestedHumanReadableName.hasPrefix("Run_") {
        screenshots.append((att, test.testIdentifier))
    }
}

print("Found \(screenshots.count) screenshots")

guard !screenshots.isEmpty else {
    print("No screenshots with 'Run_' prefix found")
    exit(0)
}

// Organize into folders
var extracted = 0
for (att, _) in screenshots {
    // Parse: Run_{session}__Test_{name}__Step_{NN}__{timestamp}__{description}_0_UUID.png
    // Remove trailing _0_UUID.png added by XCTest
    var cleanName = att.suggestedHumanReadableName
    if cleanName.hasSuffix(".png") {
        cleanName = String(cleanName.dropLast(4))
    }
    if let range = cleanName.range(of: "_0_", options: .backwards) {
        cleanName = String(cleanName[..<range.lowerBound])
    }

    let parts = cleanName.components(separatedBy: "__")

    guard parts.count >= 5 else {
        print("  Skipping (unknown format): \(att.suggestedHumanReadableName)")
        continue
    }

    let runPart = parts[0]       // Run_2026-01-15_17-49-00
    let testPart = parts[1]      // Test_testBothButtons
    let stepPart = parts[2]      // Step_01
    let timestampPart = parts[3] // 17-49-03-348
    let description = parts[4...].joined(separator: "__") // app_launched

    // Create folder structure
    let folder = URL(fileURLWithPath: outputDir)
        .appendingPathComponent(runPart)
        .appendingPathComponent(testPart)
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

    // Source file (exported by xcresulttool)
    let sourceFile = tempDir.appendingPathComponent(att.exportedFileName)

    // Destination: Step_01__17-49-03-348__app_launched.png
    let destFilename = "\(stepPart)__\(timestampPart)__\(description).png"
    let destFile = folder.appendingPathComponent(destFilename)

    do {
        try FileManager.default.copyItem(at: sourceFile, to: destFile)
        print("  \(testPart)/\(destFilename)")
        extracted += 1
    } catch {
        print("  Failed: \(att.suggestedHumanReadableName) - \(error.localizedDescription)")
    }
}

print("")
print("Done! Extracted \(extracted) screenshots to: \(outputDir)")

// Show folder structure
if extracted > 0 {
    print("")
    print("Folder structure:")

    let fm = FileManager.default
    if let enumerator = fm.enumerator(atPath: outputDir) {
        var count = 0
        while let path = enumerator.nextObject() as? String, count < 20 {
            if path.hasSuffix(".png") {
                print("  \(outputDir)/\(path)")
                count += 1
            }
        }
    }
}
