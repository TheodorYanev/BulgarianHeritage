//
//  HeritageViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 4.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import Localize_Swift

class HeritageViewController: UIViewController {
    typealias ShowLocation = (String,Location) -> ()
    
    private let theme: Theme
    private let heritage: Heritage
    private let footerEnabled: Bool
    private let showLocation: ShowLocation?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var upperLineView: UIView!
    
    @IBAction func didTapOnMapButton(_ sender: UIButton) {
        guard let position = heritage.location else {
            return
        }
        showLocation?(heritage.title, position)
    }

    init(theme: Theme, heritage: Heritage, footerEnabled: Bool = true, showLocation: ShowLocation? = nil) {
        
        self.theme = theme
        self.heritage = heritage
        self.footerEnabled = footerEnabled
        self.showLocation = showLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        localize()
        setupImageView()
        footerView.isHidden = footerEnabled ? false : true
        mapButton.setImage(UIImage(named: "google-maps"), for: .normal)
    }

}

extension HeritageViewController {
    
    private func setupImageView() {
        imageView.backgroundColor = UIColor.black
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let imageURL = strongSelf.heritage.imageURL
            guard let url = URL(string: imageURL),
                let imageData = try? Data(contentsOf: url) else {
                    return
            }
            strongSelf.imageView.image = UIImage(data: imageData)
        }
    }
    
    private func brand() {
        infoLabel.textColor = theme.mainLabelColor
        view.backgroundColor = theme.mainViewBackgroundColor
        footerView.backgroundColor = theme.footerViewbackgroundColor
        upperLineView.backgroundColor = theme.footerViewLineColor
        mapButton.tintColor = theme.footerViewButtonTintColor
        mapButton.setTitleColor(theme.footerViewTextColor, for: .normal)
    }
    
    private func localize() {
        title = heritage.title
        infoLabel.text = heritage.info
        mapButton.setTitle("Location".localized(), for: .normal)
    }
}
