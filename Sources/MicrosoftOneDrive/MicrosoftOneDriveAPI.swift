//
//  File.swift
//  
//
//  Created by vine on 2021/1/8.
//

import Vapor
@_exported import OneDrive
@_exported import MicrosoftGraph

extension Application.MicrosoftGraph {
    
    private struct OneDriveAPIKey: StorageKey {
        typealias Value = MicrosoftOneDriveAPI
    }
    public var onedrive: MicrosoftOneDriveAPI {
        get {
            if let existing = self.application.storage[OneDriveAPIKey.self] {
                return existing
            } else {
                return .init(application: self.application, eventLoop: self.application.eventLoopGroup.next())
            }
        }
        
        nonmutating set {
            self.application.storage[OneDriveAPIKey.self] = newValue
        }
    }
    
    public struct MicrosoftOneDriveAPI {
        public let application: Application
        public let eventLoop: EventLoop
        
        public var client: OneDriveClient {
            do {
                let new = try OneDriveClient(credentials: self.application.microsoftGraph.credentials, driveConfig: self.configuration, httpClient: self.http, eventLoop: self.eventLoop)
            return new
            } catch {
                fatalError("\(error.localizedDescription)")
            }
        }
        
        private struct MsOneDriveConfigurationKey: StorageKey {
            typealias Value = MsGraphOneDriveConfig
        }
        /// The configuration for using `MsGraphOneDriveConfig` APIs.
        public var configuration: MsGraphOneDriveConfig {
            get {
                if let configuration = application.storage[MsOneDriveConfigurationKey.self] {
                   return configuration
                } else {
                    fatalError("configuration has not been set. Use app.microsoftGraph.onedrive.configuration = ...")
                }
            }
            set {
                if application.storage[MsOneDriveConfigurationKey.self] == nil {
                    application.storage[MsOneDriveConfigurationKey.self] = newValue
                } else {
                    fatalError("Attempting to override credentials configuration after being set is not allowed.")
                }
            }
        }
        
        /// Custom `HTTPClient` that ignores unclean SSL shutdown.
        private struct MicrosoftOneDriveHTTPClientKey: StorageKey, LockKey {
            typealias Value = HTTPClient
        }
        public var http: HTTPClient {
            if let existing = application.storage[MicrosoftOneDriveHTTPClientKey.self] {
                return existing
            } else {
                let lock = application.locks.lock(for: MicrosoftOneDriveHTTPClientKey.self)
                lock.lock()
                defer { lock.unlock() }
                if let existing = application.storage[MicrosoftOneDriveHTTPClientKey.self] {
                    return existing
                }
                let new = HTTPClient(
                    eventLoopGroupProvider: .shared(application.eventLoopGroup),
                    configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
                )
                application.storage.set(MicrosoftOneDriveHTTPClientKey.self, to: new) {
                    try $0.syncShutdown()
                }
                return new
            }
        }
    }
    
}

extension Request {
    private struct MicrosoftGraphOneDriveKey: StorageKey {
        typealias Value = OneDriveClient
    }

    public var driveClient: OneDriveClient {
        if let existing = application.storage[MicrosoftGraphOneDriveKey.self] {
            return existing.hopped(to: self.eventLoop)
        } else {
            let client = Application.MicrosoftGraph.MicrosoftOneDriveAPI(application: self.application, eventLoop: self.eventLoop).client
            application.storage[MicrosoftGraphOneDriveKey.self] = client
            return client
        }
    }
}
