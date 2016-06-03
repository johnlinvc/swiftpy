import Python
func initPython(){
  Py_Initialize()
}
func runSimpleString(string: String) {
        PyRun_SimpleStringFlags(string, nil);
}
