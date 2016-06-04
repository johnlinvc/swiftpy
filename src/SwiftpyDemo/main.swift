import Swiftpy

initPython()
runSimpleString("def p(str):\n  print str\n")
let main = pythonImport(name: "__main__")
let hello:PythonString = "hello python fuction"
let upperHello = hello.call("upper")
main.call("p", args: upperHello)
print(hello.toPythonString())
let evalStr = eval("\"look! EVIL\"")
print(evalStr.toPythonString())
let addStr = eval("1 + 1")
print(addStr.toPythonString())
