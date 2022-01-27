//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Johnny Boshechka on 1/26/22.
//

import Foundation
import CoreData
import UIKit

// MARK: - Core Data stack
class StorageManager {
    static var shared = StorageManager()
    var taskList: [Task] = []
    private init() {}
    
   
    var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func fetchData() {
        let fetchRequest = Task.fetchRequest()
        do {
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
    
    func save(_ taskName: String, tableView: UITableView) {
        let task = Task(context: persistentContainer.viewContext)
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        saveContext()
    }
    
    func editTask(_ taskName: String, _ indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        task.name = taskName
        
        saveContext()
    }
  
    func deleteTask(_ indexPath: Int) {
        let task = taskList[indexPath]
        persistentContainer.viewContext.delete(task)
        taskList.remove(at: indexPath)
        
    }
}
