//
//  WeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 행복한 개발자 on 11/06/2019.
//  Copyright © 2019 giftbot. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    
    var weatherData: Weather3Days? {
        didSet {
            dateLabel.text = weatherData!.date
            timeLabel.text = weatherData!.time
            stateImageView.image = UIImage(named: weatherData!.stateImage)
            degreeLabel.text = weatherData!.degree
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
