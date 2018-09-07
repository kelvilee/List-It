//
//  List-It.swift
//  List-It
//
//  Created by Kelvin Lee on 2018-09-06.
//  Copyright © 2018 Kelvin Lee. All rights reserved.
//

import Foundation

class ToDoItem: NSObject, NSCoding
{
    required init?(coder aDecoder: NSCoder)
    {
        // try to unserialize the "title" variable
        if let title = aDecoder.decodeObject(forKey: "title") as? String
        {
            self.title = title
        }
        else
        {
            // no objects encoded with title so error
            return nil
        }
        
        // Check if the key "done exists, since decodeBool() always succeeds
        if aDecoder.containsValue(forKey: "done")
        {
            self.done = aDecoder.decodeBool(forKey: "done")
        }
        else
        {
            // same problem as above
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder)
    {
        // Store the object into the coder object
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.done, forKey: "done")
    }
    
    var title: String
    var done: Bool
    
    public init(title: String)
    {
        self.title = title
        self.done = false
    }
}

extension ToDoItem
{
    public class func getMockData() -> [ToDoItem]
    {
        return [
            ToDoItem(title: "Milk"),
            ToDoItem(title: "Chocolate"),
            ToDoItem(title: "Light Bulb")
        ]
    }
}

// Creates an extension of the Colleciton type (aka an Array),
// but only if it is an array of ToDoItem objects
extension Collection where Iterator.Element == ToDoItem
{
    // Builds the persistence URL. This is a location inside the "Application Support" directory for the App.
    private static func persistencePath() -> URL?
    {
        let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return url?.appendingPathComponent("todoitems.bin")
    }
    
    // Write the array to persistence
    func writeToPersistence() throws
    {
        if let url = Self.persistencePath(), let array = self as? NSArray
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to: url)
        }
        else
        {
            throw NSError(domain: "com.example.List-It", code: 10, userInfo: nil)
        }
    }
    
    // Read the array from persistence
    static func readFromPersistence() throws -> [ToDoItem]
    {
        if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ToDoItem]
            {
                return array
            }
            else
            {
                throw NSError(domain: "com.example.List-It", code: 11, userInfo: nil)
            }
        }
        else
        {
            throw NSError(domain: "com.example.List-It", code: 12, userInfo: nil)
        }
    }
}
