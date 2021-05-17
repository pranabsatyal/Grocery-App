//  Created by Pranab Raj Satyal on 5/8/21.

import UIKit

class GroceryListViewController: UIViewController {
    
    // MARK:- properties
    private var groceryList = [GroceryList]()
    private var filteredItem = [GroceryList]()
    private let searchBar = UISearchController()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(GroceryListTableViewCell.self, forCellReuseIdentifier: GroceryListTableViewCell.identifier)
        return tableView
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch data from core data
        self.fetchGroceries()
        
        setUpNavigationBar()
        
        searchBar.searchBar.delegate = self
        setUpSearchBar()
        
        view.addSubview(tableView)
    }
    
    //MARK:- View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Grocery List"
    }
    
    //MARK:- View will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    //MARK:- Setting Navigation
    func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
    }
    
    //MARK:- Setting Search Bar
    func setUpSearchBar() {
        searchBar.hidesNavigationBarDuringPresentation = false
        searchBar.obscuresBackgroundDuringPresentation = false
    }
    
    //MARK:- Add button
    func showAlertToAddItems(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter Item Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Enter quantity"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { alertAction in
            guard let item = alert.textFields?[0].text else { return }
            
            if item.isEmpty {
                self.showAlertToAddItems(title: "Provide Item to add", message: "Empty item cannot be added to the list")
                return
            } else {
                for eachItem in self.groceryList {
                    if eachItem.name?.lowercased() == item.lowercased() {
                        self.showAlertToAddItems(title: "Item already exists in your list", message: "Please enter a new Item")
                        return
                    }
                }
            }
            
            guard let quantity = alert.textFields?[1].text else { return }
            
            let addItem = GroceryList(context: self.context)
            addItem.name = item.capitalized
            addItem.quantity = quantity
            
            do {
                try self.context.save()
            } catch {
                // error while saving data
                print(error)
            }
            
            self.fetchGroceries()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- fetch data from core data
    
    func fetchGroceries() {
        
        self.groceryList = try! context.fetch(GroceryList.fetchRequest())
        reloadTableData()
    }
    
    func reloadTableData() {
        
        DispatchQueue.main.async {
            if self.groceryList.count > 0 {
                self.navigationItem.searchController = self.searchBar
                self.searchBar.searchBar.placeholder = "Search Item Name"
            }
            self.filteredItem = self.groceryList
            self.tableView.reloadData()
        }
        
    }
    
    //MARK:- Swipe left to edit button
    private func handleEditing(at index: IndexPath) {
        
        let alert = UIAlertController(title: "Edit the Item", message: "Make necessary changes to the item", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.filteredItem[index.row].name
        }
        
        alert.addTextField { textField in
            textField.text = self.filteredItem[index.row].quantity ?? ""
            if textField.text == "" {
                textField.placeholder = "Enter quantity"
            }
        }
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            
            if let itemIndex = self.groceryList.firstIndex(of: self.filteredItem[index.row]) {
                self.groceryList[itemIndex].name = (alert.textFields?[0].text)!.capitalized
                self.groceryList[itemIndex].quantity = alert.textFields?[1].text
            }
            
            self.filteredItem[index.row].name = (alert.textFields?[0].text)!.capitalized
            self.filteredItem[index.row].quantity = alert.textFields?[1].text
            
            do {
                try self.context.save()
            } catch {
                // error while saving data
                print(error)
            }
            
            self.fetchGroceries()
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK:- Objc Selector functions
    @objc func backToListButtonTapped(_ sender: UIBarButtonItem!) {
        filteredItem = groceryList
        navigationItem.title = "Grocery List"
        sender.isEnabled = false
        sender.title = nil
        tableView.reloadData()
    }
    
    @objc func addButtonTapped(_ sender: UIBarButtonItem!) {
        showAlertToAddItems(title: "Add item to List", message: "Name the item you want to add to your list")
    }
    
    
}

//MARK:- Table View Data Source
extension GroceryListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroceryListTableViewCell.identifier, for: indexPath)
        let groceryItem = filteredItem[indexPath.row]
        cell.textLabel?.text = groceryItem.name
        
        if let quantity = groceryItem.quantity {
            if !quantity.isEmpty {
                cell.detailTextLabel?.text = " Quantity : \(quantity)"
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        
        return cell
        
    }
    
}

//MARK:- Table View Delegate
extension GroceryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: nil, message: "This item will be deleted. This action cannot be undone", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                
                if let index = self.groceryList.firstIndex(of: self.filteredItem[indexPath.row]) {
                    self.context.delete(self.groceryList[index])
                }
                self.filteredItem.remove(at: indexPath.row)
                
                do {
                    try self.context.save()
                } catch {
                    // error saving
                    print(error)
                }
                
                DispatchQueue.main.async {
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.searchBar.searchBar.text = ""
                    
                    if self.filteredItem.isEmpty {
                        self.searchBar.dismiss(animated: true, completion: nil)
                        self.filteredItem = self.groceryList
                        self.navigationItem.title = "Grocery List"
                        self.setUpNavigationBar()
                    }
                    
                }
                
                self.fetchGroceries()
                
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal,
                                        title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.handleEditing(at: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

//MARK:- Search Bar Delegate
extension GroceryListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredItem = []
        
        if searchText.isEmpty {
            filteredItem = groceryList
            
        } else {
            for item in groceryList {
                if item.name!.lowercased().contains(searchText.lowercased()) {
                    filteredItem.append(item)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        navigationItem.title = "Search"
        navigationItem.rightBarButtonItem = nil
        
        if filteredItem.isEmpty {
            let alert = UIAlertController(title: "Empty List", message: "No items in list to search", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationItem.title =  "Grocery List"
                self.setUpNavigationBar()
            })
            
            present(alert, animated: true, completion: nil)
            
        }
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredItem = groceryList
        navigationItem.title = "Grocery List"
        setUpNavigationBar()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.dismiss(animated: true, completion: nil)
        self.setUpNavigationBar()
        
        if !filteredItem.isEmpty {
            navigationItem.title = "Search Results"
            searchBar.text = ""
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back to List", style: .plain, target: self, action: #selector(backToListButtonTapped(_:)))
            
        } else {
            let alert = UIAlertController(title: "Item not found", message: " \"\(searchBar.text!)\" is not in the list", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.filteredItem = self.groceryList
                self.tableView.reloadData()
                searchBar.text = ""
                searchBar.becomeFirstResponder()
            })
            present(alert, animated: true, completion: nil)
        }
        
    }
    
}
