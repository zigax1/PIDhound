import Foundation

public struct ThermalStateSampler: Sendable {
    public init() {}

    public func sample() -> ThermalState {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:  return .nominal
        case .fair:     return .moderate
        case .serious:  return .heavy
        case .critical: return .critical
        @unknown default: return .nominal
        }
    }
}
