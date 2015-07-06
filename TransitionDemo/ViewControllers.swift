//
//  ViewControllers.swift
//  TransitionDemo
//
//  Created by Lammert Westerhoff on 06/07/15.
//  Copyright (c) 2015 Xebia. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton, detailViewController = segue.destinationViewController as? DetailViewController {
            detailViewController.color = button.superview?.backgroundColor
            detailViewController.colorName = button.titleForState(.Normal)
            detailViewController.labelColor = button.titleLabel?.textColor
        }
    }


}

class DetailViewController: UIViewController {

    var color: UIColor!
    var colorName: String!
    var labelColor: UIColor!

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = colorName

        colorView.backgroundColor = color
        label.text = colorName
        label.textColor = labelColor
    }
}
