import Python

public func initPython(){
  Py_Initialize()
}

public func evalStatement(_ string: String) {
        PyRun_SimpleStringFlags(string, nil);
}

public func call(_ code: String, args:CPyObjConvertible...) -> PythonObject {
        let main = pythonImport(name: "__main__")
        return main.call(code, args: args)
}

func wrapEvalString( string : String) -> String {
        return "def _swiftpy_eval_wrapper_():\n" +
               "    result = \(string)\n" +
               "    return result"
}

//TODO handle def case
public func eval(_ code:String) -> PythonObject {
        let wrappedCode = wrapEvalString(string:code)
        evalStatement(wrappedCode)
        let main = pythonImport(name: "__main__")
        return main.call("_swiftpy_eval_wrapper_")
}

public typealias CPyObj = UnsafeMutablePointer<PyObject>

public protocol CPyObjConvertible : CustomStringConvertible {
        var cPyObjPtr:CPyObj? { get }
        var description:String { get }
        //TODO test the case of method with self
        @discardableResult func call(_ funcName:String, args:CPyObjConvertible...) -> PythonObject
        @discardableResult func call(_ funcName:String, args:[CPyObjConvertible]) -> PythonObject
        func toPythonString() -> PythonString
        func attr(_ name:String) -> PythonObject
        func setAttr(_ name:String, value:CPyObjConvertible)
}

extension CPyObjConvertible {
        @discardableResult public func call(_ funcName:String, args:CPyObjConvertible...) -> PythonObject{
                return call(funcName, args:args)
        }
        @discardableResult public func call(_ funcName:String, args:[CPyObjConvertible]) -> PythonObject {
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
                let ptr = PyObject_Str(cPyObjPtr!)
                return PythonString(obj:PythonObject(ptr:ptr))
        }

        public func attr(_ name:String) -> PythonObject {
                guard PyObject_HasAttrString(cPyObjPtr!, name) == 1 else {return PythonObject()}
                return PythonObject(ptr:PyObject_GetAttrString(cPyObjPtr!, name))
        }

        public func setAttr(_ name:String, value:CPyObjConvertible) {
                PyObject_SetAttrString(cPyObjPtr!, name, value.cPyObjPtr!)
        }

        public var description: String {
                let pyString = toPythonString()
                let cstr:UnsafePointer<CChar> = UnsafePointer(PyString_AsString(pyString.cPyObjPtr!)!)
                return String(cString : cstr)
        }

}

public class PythonInt : CPyObjConvertible, IntegerLiteralConvertible {
        public let obj:PythonObject
        public typealias IntegerLiteralType = Int
        public required init(integerLiteral value: IntegerLiteralType){
                obj = PythonObject(ptr:PyInt_FromLong(value))
        }
        public var cPyObjPtr:CPyObj? { return obj.ptr }
}

public class PythonString : CPyObjConvertible, StringLiteralConvertible{
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
