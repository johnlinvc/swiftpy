import Python
func initPython(){
  Py_Initialize()
}
func runSimpleString(string: String) {
        PyRun_SimpleStringFlags(string, nil);
}
typealias CPyObj = UnsafeMutablePointer<PyObject>

class PythonString : CustomStringConvertible{
        let obj:PythonObject
        init(stringLiteral:String) {
                obj = PythonObject(ptr: PyString_FromString(stringLiteral))
        }
        var description: String {
                get {
                        let cstr:UnsafePointer<CChar> = UnsafePointer(PyString_AsString(obj.ptr)!)
                        return String(cString : cstr)
                }
        }
}

func pythonImport(name:String) -> PythonObject{
        let module = PyImport_ImportModule(name)
        return PythonObject(ptr:module)
}

class PythonObject :CustomDebugStringConvertible {
        let ptr:CPyObj?
        init() {
                ptr = nil
        }
        init(ptr:CPyObj?) {
                self.ptr = ptr
        }
        var debugDescription: String {
                get {
                        guard let pptr = ptr else { return "nil" }
                        return pptr.debugDescription
                }
        }
        @discardableResult func call(funcName:String, args:PythonObject...) -> PythonObject{
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
