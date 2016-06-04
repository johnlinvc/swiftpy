import Python
public func initPython(){
  Py_Initialize()
}
public func runSimpleString(string: String) {
        PyRun_SimpleStringFlags(string, nil);
}

public typealias CPyObj = UnsafeMutablePointer<PyObject>

public protocol CPyObjConvertible {
        var cPyObjPtr:CPyObj? {
                get
        }
        @discardableResult func call(funcName:String, args:CPyObjConvertible...) -> PythonObject
}

extension CPyObjConvertible {
        @discardableResult public func call(funcName:String, args:CPyObjConvertible...) -> PythonObject{
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
