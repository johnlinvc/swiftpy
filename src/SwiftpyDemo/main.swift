import Swiftpy

initPython()

let hello:PythonString = "hello python fuction"
let upperHello = hello.call("upper")
print(upperHello.toPythonString())

let defLeftPad = "def leftPad(str,len,fillchar):\n" +
                 "    return str.rjust(len,fillchar)"
evalStatement(defLeftPad)

let leftPadStr:PythonString = "leftPad"
let n:PythonInt = 10
let fillChar:PythonString = "j"
let leftPadded = call("leftPad",args: leftPadStr, n, fillChar)
print(leftPadded.toPythonString())

let evalStr = eval("\"look! EVIL\"")
print(evalStr.toPythonString())

let addStr = eval("1 + 1")
print(addStr.toPythonString())

let defFoo = "class Foo:\n" +
             "    def __init__(self):\n" +
             "        self.bar = 'i am an ivar'"

evalStatement(defFoo)

let foo = eval("Foo()")
let bar = foo.attr("bar")
print(bar.toPythonString())

let newBarVal:PythonString = "i'm the new bar"
foo.setAttr("bar", value:newBarVal)
let newBar = foo.attr("bar")
print(newBar.toPythonString())
