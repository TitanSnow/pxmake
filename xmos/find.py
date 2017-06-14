import os
from os import path
from xmtrace import xmtrace
from xmerrno import set_errno
from xmbase import pathjoin

@xmtrace
def xm_os_find(lua, rootdir, pattern, recurse, mode, excludes = None):
    rootdir = path.expanduser(rootdir)
    excludes = list(excludes.values()) if excludes != None else []
    lgl = lua.globals()
    def judge(phs):
        res = []
        for ph in phs:
            if mode == 1 and path.isdir(ph) or mode == 0 and path.isfile(ph) or mode not in (0, 1):
                if ph.startswith("./"):
                    ph = ph[2:]
                match = lgl.string.match
                if ph == match(ph, pattern):
                    rootlen = len(rootdir)
                    assert(rootdir != ph)
                    assert(rootlen + 1 <= len(ph))
                    if rootdir != ".":
                        phtk = ph[rootlen + 1:]
                    else:
                        phtk = ph
                    excluded = False
                    for exclude in excludes:
                        if match(phtk, exclude) == phtk:
                            excluded = True
                            break
                    if not excluded:
                        res.append(ph)
        return res
    try:
        if not recurse:
            res = judge([pathjoin(rootdir, nm) for nm in os.listdir(rootdir)])
        else:
            tree = []
            for (dirpath, dirnames, filenames) in os.walk(rootdir):
                tree += [pathjoin(dirpath, nm) for nm in dirnames + filenames]
            res = judge(tree)
    except OSError as e:
        set_errno(e.errno)
        return lua.table(), 0
    return lua.table(*res), len(res)
