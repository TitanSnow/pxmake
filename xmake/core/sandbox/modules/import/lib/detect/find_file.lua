--!The Make-like Build Utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2017, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        find_file.lua
--

-- define module
local sandbox_lib_detect_find_file = sandbox_lib_detect_find_file or {}

-- load modules
local os        = require("base/os")
local path      = require("base/path")
local utils     = require("base/utils")
local table     = require("base/table")
local winreg    = require("base/winreg")
local raise     = require("sandbox/modules/raise")
local vformat   = require("sandbox/modules/vformat")

-- find file
--
-- @param name      the file name
-- @param pathes    the search pathes (.e.g dirs, pathes, winreg pathes)
-- @param opt       the options, .e.g {suffixes = {"/aa", "/bb"}}
--
-- @return          the file path
--
-- @code
--
-- local file = find_file("ccache", { "/usr/bin", "/usr/local/bin"})
-- local file = find_file("test.h", { "/usr/include", "/usr/local/include/**"})
-- local file = find_file("xxx.h", { "$(env PATH)", "$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name)"})
-- local file = find_file("xxx.h", { "$(env PATH)", function () return val("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name"):match("\"(.-)\"") end})
--
-- @endcode
--
function sandbox_lib_detect_find_file.main(name, pathes, opt)

    -- init options
    opt = opt or {}

    -- init pathes
    pathes = table.wrap(pathes)
    
    -- append suffixes to pathes
    local suffixes = table.wrap(opt.suffixes)
    if #suffixes > 0 then
        local pathes_new = {}
        for _, parent in ipairs(pathes) do
            for _, suffix in ipairs(suffixes) do
                table.insert(pathes_new, path.join(parent, suffix))
            end
        end
        pathes = pathes_new
    end

    -- find file
    local result = nil
    for _, _path in ipairs(pathes) do

        -- format path for builtin variables
        if type(_path) == "function" then
            local ok, results = sandbox.load(_path) 
            if ok then
                _path = results or ""
            else 
                raise(results)
            end
        else
            _path = vformat(_path)
        end

        -- get file path
        local filepath = nil
        if os.isfile(_path) then
            filepath = _path
        else
            filepath = path.join(_path, name)
        end

        -- file exists?
        for _, file in ipairs(os.files(filepath)) do
            result = file
            break
        end

        -- found?
        if result then
            break
        end
    end

    -- ok?
    return result
end

-- return module
return sandbox_lib_detect_find_file
