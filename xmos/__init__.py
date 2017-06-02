from functools import partial
from xmos.argv import xm_os_argv
from xmos.find import xm_os_find
from xmos.uuid import xm_os_uuid
from xmos.isdir import xm_os_isdir
from xmos.rmdir import xm_os_rmdir
from xmos.mkdir import xm_os_mkdir
from xmos.cpdir import xm_os_cpdir
from xmos.chdir import xm_os_chdir
from xmos.mtime import xm_os_mtime
from xmos.curdir import xm_os_curdir
from xmos.tmpdir import xm_os_tmpdir
from xmos.isfile import xm_os_isfile
from xmos.rmfile import xm_os_rmfile
from xmos.cpfile import xm_os_cpfile
from xmos.exists import xm_os_exists
from xmos.setenv import xm_os_setenv
from xmos.emptydir import xm_os_emptydir
from xmos.strerror import xm_os_strerror
from xmos.getwinsize import xm_os_getwinsize
from xmos.versioninfo import xm_os_versioninfo
try:
    from xmos.getown import xm_os_getown
except ImportError:
    pass

def register(lua):
    lua.execute("os = os or {}")
    xmos = lua.globals().os
    xmos.argv = partial(xm_os_argv, lua)
    xmos.find = partial(xm_os_find, lua)
    xmos.uuid = partial(xm_os_uuid, lua)
    xmos.isdir = partial(xm_os_isdir, lua)
    xmos.rmdir = partial(xm_os_rmdir, lua)
    xmos.mkdir = partial(xm_os_mkdir, lua)
    xmos.cpdir = partial(xm_os_cpdir, lua)
    xmos.chdir = partial(xm_os_chdir, lua)
    xmos.mtime = partial(xm_os_mtime, lua)
    xmos.curdir = partial(xm_os_curdir, lua)
    xmos.tmpdir = partial(xm_os_tmpdir, lua)
    xmos.isfile = partial(xm_os_isfile, lua)
    xmos.rmfile = partial(xm_os_rmfile, lua)
    xmos.cpfile = partial(xm_os_cpfile, lua)
    original_rename = xmos.rename
    xmos.rename = lambda *args: True if original_rename(*args) == True else False
    xmos.exists = partial(xm_os_exists, lua)
    xmos.setenv = partial(xm_os_setenv, lua)
    xmos.emptydir = partial(xm_os_emptydir, lua)
    xmos.strerror = partial(xm_os_strerror, lua)
    xmos.getwinsize = partial(xm_os_getwinsize, lua)
    xmos.versioninfo = partial(xm_os_versioninfo, lua)
    try:
        xmos.getown = partial(xm_os_getown, lua)
    except NameError:
        pass
