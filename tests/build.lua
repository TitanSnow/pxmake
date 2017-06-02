-- imports
import("privilege.sudo")

-- main entry
function main(argv)

    -- generic?
    os.exec("pxmake m -b")
    os.exec("pxmake f -c")
    os.exec("pxmake")
    if os.host() ~= "windows" then
        os.exec("pxmake install -o /tmp -a --verbose --backtrace")
        os.exec("pxmake uninstall --installdir=/tmp --verbose --backtrace")
    end
    os.exec("pxmake p")
    os.exec("pxmake c")
    os.exec("pxmake f --mode=debug --verbose --backtrace")
    os.exec("pxmake -r -a -v --backtrace")
    os.exec("pxmake p --verbose --backtrace")
    os.exec("pxmake c --verbose --backtrace")
    os.exec("pxmake m -e buildtest")
    os.exec("pxmake m -l")
    os.exec("pxmake f --cc=gcc --cxx=g++")
    os.exec("pxmake m buildtest")
    if sudo.has() then
        sudo.exec("pxmake install")
        sudo.exec("pxmake uninstall")
    end
    os.exec("pxmake f --cc=clang --cxx=clang++ --ld=clang++ --verbose --backtrace")
    os.exec("pxmake m buildtest")
    if sudo.has() then
        sudo.exec("pxmake install --all -v --backtrace")
        sudo.exec("pxmake uninstall -v --backtrace")
    end
    os.exec("pxmake m -d buildtest")

    -- test iphoneos?
    if argv and argv.iphoneos then
        if os.host() == "macosx" then
            os.exec("pxmake m package -p iphoneos")
        end
    end
end
