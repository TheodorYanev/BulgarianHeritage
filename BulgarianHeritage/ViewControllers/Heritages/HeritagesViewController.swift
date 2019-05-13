//
//  HeritagesViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

enum HeritageType {
    case cultural
    case natural
    case intangible
}

class HeritagesViewController: UIViewController {
    typealias DidSelect = (Heritage, HeritageType) -> ()

    private let theme: Theme
    private let type: HeritageType
    private let didSelect: DidSelect?
    
    var items: [Heritage]?

    @IBOutlet weak var tableView: UITableView!
    
    init(theme: Theme, type: HeritageType, items: [Heritage]? = nil, didSelect: DidSelect? = nil) {
        self.theme = theme
        self.type = type
        self.items = items
        self.didSelect = didSelect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.register(cellClass: HeritagesTableViewCell.self)
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
}

extension HeritagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let items = items else { return }
        didSelect?(items[indexPath.row], type)
    }
}

extension HeritagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = items else { return UITableViewCell() }
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath) as HeritagesTableViewCell
        cell.titleLabel.text = item.title
        cell.titleLabel.textColor = theme.mainLabelColor
        return cell
    }
}
