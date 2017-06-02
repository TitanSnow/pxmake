function main()
    os.exec("pxmake")
    if os.host() == "macosx" then
        os.exec("pxmake f -p iphoneos")
        os.exec("pxmake")
        os.exec("pxmake f -p iphoneos -a arm64")
        os.exec("pxmake")
    end
end
