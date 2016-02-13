/**************************************************************************************
 * Class: CalculatorBrain
 *
 * Author:  Joseph Maurer
 *
 * Email:   Joseph.Maurer2@oit.edu
 *
 * Date:    February 12, 2016
 *
 * Purpose: This class is used to control the calculator logic for my
 *          example code for Zappos Internship 2016.
 *
 * Manager functions:
 *      description: This manager function handles the logic for 
 *                      getting the description(The text that shows
 *                      what the user has input) Doesn't implement the
 *                      setter.
 *
 * Methods:
 *          private func description(ops: [Op]) -> (result: String?, remainingOps: [Op])
 *              Works to get the description of the current based on what operation is
 *              being done. For example if there is a unary sqrt, it will return √ and
 *              the value that was being operated on.
 *         private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
 *              Works to determine which operation to do, if it has everything it needs,
 *              and then calls that operation if all conditions are met.
 *         func evaluate() -> Double?
 *              This function is the one that eventually displays the current stack to 
 *              the console window and returns the answer.
 *         func pushOperand(operand: Double) -> Double?
 *              This pushes an operand onto the stack, and acts like a pass through 
 *              function(It will pass back the solution as a double after calling 
 *              the appropriate functions)
 *         func performOperation(symbol: String) -> Double?
 *              This functions performs the operation once if gets the final operation.
 *              If you ever want to convert to a infix notation calculator, fix here.
 *         func resetStack()
 *              This function removes everything from the stack. Called when the
 *              little fire emoji is pressed lol
 *          func getStack() -> String?
 *              This is a helper function that handles taking the current stack and
 *              serializing that data so that the front end can just display a string :)
 *          func errorcase() -> Bool
 *              This function returns the part flag that is set when an error case 
 *              is reached. Its also this functions job to reset the flag.
 *******************************************************************************************/

import Foundation

class CalculatorBrain
{
    var errordetect = false
    /**********************************************************************
     * Purpose: This enum is used so that the calculator know the difference 
     *          between a Unary and Binary operation.
     *
     * Entry: Avaiable on instantiation
     *
     * Exit: Allows an operation to be printable and more intuitive
     *
     ************************************************************************/
    private enum Op: CustomStringConvertible
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double,Double) -> Double)
        case Variable(String)
        
        // implement a protocol to be Printable
        var description: String
        {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol,_):
                    return symbol
                case .BinaryOperation(let symbol,_):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
        
    }
    private var opStack = [Op]()    // Same as var opStack: array<Op>
    
    private var knownOps = [String:Op]()   // -similar to- Dictionary<String, Op>()
    
    var variableValues = [String: Double]()
    
    /**********************************************************************
     * Purpose: This init adds the known operations that the calculator 
     *          can do. If expanding operations add them here.
     *
     * Entry: Avaiable on instantiation
     *
     * Exit: KnownOps now know how to calculate themselves!
     *
     ************************************************************************/
    init()
    {  // will be called anytime someone say let brain = CalculatorBrain()
         knownOps["×"] = Op.BinaryOperation("×", *) // - or- without ",*"{ $0 * $1}
         knownOps["÷"] = Op.BinaryOperation("÷") {$0 == 0 ? 0.0 : $1 / $0}
         knownOps["+"] = Op.BinaryOperation("+", +) //{ $0 + $1}
         knownOps["−"] = Op.BinaryOperation("−") { $1 - $0}
         knownOps["√"] = Op.UnaryOperation("√")  { $0 < 0 ? 0.0 : sqrt($0) }
         //knownOps["x²"] = Op.UnaryOperation("x²", pow(Double($0),Double($0)))
         //knownOps["%"] = Op.BinaryOperation("/") {$1 / 100.0 }
        
    }
    
    /**********************************************************************
     * Purpose: This getter allows you to access the description in easier
     *      to understand terms for the user
     *
     * Entry: A stack of operations to conv
     *
     * Exit: Allows an operation to be printable to the end user.
     *
     ************************************************************************/
    var description: String
    {
        get
        {
            var (result, ops) = ("", opStack)
            repeat
            { // doesn't allow a do-while for some weird reason
                var current: String?
                (current, ops) = description(ops) // get the description
                result = result == "" ? current! : "\(current!), \(result)"
            } while ops.count > 0 // while there are still things to display
            return result
        }
    }
    
    /**********************************************************************
     * Purpose: This func converts operations to readable english
     *
     * Entry: Passed operations
     *
     * Exit: symbol and string. Need to be formatted before returned to UI.
     *
     ************************************************************************/
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op])
    {
        if !ops.isEmpty // if there are operations to preform on
        {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op // find the operation that is the current
            {
            case .Operand(let operand):  // format the string to return
                return (String(format: "%g", operand) , remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = description(remainingOps)
                if let operand = operandEvaluation.result
                {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Evaluation = description(remainingOps)
                if var operand1 = op1Evaluation.result
                {
                    if remainingOps.count - op1Evaluation.remainingOps.count > 2
                    {
                        operand1 = "(\(operand1))"
                    }
                    let op2Evaluation = description(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result
                    {
                        return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let symbol):
                return (symbol, remainingOps)
            }
        }
        return ("?", ops) // return ? if you don't have the right things for the op
    }
    /**********************************************************************
     * Purpose: This func is the on to make sure there are the proper 
     *          things on the stack to perform the operations, and then
     *          call the appr methods.
     *
     * Entry: The operations to preform
     *
     * Exit: The remaining stack which now includes the result as the
     *         first arg and the remaining as the second.
     *
     ************************************************************************/
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if (!ops.isEmpty)
        {
            var remainingOps = ops // makes a copy of this
            let op = remainingOps.removeLast()
            switch op {
                case .Operand(let operand):
                    return (operand, remainingOps)
                case .UnaryOperation(_, let operation):
                    // get the next one off the stack
                    let operandEvaluation = evaluate(remainingOps)
                    if let operand = operandEvaluation.result
                    {
                        if ( String(op) == "√" && operand < 0.0)
                        {
                            print("Error: Imaginary. Input reset to 0")
                            errordetect = true
                            return (0.0,ops)
                        }
                      return (operation(operand), operandEvaluation.remainingOps)
                    }
                case .BinaryOperation(_, let operation):
                    let op1Evaluation = evaluate(remainingOps)
                    if let operand1 = op1Evaluation.result
                    {
                        let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                        if let operand2 = op2Evaluation.result
                        {
                            if ( String(op) == "÷" && operand1 == 0.0)
                            {
                                print("Error: Division by Zero. Input reset to 0")
                                errordetect = true
                                return (0.0,ops)
                            }
                            return (operation(operand1, operand2), op2Evaluation.remainingOps)
                        }
                }
            case .Variable(let symbol):
                        return (variableValues[symbol], remainingOps)
            }
        }
        return (nil, ops)
        
    }
    /**********************************************************************
     * Purpose: Formats the concole window for out.
     *
     * Entry: Passed operations
     *
     * Exit: The result of the evaluation
     *
     ************************************************************************/
    func evaluate() -> Double?
    { // must be an optional so that you can return nill for an invalid
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    /**********************************************************************
     * Purpose:     This pushes an operand onto the stack, and acts like
     *              a pass through function(It will pass back the solution
     *              as a double after calling the appropriate functions)
     *
     * Entry: Thing to push... ahhh push it
     *
     * Exit: Double value that is returned from evaluate.
     *
     ************************************************************************/
    func pushOperand(operand: Double) -> Double?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    /**********************************************************************
     * Purpose: This functions performs the operation once if gets the
     *          final operation. If you ever want to convert to a infix
     *          notation calculator, fix here.
     *
     * Entry: Symbol that is needed to perform the operation.
     *
     * Exit: The result of the evaluation.
     *
     ************************************************************************/
    func performOperation(symbol: String) -> Double?
    {
        if let operation = knownOps[symbol]
        {
            opStack.append(operation)
        }
         return evaluate()
    }
    /**********************************************************************
     * Purpose: Remove the things from the stack,
     *
     * Entry: none.
     *
     * Exit: An empty stack! Reset to init condition
     *
     ************************************************************************/
    func resetStack()
    {
        opStack.removeAll();
    }
    /**********************************************************************
     * Purpose: Gets the stack as a readable string
     *
     * Entry: none.
     *
     * Exit: String to be display in the UI.
     *
     ************************************************************************/
    func getStack() -> String?
    {
        return opStack.map{ "\($0)" }.joinWithSeparator(" ")
    }
    
    /**********************************************************************
     * Purpose: This function returns the part flag that is set when an
     *          error case is reached. Its also this functions job to
     *          reset the flag.
     *
     * Entry: none.
     *
     * Exit: Bool that reads the errordetect variable
     *
     ************************************************************************/
    func errorcase() -> Bool
    {
        if errordetect == true
        {
            errordetect = false
            return true
        }
        else
        {
            return false
        }
    }
}


