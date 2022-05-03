import Vapor
@_exported import MicrosoftGraphCore

extension Application {
    
    public var microsoftGraph: MicrosoftGraph {
        .init(application: self)
    }
    
    private struct MsCredentialsKey: StorageKey {
        typealias Value = MsGraphCredentialsConfiguration
    }
    
    public struct MicrosoftGraph {
        public let application: Application
        
        public var credentials: MsGraphCredentialsConfiguration {
            get {
                if let credentials = application.storage[MsCredentialsKey.self] {
                    return credentials
                } else {
                    fatalError("Cloud credentials configuration has not been set. Use app.microsoftGraph.credentials = ...")
                }
            }
            nonmutating set {
                if application.storage[MsCredentialsKey.self] == nil {
                   application.storage[MsCredentialsKey.self] = newValue
                } else {
                    fatalError("Overriding credentials configuration after being set is not allowed.")
                }
            }
        }
    }
}

