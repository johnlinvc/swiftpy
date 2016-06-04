import Python

public func initPython(){
  Py_Initialize()
}

public func runSimpleString(_ string: String) {
        PyRun_SimpleStringFlags(string, nil);
}

func wrapEvalString( string : String) -> String {
        return "def _swiftpy_eval_wrapper_():\n" +
               "    result = \(string)\n" +
               "    return result"
}

//TODO handle def case
public func eval(_ code:String) -> PythonObject {
        let wrappedCode = wrapEvalString(string:code)
        runSimpleString(wrappedCode)
        let main = pythonImport(name: "__main__")
        return main.call("_swiftpy_eval_wrapper_")
}

public typealias CPyObj = UnsafeMutablePointer<PyObject>

public protocol CPyObjConvertible {
        var cPyObjPtr:CPyObj? {
                get
        }
        @discardableResult func call(_ funcName:String, args:CPyObjConvertible...) -> PythonObject
        func toPythonString() -> PythonString
}

extension CPyObjConvertible {
        @discardableResult public func call(_ funcName:String, args:CPyObjConvertible...) -> PythonObject{
                let pFunc = PyObject_GetAttrString(cPyObjPtr!, funcName)
                guard PyCallable_Check(pFunc) == 1 else { return PythonObject() }
                let pArgs = PyTuple_New(args.count)
                for (idx,obj) in args.enumerated() {
                        let i:Int = idx
                        PyTuple_SetItem(pArgs, i, obj.cPyObjPtr!)
                }
                let pValue = PyObject_CallObject(pFunc, pArgs)
                Py_DecRef(pArgs)
                return PythonObject(ptr: pValue)
        }
        public func toPythonString() -> PythonString {
                runSimpleString("def _swiftpy_to_str_(obj):\n" +
                     "    return str(obj)")
                let main = pythonImport(name: "__main__")
                return PythonString(obj:main.call("_swiftpy_to_str_",args:self))
        }
}

public class PythonString : CPyObjConvertible, CustomStringConvertible, StringLiteralConvertible{
        public let obj:PythonObject

        public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
        public typealias UnicodeScalarLiteralType = StringLiteralType
        public required init(stringLiteral:String) {
                obj = PythonObject(ptr: PyString_FromString(stringLiteral))
        }

        public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
                obj = PythonObject(ptr: PyString_FromString(value))
        }

        public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
                obj = PythonObject(ptr: PyString_FromString("\(value)"))
        }

        init(obj:PythonObject){
                self.obj = obj
        }

        public var cPyObjPtr:CPyObj? { return obj.ptr }
        public var description: String {
                get {
                        let cstr:UnsafePointer<CChar> = UnsafePointer(PyString_AsString(cPyObjPtr)!)
                        return String(cString : cstr)
                }
        }
}

public func pythonImport(name:String) -> PythonObject{
        let module = PyImport_ImportModule(name)
        return PythonObject(ptr:module)
}

//TODO
public func convertCPyObj(cPyObj ptr:CPyObj) -> CPyObjConvertible {
        //NOT impl yet
        return PythonObject(ptr:ptr)
}

public class PythonObject : CustomDebugStringConvertible, CPyObjConvertible {
        let ptr:CPyObj?
        public init() {
                ptr = nil
        }
        init(ptr:CPyObj?) {
                self.ptr = ptr
        }
        public var cPyObjPtr:CPyObj? {
                return ptr
        }


        public var debugDescription: String {
                get {
                        guard let pptr = ptr else { return "nil" }
                        return pptr.debugDescription
                }
        }
}
