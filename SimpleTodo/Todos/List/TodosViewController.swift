//
//  ViewController.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import UIKit
import Moya
import SCLAlertView

enum ModificationType {
    case insert
    case edit
    case delete
}

class TodosViewController: UIViewController {
    
    @IBOutlet weak internal var tableView: UITableView!
    var viewModel: TodosViewModelProtocol! = TodosViewModel()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        self.loadData()
    }
    
    func loadData() {
        viewModel.download { (todos, error) in
            self.refreshControl.endRefreshing()
            if let error = error {
                print("Error: \(error)")
                SCLAlertView().showError("Cannot load data", subTitle: error.localizedDescription)
            }
            else { self.tableView.reloadData() }
        }
    }
    
    private func buildEditor(for todo: Todo) -> TodoEditorViewController {
        let editor = Storyboard.main.viewController(of: TodoEditorViewController.self)
        let type = todo.isNew ? ModificationType.insert : ModificationType.edit
        editor.configure(withDelegate: self, todo: todo, modificationType: type)
        return editor
    }
    
    func addNew() {
        let newTodo = Todo(withTitle: "")
        edit(newTodo)
    }
    
    func edit(_ todo: Todo) {
        let editor = buildEditor(for: todo).wrapIntoNavigation()
        present(editor, animated: true, completion: nil)
    }
    
    func delete(_ todo: Todo) {
        let alertView = SCLAlertView()
        alertView.addButton("Delete") {
            self.viewModel.delete(todo) { [weak self] todo, error in
                if let error = error {
                    print(error.localizedDescription)
                    SCLAlertView().showError("Cannot remove data", subTitle: error.localizedDescription)
                    return
                }
                self?.syncCollectionItem(todo, modificationType: .delete)
            }
        }
        alertView.showWarning("Confirm", subTitle: "Are you sure you want to delete todo?", closeButtonTitle: "Cancel")
    }
    
    func syncCollectionItem(_ item: Todo, modificationType mode: ModificationType) {
        if let ip = viewModel.syncCollection(with: item, modificationType: mode) {
            switch mode {
            case .insert:
                self.tableView.insertRows(at: [ip], with: .automatic)
            case .edit:
                self.tableView.reloadRows(at: [ip], with: .automatic)
            case .delete:
                self.tableView.deleteRows(at: [ip], with: .automatic)
            }
        }
    }
}

// MARK - Actions
extension TodosViewController {
    @IBAction func loadData(_ sender: Any) {
        self.loadData()
    }
    
    @IBAction func onAddNew(_ sender: Any) {
        self.addNew()
    }
    
}

// MARK - Data Source
extension TodosViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfGroups()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inGroup: 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* POI: Force unwrap can be useful!
         We would not want to workaround it
         */
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath) as! TodoTableViewCell
        let todo = viewModel.item(byIndexPath: indexPath)! /*as? Todo*/
        cell.delegate = self
        cell.configure(id: todo.id,
                       title: todo.title,
                       category: todo.category,
                       priority: todo.priority,
                       completed: todo.completed)
        
        return cell
    }
}

extension TodosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = viewModel.item(byIndexPath: indexPath)!
        edit(todo)
    }
}

extension TodosViewController: TodoTableViewCellDelegate {
    func todoCell(_ cell: TodoTableViewCell, didChangeCompletion completed: Bool) {
        guard let todo = viewModel.item(byId: cell.todoId) else { return }
        todo.completed = completed
        viewModel.update(todo) { [weak self] todo, error in
            if let error = error {
                print(error.localizedDescription)
                SCLAlertView().showError("Cannot save data", subTitle: error.localizedDescription)
                return
            } else {
                if let ip = self?.tableView.indexPath(for: cell) {
                    self?.tableView.reloadRows(at: [ip], with: UITableViewRowAnimation.automatic)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            guard let todo = self.viewModel.item(byIndexPath: indexPath) else { return }
            self.delete(todo)
        }
        return [delete]
    }

}

extension TodosViewController: TodoEditorViewControllerDelegate {
    func editor(_ editor: TodoEditorViewController, didChange todo: Todo?) {
        guard let todo = todo else { return }
        let mode = editor.modificationType!
        syncCollectionItem(todo, modificationType: mode)
    }
}

