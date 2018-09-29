MySQL = {
    Async = {},
    Sync = {}
}

local function safeParameters(params)
    if nil == params then
        return {[''] = ''}
    end

    assert(type(params) == "table", "A table is expected")
    assert(params[1] == nil, "Parameters should not be an array, but a map (key / value pair) instead")

    if next(params) == nil then
        return {[''] = ''}
    end

    return params
end

local function safeCallback(callback)
    if nil == callback then
        return function() end
    end

    assert(type(callback) == "function", "A callback is expected")

    return callback
end

---
-- Execute a query with no result required, sync version
--
-- @param query
-- @param params
--
-- @return int Number of rows updated
--
function MySQL.Sync.execute(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    return exports['mysql-async']:mysql_sync_execute(query, safeParameters(params))
end

---
-- Execute a query and fetch all results in an sync way
--
-- @param query
-- @param params
--
-- @return table Query results
--
function MySQL.Sync.fetchAll(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    return exports['mysql-async']:mysql_sync_fetch_all(query, safeParameters(params))
end

---
-- Execute a query and fetch the first column of the first row, sync version
-- Useful for count function by example
--
-- @param query
-- @param params
--
-- @return mixed Value of the first column in the first row
--
function MySQL.Sync.fetchScalar(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    return exports['mysql-async']:mysql_sync_fetch_scalar(query, safeParameters(params))
end

---
-- Execute a query and retrieve the last id insert, sync version
--
-- @param query
-- @param params
--
-- @return mixed Value of the last insert id
--
function MySQL.Sync.insert(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    return exports['mysql-async']:mysql_sync_insert(query, safeParameters(params))
end

---
-- Execute a query with no result required, async version
--
-- @param query
-- @param params
-- @param func(int)
--
function MySQL.Async.execute(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_execute(query, safeParameters(params), safeCallback(func))
end

---
-- Execute a query and fetch all results in an async way
--
-- @param query
-- @param params
-- @param func(table)
--
function MySQL.Async.fetchAll(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_fetch_all(query, safeParameters(params), safeCallback(func))
end

---
-- Execute a query and fetch the first column of the first row, async version
-- Useful for count function by example
--
-- @param query
-- @param params
-- @param func(mixed)
--
function MySQL.Async.fetchScalar(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_fetch_scalar(query, safeParameters(params), safeCallback(func))
end

---
-- Execute a query and retrieve the last id insert, async version
--
-- @param query
-- @param params
-- @param func(string)
--
function MySQL.Async.insert(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_insert(query, safeParameters(params), safeCallback(func))
end

local isReady = false

AddEventHandler('onMySQLReady', function()
    isReady = true
end)

function MySQL.ready(callback)
    if isReady then
        callback()

        return
    end

    AddEventHandler('onMySQLReady', callback)
end

TriggerEvent('esx:getSharedObject', function(ESX)
	ESX.RegisterServerCallback('mysql-async:execute', function(source, callback, query, params)
		MySQL.Async.execute(tostring(query), params, function(result)
			callback(result)
		end)
	end)

	ESX.RegisterServerCallback('mysql-async:fetchAll', function(source, callback, query, params)
		MySQL.Async.fetchAll(tostring(query), params, function(result)
			callback(result)
		end)
	end)

	ESX.RegisterServerCallback('mysql-async:fetchScalar', function(source, callback, query, params)
		MySQL.Async.fetchScalar(tostring(query), params, function(result)
			callback(result)
		end)
	end)

	ESX.RegisterServerCallback('mysql-async:insert', function(source, callback, query, params)
		MySQL.Async.insert(tostring(query), params, function(result)
			callback(result)
		end)
	end)

	ESX.RegisterServerCallback('mysql-async:sync:execute', function(source, callback, query, params)
		callback(MySQL.Sync.execute(tostring(query), params))
	end)

	ESX.RegisterServerCallback('mysql-async:sync:fetchAll', function(source, callback, query, params)
		callback(MySQL.Sync.fetchAll(tostring(query), params))
	end)

	ESX.RegisterServerCallback('mysql-async:sync:fetchScalar', function(source, callback, query, params)
		callback(MySQL.Sync.fetchScalar(tostring(query), params))
	end)

	ESX.RegisterServerCallback('mysql-async:sync:insert', function(source, callback, query, params)
		callback(MySQL.Sync.insert(tostring(query), params))
	end)
end)