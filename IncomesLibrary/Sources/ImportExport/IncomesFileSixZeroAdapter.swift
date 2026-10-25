import Foundation

enum IncomesFileSixZeroAdapter {
    static func normalizedData(from data: Data) throws -> Data? {
        guard var object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              object["format"] as? String == "com.muhiro12.Incomes.data",
              object["schemaVersion"] as? String == "3.0.0",
              object["fileType"] == nil,
              object["formatVersion"] == nil else {
            return nil
        }
        object.removeValue(forKey: "format")
        object["fileType"] = "com.muhiro12.Incomes.data"
        // The 6.0 payload matches this historical pair, independently of future writers.
        object["formatVersion"] = 1
        object["schemaVersion"] = "2.0.0"
        return try JSONSerialization.data(withJSONObject: object, options: .withoutEscapingSlashes)
    }
}
