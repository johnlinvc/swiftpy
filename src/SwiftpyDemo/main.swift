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
let defFoo = "class Foo:\n" +
             "    def __init__(self):\n" +
             "        self.bar = 'i am an ivar'"

runSimpleString(defFoo)
let foo = eval("Foo()")
let bar = foo.attr("bar")
print(bar.toPythonString())
