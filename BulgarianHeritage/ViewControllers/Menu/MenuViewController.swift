//
//  MenuViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 21.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import Localize_Swift

enum CellIdentifier {
    case heritage
    case scores
    case quiz
}

struct Cell {
    var title: String
    var identifier: CellIdentifier
}
protocol MenuViewControllerDelegate: class {
    func menuViewController(_ controller: MenuViewController, didSelectItemAt indexPath: IndexPath)
    func menuViewControllerDidPressedLogOut(_ controller: MenuViewController)
}

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var logOutButton: UIButton!

    @IBAction func logOutButtonPressed(_ sender: UIButton) {
        delegate?.menuViewControllerDidPressedLogOut(self)
    }

    let theme: Theme
    let cells: [Cell]

    weak var delegate: MenuViewControllerDelegate?

    public init(_ cells: [Cell], theme: Theme) {
        self.cells = cells
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        tableView.estimatedRowHeight = 40.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: MenuTableViewCell.self)
        logOutButton.setTitle("Log out".localized(), for: .normal)
        logOutButton.layer.cornerRadius = 5.0
        logOutButton.layer.borderWidth = 2.0
    }
    
    private func brand() {
        tableView.backgroundColor = theme.tableViewBackgroundColor
        logOutButton.tintColor = theme.logOutButtonTintColor
        logOutButton.layer.borderColor = theme.logoutButtonBorderColor.cgColor
        logOutButton.setTitleShadowColor(theme.logoutButtonTitleShadowColor, for: .normal)
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.menuViewController(self, didSelectItemAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = cells[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath) as MenuTableViewCell
        cell.categoryTextLabel.text = item.title
        cell.categoryTextLabel.textColor = theme.tableViewCellTextColor
        cell.categoryTextLabel.shadowColor = theme.tableViewCellTextShadowColor
        cell.categoryTextLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cell.backgroundColor = theme.tableViewCellBackgroundColor
        return cell
    }
}
