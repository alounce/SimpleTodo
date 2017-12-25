//
//  TodoEditorViewController.swift
//  SimpleTodo
//
//  Created by Alexander Karpenko on 1/4/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import UIKit

protocol TodoEditorViewControllerDelegate: NSObjectProtocol {
    func editor(_ editor: TodoEditorViewController, didChange todo: Todo?)
}

class TodoEditorViewController: UIViewController {
    
    private(set) var todo: Todo!
    private(set)var modificationType: ModificationType!
    weak var delegate: TodoEditorViewControllerDelegate?
    
    /* BREAKING ATTEMPT #6
     Imagine that during refactoring we lose wiring to some outlets.
     Tests must show that
     */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var detailsText: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        syncData()
        self.titleText.becomeFirstResponder()
    }
    
    func configure(withDelegate delegate:TodoEditorViewControllerDelegate,
                   todo: Todo,
                   modificationType: ModificationType = .edit) {
        self.delegate = delegate
        self.todo = todo
        self.modificationType = modificationType
    }
    
    func syncData(forward: Bool = true) {
        if forward {
            titleText?.text = todo.title
            /* BREAKING ATTEMPT #5
             imagine we forgot to sync detail for an editor
             
             Add couple of tests have to fail!
             */
            detailsText.text = todo.details
            //------------------------------------------------------------------
            categoryText?.text = todo.category
            prioritySegment?.selectedSegmentIndex = todo.priority - 1
            title = todo.id < 0 ? "New" : "#\(todo.id)"
        } else {
            if let value = titleText?.text { todo.title = value }
            if let value = detailsText?.text { todo.details = value }
            if let value = categoryText?.text { todo.category = value }
            todo.priority = prioritySegment.selectedSegmentIndex + 1
        }
        
    }
    
    // MARK: - Actions
    
    /* BREAKING ATTEMPT #7
     Imagine that during refactoring we lose wiring to some Actions.
     Tests must show that
     */
    @IBAction func onDone(_ sender: Any) {
        self.setEditing(false, animated: true)
        syncData(forward: false)
        guard todo.isDirty else {
            onCancel(sender)
            return
        }
        todo.update { [weak self] todo, error in
            guard error == nil  else {
                print("Cannot save todo: \(String(describing: error?.localizedDescription))")
                return
            }
            if let editor = self,
                let delegate = editor.delegate,
                let todo = editor.todo {
                
                delegate.editor(editor, didChange: todo)
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.setEditing(false, animated: true)
        delegate?.editor(self, didChange: nil)
        dismiss(animated: true, completion: nil)
    }
    
}
