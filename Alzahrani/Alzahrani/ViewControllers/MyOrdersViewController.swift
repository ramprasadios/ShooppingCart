//
//  MyOrdersViewController.swift
//  Alzahrani
//
//  Created by shilpa shree on 5/16/17.
//  Copyright © 2017 Ramprasad A. All rights reserved.
//

import UIKit

class MyOrdersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var orderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTableView.delegate = self
        orderTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyorderTableViewCell
        
        cell?.orderImageView.image = UIImage(named:"download.jpeg")
        cell?.orderName.text = "Coffee Machine 1.5 ltr 50/0 Hz"
        cell?.orderNO.text = "OR550"
        cell?.placedOn.text = "chennai"
        cell?.qtyLabel.text = "6"
        cell?.priceLabel.text = "500.S.R"
        cell?.deliveryLabel.text = "20/10/2017"
        return (cell)!
    }
}
