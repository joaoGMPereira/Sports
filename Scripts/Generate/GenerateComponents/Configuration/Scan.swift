import Foundation

struct Scan {
    // Recursively scan a directory for Swift files
    func scanDirectory(at path: String, completion: (String) -> Void) {
        let fileManager = FileManager.default
        
        guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
            print("Could not access directory: \(path)")
            return
        }
        
        for item in contents {
            let itemPath = (path as NSString).appendingPathComponent(item)
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) else {
                continue
            }
            
            if isDirectory.boolValue {
                // Recursively scan subdirectories
                scanDirectory(at: itemPath, completion: completion)
            } else if itemPath.hasSuffix(".swift") {
                // Process Swift files
                completion(itemPath)
            }
        }
    }
}
