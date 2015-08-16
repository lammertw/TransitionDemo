Transitions are done with __UIViewControllerAnimatedTransitioning__.

    class ColorAnimations: NSObject, UIViewControllerAnimatedTransitioning {


    }

Two required methods.

        func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
            return 1.0
        }

        func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            // implement the transition
        }

- Tell app to use transitions with __UINavigationControllerDelegate__.
- Modal or custom different.

_Create a custom navigation controller delegate._

    class Transitions: NSObject, UINavigationControllerDelegate {

    }

- __Add to Storyboard.__

Only optional methods.

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      // here we check if we need to animate the transition from fromVC to toVC and then return a Animated Transitioning object
    }

Construct our transitions

    let animations = ColorAnimations()
    return animations

Run to show it's using it but messed up.

Get access to from and to view controllers.

    if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {


    }

Add to view to container view

    transitionContext.containerView().addSubview(toVC.view)

Need complete transition

    UIView.animateWithDuration(transitionDuration(transitionContext), animations: {

    }) { finished in
        if finished {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }

Run again. Works. Swipe doesn't work.

Add very basic animation.

    toVC.view.alpha = 0.0

Inside:

    toVC.view.alpha = 1.0

Run again. Everything works now.

Add nice animation:

    var reverse = false

In nav delegate

    animations.reverse = operation == .Pop

Replace view controllers:

    if let mainViewController = transitionContext.viewControllerForKey(reverse ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey) as? MainViewController,
        let detailViewController = transitionContext.viewControllerForKey(reverse ? UITransitionContextFromViewControllerKey : UITransitionContextToViewControllerKey) as? DetailViewController {

            transitionContext.containerView().addSubview(reverse ? mainViewController.view : detailViewController.view)

Add selected view to main view controller

    var selectedView: UIView?

In prepareForSegue

    selectedView = button.superview

The new animation:

    let animationView = UIView()
    animationView.backgroundColor = mainViewController.selectedView!.backgroundColor
    transitionContext.containerView().addSubview(animationView)

    if !reverse {
        detailViewController.view.layoutIfNeeded()
    }

    var sourceFrame = mainViewController.selectedView!.frame
    var targetFrame = detailViewController.view.frame

    animationView.frame = sourceFrame

    detailViewController.view.hidden = true

    UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
        animationView.frame = targetFrame

        }) { finished in
            if finished {
                animationView.removeFromSuperview()

                detailViewController.view.hidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
    }

Include label in animation:

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

Next, make interactive.

    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
       return interactionController
    }

Percent driven

    var interactionController: UIPercentDrivenInteractiveTransition?

- Add Pinch Gestures
- Name segues
- Create action

Implement Began state

    switch (sender.state) {

    case .Began:
        let button = sender.view as! UIButton
        performSegueWithIdentifier(button.titleForState(.Normal), sender: button)
    default: ()
        // do nothing for now
    }

Run to see pinch will open detail view controller

Add to Began:

    transitions?.interactionController = UIPercentDrivenInteractiveTransition()

Add other states:

    case .Changed:
        transitions?.interactionController?.updateInteractiveTransition(sender.scale - 1)

    default: // .Ended, .Cancelled, .Failed ...
        if sender.velocity > 0 || (sender.scale > 1.5 && sender.velocity == 0) {
            transitions?.interactionController?.finishInteractiveTransition()
        } else {
            transitions?.interactionController?.cancelInteractiveTransition()
        }
        transitions?.interactionController = nil
    }

To access the transitions from any view controller

    extension UIViewController {

        var transitions: Transitions? {
            return navigationController?.delegate as? Transitions
        }
    }

Add screen edge gesture to detail

    if let transitions = transitions {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: transitions, action: "pan:")
        edgePanGesture.edges = .Left
        view.addGestureRecognizer(edgePanGesture)
    }

Add pan: to transitions

    func pan(recognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view!)
        let d =  translation.x / CGRectGetWidth(recognizer.view!.bounds)

        switch (recognizer.state) {

        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            navigationController?.popViewControllerAnimated(true)

        case .Changed:
            interactionController?.updateInteractiveTransition(d)

        default:

            if recognizer.velocityInView(recognizer.view!).x > 0 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        }
    }

- Create outlet for navigationController

Run. End code.

Few notes:

- By adding navigation controller delegate, none of the swipe gestures work anymore regardless wether or not you return animations.
