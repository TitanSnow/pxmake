# pxmake
xmake implement on python focuses on reuse python's library and API compatibility

<table><tr><td>linux</td><td>osx</td><td>windows</td></tr><tr><td><a href="https://travis-ci.org/TitanSnow/pxmake"><img alt="Build Status" src="https://travis-ci.org/TitanSnow/pxmake.svg?branch=dev"/></a></td><td><a href="https://travis-ci.org/TitanSnow/pxmake"><img alt="Build Status" src="https://travis-ci.org/TitanSnow/pxmake.svg?branch=build_on_mac"/></a></td><td><a href="https://ci.appveyor.com/project/TitanSnow/pxmake/branch/dev"><img alt="Build Status" src="https://ci.appveyor.com/api/projects/status/otk5ccqm048qqhex/branch/dev?svg=true"/></a></td></table>

[![codecov](https://codecov.io/gh/TitanSnow/pxmake/branch/dev/graph/badge.svg)](https://codecov.io/gh/TitanSnow/pxmake)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/4807330a0fcf4fc8b54a59a0455a8cc8)](https://www.codacy.com/app/TitanSnow/pxmake?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=TitanSnow/pxmake&amp;utm_campaign=Badge_Grade)
[![LICENSE](https://img.shields.io/badge/LICENSE-Apache--2.0-blue.svg)](LICENSE.md)

## Intro

[xmake](https://github.com/tboox/xmake) is a make-like build utility based on Lua. Its low-level API (xmake machine) is implemented in C with library [tbox](https://github.com/tboox/tbox)

This repo, *pxmake*, is the reimplement of xmake machine on Python. Notice that the main part is still written in Lua and is same as xmake

pxmake created because to extend API for xmake in C is a little matter. pxmake focuses on reuse python's library and API compatibility with xmake

## Install

```console
$ python3 setup.py install
```

### Common install problems

Generic build steps could be found at [.travis.yml](.travis.yml) & [.appveyor.yml](.appveyor.yml)

#### Python version

*Not support python2.* At least python 3.3 with *setuptools (pip)* is required but newest version is recommanded especially on Windows

#### lupa build fails

See [lupa/INSTALL.rst#building-with-luajit2](https://github.com/scoder/lupa/blob/master/INSTALL.rst#building-with-luajit2)

#### Run fails

* Do not install from wheel or sdist. Directly install or install from egg. This is because the path of installed `data_files` is vary in other ways
* lupa *must bind with luajit,* not lua. It's not matter whether JIT is enabled (no big diff on speed) but it must be luajit
