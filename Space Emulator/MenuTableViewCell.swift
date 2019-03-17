//
//  MenuTableViewCell.swift
//  Space Emulator
//
//  Created by Nikita Grigorchuk on 17.03.2019.
//  Copyright © 2019 Rusdev. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var types = ["Sun","Earth","Planet"]
    var t : planetType = planetType.sun
    
    @IBOutlet weak var massTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    
    @IBOutlet weak var xVectorTextField: UITextField!
    @IBOutlet weak var yVectorTextField: UITextField!
    @IBOutlet weak var zVectorTextField: UITextField!
    
    @IBOutlet weak var planetTypePickerView: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        planetTypePickerView.delegate = self
        planetTypePickerView.dataSource = self
        // Configure the view for the selected state
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let str = types[row]
            switch str {
            case "Sun":
                t = .sun
            case "Earth":
                t = .earth
            case "Planet":
                t = .planet
            default:
                break
            }
    }

}
