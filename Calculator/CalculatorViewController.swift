/**************************************************************************************
 * Class: CalculatorViewController
 *
 * Author:  Joseph Maurer
 *
 * Email:   Joseph.Maurer2@oit.edu
 *
 * Date:    February 12, 2016
 *
 * Purpose: This class is used to control the calculator user interface.
 *
 * Variables:
 *      display: The main result that is displayed.
 *
 *      userIsInTheMiddleOfTypingANumber: .... I think this one says it all :)
 *
 *      brain: allows the UI to connect to the thing that will preform the operation.
 *
 *      history: The red at the top that says the operation being preformed.
 *
 *      var displayValue: Double 
 *          Works to return and set the value of the displayed value on the screen. 
 *
 * Methods:
 *      @IBAction func appendDigit(sender: UIButton)
 *          Appends the digit to the display text. Doesn't not do the logic.
 *      @IBAction func enter()
 *          Sends the enter value to the brain.
 *      @IBAction func operate(sender: UIButton)
 *          When the final op is given it calls the methods to call calculate.
 *      @IBAction func backspace(sender: UIButton) 
 *              Function implements the backspace button in the top right
 *              more or less a clear.
 *      @IBAction func backOne()
 *              Undo function. Removes the last input from the display value.
 *      @IBAction func negative(sender: UIButton)
 *              Allows the user to be able to switch from positive to negative values.
 *
 *******************************************************************************************/

import UIKit // import the UI portion of the OS

class CalculatorViewController: UIViewController // class definition for the default UI: inherit from the UI controller
{
    // make a property (instance variable)
    // variable pointer to property, automatic garabge collection. : UILabel is the type of the variable. also an option so the ! must be there. implicitly unwrapped optional
    @IBOutlet var display: UILabel!
    
    // variable to determine if a user is in the middle of typing a digit. Must set it to an intital value when instantiating an object in swift!
    var userIsInTheMiddleOfTypingANumber: Bool = false
    
    // reference to the swift code that will eventually handle the calculator logic
    private var brain = CalculatorBrain()
    
    // the variable below links to the top feild that indicates the what operations the user is/has done
    @IBOutlet weak var history: UILabel!
    
    // Stack variable to hold the operands that are operated on
    //var  operandStack = Array<Double>() // -or- var  operandStack: Array<Double> = Array<Double>()
    
    
    /**********************************************************************
    * Purpose: Appends the digit to the display text. Doesn't not do the logic.
    *
    * Entry: Button Press.
    *
    * Exit: Updated Stack Frame
    *
    ************************************************************************/
    @IBAction func appendDigit(sender: UIButton)
    {
        // method to handle button press action of the 7 key
        // if there was a return type, there would be an (  -> Double  ) before the {
        
        
        // declare a local variable
        let digit = sender.currentTitle! // gets the current title from the button. Not the best, but it'll work
        if userIsInTheMiddleOfTypingANumber
        {
            if (digit == ".") && (display.text!.rangeOfString(".") != nil)
            {
                return // we found a "." in the current display string. Get out of hur
            }
            else
            {
                display.text = display.text! + digit // add digit pressed to the display
            }
        }
        else
        {
            if digit == "." // add the decimal point to the end of the display text
            {
                display.text = "0."
            }
            else
            {
                display.text = digit // if there is already a . don't readd one!
            }
            userIsInTheMiddleOfTypingANumber = true // set var to handle the next instance of typying a digit
            history.text = brain.description != "?" ? brain.description : "" // case for if we don't have everything we need to compute
        }
        
    }
    /**********************************************************************
     * Purpose: Logic to implement the enter key
     *
     * Entry: Button Press.
     *
     * Exit: Pushed operation by the calc brain
     *
     ************************************************************************/
    @IBAction func enter()
    {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue)
        {
            displayValue = result
        }
        else {
            displayValue = 0
        }
    }
    
    /**********************************************************************
     * Purpose: Handle the details for gettting/setting the displayValue
     *
     * Entry: none
     *
     * Exit: A correct displayValue that the user can see.
     *
     ************************************************************************/
    var displayValue: Double
    {
        get
        {
            // take the string text and convert to a double and return that value
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set
        {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
            let stack = brain.getStack()
            if !stack!.isEmpty {
                history.text = brain.description + " ="
            }
        }
    }

    /**********************************************************************
    * Purpose: When ready, call the operate funct
    *
    * Entry: Button Press
    *
    * Exit: Updated display Value for the result of the operation.
    *
    ************************************************************************/
    @IBAction func operate(sender: UIButton)
    {
        //let operation = sender.currentTitle! // unwrap the current sender
        
        if userIsInTheMiddleOfTypingANumber
        {
            enter() // automatic enter when user presses the op key
        }
        if let operation = sender.currentTitle
        {

            if let result = brain.performOperation(operation)
            {
                if brain.errorcase() == true
                {
                    history.text = "ERROR: Press AC to reset"
                    brain.resetStack()
                    display.text = "--"
                    
                }
                else
                {
                    displayValue = result
                }
            }
            else
            {
                displayValue = 0
            }
        }
        // calculator logic now moved out of controler to conform to MVC: see Calc Brain
    }

    /**********************************************************************
     * Purpose: Allow the user to be abke to implement a "." to a num.
     *
     * Entry: Button Press
     *
     * Exit: Updated display Value with logic checking.
     *
     ************************************************************************/
    @IBAction func decimal(sender: UIButton)
    {
        // check to see if the currrent display value already
        // doesn't contains a decimal before adding one to it.
        if (display.text?.rangeOfString(".") != nil)
        {
                display.text = display.text! + "."
        }
    }
    
    /**********************************************************************
    * Purpose: Function implements the fire button in the top right
    *          more
    *
    * Entry: Button Press
    *
    * Exit: Removes the everything :) should probably be named something else....
    *
    ************************************************************************/
    @IBAction func backspace(sender: UIButton)
    {
        //display.text?.removeAll()
        brain.resetStack();
        displayValue = 0 // reset the value
        history.text = " " //clear out the history UILabel
    }

    /**********************************************************************
     * Purpose: Function implements the backspace button in the top right
     *          more
     *
     * Entry: Button Press
     *
     * Exit: Removes the last thing added..
     *
     ************************************************************************/
    @IBAction func backOne()
    {
        if userIsInTheMiddleOfTypingANumber
        {
            let displayText = display.text!

            if  displayText.characters.count > 1
            {
                display.text = displayText.substringToIndex(displayText.endIndex.predecessor())
            }
            else {
                display.text = "0"
            }
        }
    }
    
    /**********************************************************************
     * Purpose: Function implements the pos/neg button
     *
     * Entry: Button Press
     *
     * Exit: inverses the number to be positive or negative.
     *
     ************************************************************************/
    @IBAction func negative(sender: UIButton)
    {
        if let operation = sender.currentTitle
        {
                if operation == "±"
                {
                    let displayText = display.text!
                    if (displayText.rangeOfString("-") != nil) //if the string already is negative
                    {
                        // go in and replace the negative sign with a space
                        let replace = String(displayText.characters.map { $0 == "-" ? " " : $0 })
                        display.text = replace // set the new display value
                    }
                    else // if the string is positive
                    {
                        display.text = "-" + displayText // add a negative sign
                    }
                }
            }
    }

}