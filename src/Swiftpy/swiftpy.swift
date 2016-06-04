import Python
public func initPython(){
  Py_Initialize()
}
public func runSimpleString(string: String) {
        PyRun_SimpleStringFlags(string, nil);
}
typealias CPyObj = UnsafeMutablePointer<PyObject>

public class PythonString : CustomStringConvertible{
        public let obj:PythonObject
        public init(stringLiteral:String) {
                obj = PythonObject(ptr: PyString_FromString(stringLiteral))
        }
        public var description: String {
                get {
                        let cstr:UnsafePointer<CChar> = UnsafePointer(PyString_AsString(obj.ptr)!)
                        return String(cString : cstr)
                }
        }
}

public func pythonImport(name:String) -> PythonObject{
        let module = PyImport_ImportModule(name)
        return PythonObject(ptr:module)
}

public class PythonObject :CustomDebugStringConvertible {
        let ptr:CPyObj?
        public init() {
                ptr = nil
        }
        init(ptr:CPyObj?) {
                self.ptr = ptr
        }
        public var debugDescription: String {
                get {
                        guard let pptr = ptr else { return "nil" }
                        return pptr.debugDescription
                }
        }
        @discardableResult public func call(funcName:String, args:PythonObject...) -> PythonObject{
                let pFunc = PyObject_GetAttrString(ptr!, funcName)
                guard PyCallable_Check(pFunc) == 1 else { return PythonObject() }
                let pArgs = PyTuple_New(args.count)
                for (idx,obj) in args.enumerated() {
                        let i:Int = idx
                        PyTuple_SetItem(pArgs, i, obj.ptr)
                }
                let pValue = PyObject_CallObject(pFunc, pArgs)
                Py_DecRef(pArgs)
                return PythonObject(ptr: pValue)
        }
}
