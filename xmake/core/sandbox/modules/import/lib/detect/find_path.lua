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
-- @file        find_path.lua
--

-- define module
local sandbox_lib_detect_find_path = sandbox_lib_detect_find_path or {}

-- load modules
local os        = require("base/os")
local path      = require("base/path")
local table     = require("base/table")
local raise     = require("sandbox/modules/raise")

-- find path
--
-- @param name      the path name
-- @param pathes    the program pathes (.e.g dirs, pathes, winreg pathes)
--
-- @return          the path
--
-- @code
--
-- local p = find_path("include/test.h", { "/usr", "/usr/local"})
-- local p = find_path("include/*.h", { "/usr", "/usr/local/**"})
--
-- @endcode
--
function sandbox_lib_detect_find_path.main(name, pathes)

    -- find file
    local result = nil
    for _, _path in ipairs(table.wrap(pathes)) do

        -- handle winreg value .e.g [HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\XXXX;Name]\\dir\\file
        _path = _path:gsub("%[(.*)%]", function (regpath)

            -- get registry value
            local value, errors = winreg.query(regpath)
            if not value then
                utils.verror(errors)
            end

            -- file path not exists? attempt to parse path from `"path" xxx`
            if value and not os.exists(value) then
                value = value:match("\"(.-)\"")
            end

            -- ok
            return value
        end)

        -- get file path
        local filepath = nil
        if os.isfile(_path) then
            filepath = _path
        elseif os.isdir(_path) then
            filepath = path.join(_path, name)
        end

        -- path exists?
        if filepath then
            for _, p in ipairs(os.filedirs(filepath)) do
                result = p
                break
            end
        end
    end

    -- ok?
    return result
end

-- return module
return sandbox_lib_detect_find_path
