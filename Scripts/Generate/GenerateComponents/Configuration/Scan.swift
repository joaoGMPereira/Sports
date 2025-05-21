import Foundation

struct Scan {
    // Recursively scan a directory for Swift files
    func scanDirectory(at path: String, type: String? = nil) -> [String] {
        let fileManager = FileManager.default
        var pathsFound: [String] = []
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            print("Could not access directory: \(path)")
            return pathsFound
        }
        
        for item in contents {
            let itemPath = (path as NSString).appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) else {
                continue
            }
            
            if isDirectory.boolValue {
                // Recursively scan subdirectories
                pathsFound.append(contentsOf: scanDirectory(at: itemPath, type: type))
            } else if itemPath.hasSuffix(".swift") {
                // Check if we're looking for a specific type in the file
                if let typeName = type {
                    if let fileContent = try? String(contentsOfFile: itemPath), fileContent.contains(typeName) {
                        pathsFound.append(itemPath)
                    }
                } else {
                    // Add all Swift files if no type filter
                    pathsFound.append(itemPath)
                }
            }
        }
        
        return pathsFound
    }
}
