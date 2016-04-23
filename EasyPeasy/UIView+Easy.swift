// The MIT License (MIT) - Copyright (c) 2016 Carlos Vidal
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

infix operator <- {}

/**
    Operator which applies the attribute given to the view located
    in the left hand side of it
    - parameter lhs: `UIView` the attributes will apply to
    - parameter rhs: Attribute applied to the `UIView`
    - returns: The array of `NSLayoutConstraints` applied
 */
public func <- (lhs: UIView, rhs: Attribute) -> [NSLayoutConstraint] {
    return lhs <- [rhs]
}

/**
    Opeator which applies the attributes given to the view located
     in the left hand side of it
     - parameter lhs: UIView the attributes will apply to
     - parameter rhs: Attributes applied to the UIView
     - returns: The array of `NSLayoutConstraints` applied
 */
public func <- (lhs: UIView, rhs: [Attribute]) -> [NSLayoutConstraint] {
    // Disable autoresizing to constraints translation
    lhs.translatesAutoresizingMaskIntoConstraints = false
    
    // Create constraints to install and gather regular attribtues
    var constraintsToInstall: [NSLayoutConstraint] = []

    for attribute in rhs {
        // Create the constraint
        let newConstraints = attribute.createConstraintForView(lhs)
        constraintsToInstall.appendContentsOf(newConstraints)
    }
    
    // Install these constraints
    NSLayoutConstraint.activateConstraints(constraintsToInstall)
    
    // Return just regular `Attributes`, not `CompoundAttributes`
    return constraintsToInstall
}

/**
    Convenience methods applicable to `UIView` and subclasses
 */
public extension UIView {
    
    /**
        This method will trigger the recreation of the constraints
        created using *EasyPeasy* for the current view. `Condition` 
        closures will be evaluated again
     */
    public func easy_reload() {
        var storedAttributes: [Attribute] = []
        
        // Reload attributes owned by the superview
        if let attributes = (self.superview?.easy_attributes.filter { $0.createView === self }) {
            storedAttributes.appendContentsOf(attributes)
        }
        
        // Reload attributes owned by the current view
        let attributes = self.easy_attributes.filter { $0.createView === self }
        storedAttributes.appendContentsOf(attributes)

        // Apply
        self <- storedAttributes
    }
    
    /**
        Clears all the constraints applied with EasyPeasy to the
        current `UIView`
     */
    public func easy_clear() {
        // Remove from the stored Attribute objects of the superview
        // those which createView is the current UIView
        if let superview = self.superview {
            superview.easy_attributes = superview.easy_attributes.filter { $0.createView !== self }
        }
        
        // Remove from the stored Attribute objects of the current view
        // those which createView is the current UIView
        self.easy_attributes = self.easy_attributes.filter { $0.createView !== self }
        
        // Now uninstall those constraints
        var constraintsToUninstall: [NSLayoutConstraint] = []
        
        // Gather NSLayoutConstraints in the superview with self as createView
        for constraint in (self.superview?.constraints ?? []) {
            if let attribute = constraint.easy_attribute where attribute.createView === self {
                constraintsToUninstall.append(constraint)
            }
        }
        
        // Gather NSLayoutConstraints in self with self as createView
        for constraint in self.constraints {
            if let attribute = constraint.easy_attribute where attribute.createView === self {
                constraintsToUninstall.append(constraint)
            }
        }
        
        // Deactive the constraints
        NSLayoutConstraint.deactivateConstraints(constraintsToUninstall)
    }
    
}