function main ()
    os.exec("pxmake create -P $(tmpdir)/test")
    os.exec("pxmake -P $(tmpdir)/test")
    os.exec("pxmake create -l c++ -P $(tmpdir)/test_cpp")
    os.exec("pxmake -P $(tmpdir)/test_cpp")
    os.exec("pxmake create -l c++ -t 3 -P $(tmpdir)/test_cpp2")
    os.exec("pxmake -P $(tmpdir)/test_cpp2")
end
