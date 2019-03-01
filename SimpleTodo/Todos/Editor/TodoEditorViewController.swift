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
    
    private(set) var viewModel: TodoEditorViewModelProtocol!
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
        syncUI()
        self.titleText.becomeFirstResponder()
    }
    
    func configure(withDelegate delegate:TodoEditorViewControllerDelegate,
                   todo: Todo,
                   modificationType: ModificationType = .edit) {
        self.delegate = delegate
        self.viewModel = TodoEditorViewModel(with: todo)
        self.modificationType = modificationType
    }
    
    func syncUI(toUI: Bool = true) {
        if toUI {
            title = viewModel.title
            titleText?.text = viewModel.todo.title
            /* BREAKING ATTEMPT #5
             imagine we forgot to sync detail for an editor
             
             Add couple of tests have to fail!
             */
            detailsText.text = viewModel.todo.details
            //------------------------------------------------------------------
            categoryText?.text = viewModel.todo.category
            prioritySegment?.selectedSegmentIndex = viewModel.todo.priority - 1
            title = viewModel.todo.id < 0 ? "New" : "#\(viewModel.todo.id)"
        } else {
            if let value = titleText?.text { viewModel.todo.title = value }
            if let value = detailsText?.text { viewModel.todo.details = value }
            if let value = categoryText?.text { viewModel.todo.category = value }
            viewModel.todo.priority = prioritySegment.selectedSegmentIndex + 1
        }
        
    }
    
    // MARK: - Actions
    
    /* BREAKING ATTEMPT #7
     Imagine that during refactoring we lose wiring to some Actions.
     Tests must show that
     */
    @IBAction func onDone(_ sender: Any) {
        self.setEditing(false, animated: true)
        syncUI(toUI: false)
        guard viewModel.todo.isDirty else {
            onCancel(sender)
            return
        }
        viewModel.update { [weak self] result in
            switch result {
            case .failure(let error):
                print("Cannot save todo: \(error)")
                return
            case .success(let todo):
                guard let editor = self, let delegate = editor.delegate  else { return }
                editor.viewModel.todo = todo
                delegate.editor(editor, didChange: todo)
                editor.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.setEditing(false, animated: true)
        delegate?.editor(self, didChange: nil)
        dismiss(animated: true, completion: nil)
    }
    
}
