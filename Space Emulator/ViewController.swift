//
//  ViewController.swift
//  Space Emulator
//
//  Created by Nikita Grigorchuk on 14.03.2019.
//  Copyright © 2019 Rusdev. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var count = 1
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuTableViewCell
        {
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            count = count - 1
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        
        
    }
    
    @IBAction func addButtonTouched(_ sender: Any) {
        count = count + 1
        tableView.reloadData()
    }
    
    @IBAction func startButtonTouched(_ sender: Any) {
        if count != 0
        {
        if let gameController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameController") as? GameViewController{
           
            for i in 0...count-1
            {
                if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MenuTableViewCell
                {
                   let type = cell.t
                    let mass = (cell.massTextField.text! as NSString).doubleValue
                    let radius = (cell.radiusTextField.text! as NSString).doubleValue
                    let x = (cell.xVectorTextField.text! as NSString).doubleValue
                    let y = (cell.yVectorTextField.text! as NSString).doubleValue
                    let z = (cell.zVectorTextField.text! as NSString).doubleValue
                    let vector = SCNVector3(x, y, z)
                    
                    let xPos = (cell.xStartTextField.text! as NSString).doubleValue
                    let yPos = (cell.yStartTextField.text! as NSString).doubleValue
                    let zPos = (cell.zStartTextField.text! as NSString).doubleValue
                    let vectorPos = SCNVector3(xPos, yPos, zPos)
                    
                    gameController.planetsData.append((type: type , mass: mass, radius: radius, vector: vector, position: vectorPos))
                }
            }
            self.navigationController?.pushViewController(gameController, animated: true)
        }
    }
    }
}


extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
