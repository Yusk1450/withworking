//
//  eventPopupViewController.swift
//  ShinGikenApp
//
//  Created by ichinose-PC on 2026/02/27.
//

import UIKit

class eventPopupViewController:UIViewController
{
    var eventName: String?
    @IBOutlet weak var evenTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.evenTitle.text = eventName
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        self.presentingViewController?
            .presentingViewController?
            .dismiss(animated: true)
    }

    @IBAction func backBtn(sender: AnyObject) {
        self.presentingViewController?
            .presentingViewController?
            .dismiss(animated: true)
    }
}
