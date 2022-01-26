//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Johnny Boshechka on 1/25/22.
//
import UIKit

class TaskListViewController: UITableViewController {
    private let storageManager = StorageManager.shared
    
    private let cellID = "task"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        storageManager.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storageManager.fetchData()
        tableView.reloadData()
    }
 
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    private func showAlertTask(with title: String, and message: String) {
       
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alertController.textFields?.first?.text else { return }
            self.storageManager.save(task, tableView: self.tableView)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            self.dismiss(animated: true)
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alertController, animated: true)

    }
    
        private func showEditAlert(with title: String, and message: String, indexPath: IndexPath) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                    self.storageManager.editTask(task, indexPath)
                    self.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                alert.addTextField { textField in
                    let task = self.storageManager.taskList[indexPath.row]
                    textField.text = task.name
                }
                present(alert, animated: true)
            }
    
    @objc private func addNewTask() {
        showAlertTask(with: "New task", and: "What do you want to do?")
    }
    
    private func edit(_ task: Task,_ newName: String, _ indexPath: [IndexPath]) {
           task.name = newName
           storageManager.saveContext()
           tableView.reloadRows(at: indexPath, with: .automatic)

       }

}

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storageManager.taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = storageManager.taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, complete in
            self.showEditAlert(with: "Edit", and: "Editing task", indexPath: indexPath)
            
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, complete in
            let task = self.storageManager.taskList[indexPath.row]
            self.storageManager.taskList.remove(at: indexPath.row)
            self.storageManager.persistentContainer.viewContext.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
       
        editAction.backgroundColor = .systemGreen
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
        


// Для сложных взаимосвязей в модели
//        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
//        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
//}
}
