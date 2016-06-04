import Swiftpy

initPython()
runSimpleString(string:"def p(str):\n  print str\n")
let main = pythonImport(name: "__main__")
let hello:PythonString = "hello python fuction"
let upperHello = hello.call("upper")
main.call("p", args: upperHello)
