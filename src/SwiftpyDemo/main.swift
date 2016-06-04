import Swiftpy
initPython()
runSimpleString(string:"def p(str):\n  print str\n")
let main = pythonImport(name: "__main__")
let hello:PythonString = PythonString(stringLiteral:"hello function")
main.call(funcName:"p", args: hello)
