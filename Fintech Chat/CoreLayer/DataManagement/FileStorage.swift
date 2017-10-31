//
//  FileStorage.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 31/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol Storage {
    func saveData(_ data: Data) -> Error?
    func loadData() -> (Data?, Error?)
}

enum StorageError: Error {
    case noDocumentDirectory
    case fileDoesNotExist
    case failedToWrite
    case failedToRead
}

class FileStorage: Storage {
    
    private let userDataFileName = "UserInfo.txt"
    
    func saveData(_ data: Data) -> Error? {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard dir != nil else { return StorageError.noDocumentDirectory }
        
        let fileURL = dir!.appendingPathComponent(userDataFileName)
        do {
            try data.write(to: fileURL)
            return nil
        } catch {
            return StorageError.noDocumentDirectory
        }
    }
    
    func loadData() -> (Data?, Error?) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard dir != nil else { return (nil, StorageError.noDocumentDirectory) }
        
        let fileURL = dir!.appendingPathComponent(userDataFileName)
        if FileManager.default.fileExists(atPath: fileURL.path)  {
            do {
                let data = try Data(contentsOf: fileURL)
                return (data, nil)
            } catch {
                return (nil, StorageError.failedToRead)
            }
        } else {
            return (nil, StorageError.fileDoesNotExist)
        }
    }
    
    
}
