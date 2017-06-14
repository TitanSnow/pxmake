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
-- @file        find_package.lua
--

-- define module
local sandbox_lib_detect_find_package = sandbox_lib_detect_find_package or {}

-- load modules
local os                = require("base/os")
local path              = require("base/path")
local utils             = require("base/utils")
local table             = require("base/table")
local option            = require("base/option")
local cache             = require("project/cache")
local project           = require("project/project")
local raise             = require("sandbox/modules/raise")
local import            = require("sandbox/modules/import")
local find_file         = import("lib.detect.find_file")
local find_library      = import("lib.detect.find_library")
local pkg_config        = import("lib.detect.pkg_config")

-- find package from repositories
function sandbox_lib_detect_find_package._find_from_repositories(name, opt)

    -- TODO in repo branch
end

-- find package from modules (detect.package.find_xxx)
function sandbox_lib_detect_find_package._find_from_modules(name, opt)

    -- "detect.package.find_xxx" exists?
    if os.isfile(path.join(os.programdir(), "modules", "detect", "package", "find_" .. name .. ".lua")) then
        local find_package = import("detect.package.find_" .. name, {anonymous = true})
        if find_package then
            return find_package(opt)
        end
    end
end

-- find package from system
function sandbox_lib_detect_find_package._find_from_system(name, opt)

    -- init links and pathes
    local links  = opt.links or {}
    local pathes = opt.pathes or {}

    -- attempt to add search pathes from pkg-config
    local pkginfo = pkg_config.find(name, {version = true})
    if not pkginfo and not name:startswith("lib") then
        pkginfo = pkg_config.find("lib" .. name, {version = true})
    end
    if pkginfo then
        table.join2(links, pkginfo.links)
        table.join2(pathes, pkginfo.linkdirs)
        table.join2(pathes, pkginfo.includedirs)
    end

    -- find library 
    local result = nil
    for _, link in ipairs(links) do
        local libinfo = find_library(link, pathes)
        if libinfo then
            result          = result or {}
            result.links    = table.join(result.links or {}, libinfo.link)
            result.linkdirs = table.join(result.linkdirs or {}, libinfo.linkdir)
        end
    end
    if result and result.linkdirs then
        result.linkdirs = table.unique(result.linkdirs)
    end

    -- save version and includedirs if exists
    if pkginfo and result then
        result.version = pkginfo.version
        result.includedirs = table.join(result.includedirs or {}, pkginfo.includedirs)
    end

    -- ok
    return result
end

-- find package
function sandbox_lib_detect_find_package._find(name, opt)

    -- init find scripts
    local findscripts = 
    {
        sandbox_lib_detect_find_package._find_from_repositories
    ,   sandbox_lib_detect_find_package._find_from_modules
    ,   sandbox_lib_detect_find_package._find_from_system
    }

    -- find it, TODO match version
    opt = opt or {}
    for _, find in ipairs(findscripts) do
        local package = find(name, opt)
        if package then
            return package
        end
    end
end

-- find package 
--
-- @param name      the package name
-- @param opt       the package options. e.g. {version = ">1.0.1", pathes = {"/usr/lib"}, links = {"ssl"}, includes = {"ssl.h"}}
--
-- @return          {links = {"ssl", "crypto", "z"}, linkdirs = {"/usr/local/lib"}, includedirs = {"/usr/local/include"}, version = "1.0.2"}
--
-- @code 
--
-- local package = find_package("openssl")
-- local package = find_package("openssl", {version = ">1.0.1"})
-- local package = find_package("openssl", {pathes = {"/usr/lib", "/usr/local/lib", "/usr/local/include"}, version = ">1.0.1"})
-- local package = find_package("openssl", {pathes = {"/usr/lib", "/usr/local/lib", "/usr/local/include"}, links = {"ssl", "crypto"}, includes = {"ssl.h"}})
-- 
-- @endcode
--
function sandbox_lib_detect_find_package.main(name, opt)

    -- get detect cache 
    local detectcache = cache(utils.ifelse(os.isfile(project.file()), "local.detect", "memory.detect"))
 
    -- attempt to get result from cache first
    local cacheinfo = detectcache:get("find_package") or {}
    local result = cacheinfo[name]
    if result ~= nil then
        return utils.ifelse(result, result, nil)
    end

    -- find package
    result = sandbox_lib_detect_find_package._find(name, opt) 

    -- cache result
    cacheinfo[name] = utils.ifelse(result, result, false)

    -- save cache info
    detectcache:set("find_program", cacheinfo)
    detectcache:flush()

    -- trace
    if option.get("verbose") then
        if result then
            utils.cprint("checking for the %s ... ${green}ok", name)
        else
            utils.cprint("checking for the %s ... ${red}no", name)
        end
    end

    -- ok?
    return result
end

-- return module
return sandbox_lib_detect_find_package
