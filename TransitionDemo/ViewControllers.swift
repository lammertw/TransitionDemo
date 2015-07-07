//
//  ViewControllers.swift
//  TransitionDemo
//
//  Created by Lammert Westerhoff on 06/07/15.
//  Copyright (c) 2015 Xebia. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var selectedView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Colors"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let button = sender as? UIButton, detailViewController = segue.destinationViewController as? DetailViewController {
            selectedView = button.superview
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

class ViewAnimations: NSObject, UINavigationControllerDelegate {

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        println("animating from \(fromVC) to \(toVC)")
        let animations = ColorAnimations()
        animations.reverse = fromVC is DetailViewController
        return animations
    }

}

class ColorAnimations: NSObject, UIViewControllerAnimatedTransitioning {

    var reverse = false

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.4
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let mainViewController = transitionContext.viewControllerForKey(reverse ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey) as! MainViewController
        let detailViewController = transitionContext.viewControllerForKey(reverse ? UITransitionContextFromViewControllerKey : UITransitionContextToViewControllerKey) as! DetailViewController

        transitionContext.containerView().addSubview(reverse ? mainViewController.view : detailViewController.view)

        let animationView = UIView()
        animationView.backgroundColor = mainViewController.selectedView!.backgroundColor
        transitionContext.containerView().addSubview(animationView)


        let animationLabel = UILabel()
        let button = mainViewController.selectedView!.subviews[0] as! UIButton
        animationLabel.font = UIFont.systemFontOfSize(15)
        animationLabel.text = button.titleForState(.Normal)
        animationLabel.textColor = button.titleLabel?.textColor
        animationLabel.backgroundColor = UIColor.clearColor()
        animationLabel.textAlignment = .Center
        transitionContext.containerView().addSubview(animationLabel)

        if !reverse {
            detailViewController.view.layoutIfNeeded()
            animationLabel.sizeToFit()
        }

        var sourceFrame = mainViewController.selectedView!.frame
        var targetFrame = detailViewController.view.frame
        var sourceLabelFrame = transitionContext.containerView().convertRect(button.frame, fromView: mainViewController.selectedView!)
        var targetLabelFrame = detailViewController.label.frame

        if reverse {
            swap(&sourceFrame, &targetFrame)
            swap(&sourceLabelFrame, &targetLabelFrame)
            animationLabel.frame = sourceLabelFrame
        }

        animationView.frame = sourceFrame
        animationLabel.center = CGPointMake(CGRectGetMidX(sourceLabelFrame), CGRectGetMidY(sourceLabelFrame))

        detailViewController.view.hidden = true

        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            animationView.frame = targetFrame
            animationLabel.center = CGPointMake(CGRectGetMidX(targetLabelFrame), CGRectGetMidY(targetLabelFrame))
            
            }) { finished in
                if finished {
                    animationView.removeFromSuperview()
                    animationLabel.removeFromSuperview()

                    detailViewController.view.hidden = false
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                }
        }


    }
}
