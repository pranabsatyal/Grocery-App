//  Created by Pranab Raj Satyal on 5/12/21.

import UIKit

class GroceryListTableViewCell: UITableViewCell {
    
    static let identifier = "GroceryListTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        detailTextLabel?.font = .systemFont(ofSize: 15, weight: .light)
        textLabel?.numberOfLines = 2
        textLabel?.lineBreakMode = .byWordWrapping
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
