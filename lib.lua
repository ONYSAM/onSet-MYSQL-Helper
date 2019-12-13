_G.wherec = nil
_G.rowC = {}

function where(clausArry)
         clause = ""
         first = 0

         if type(clausArry) == "table" then
             --print(clausArry.length)
             --print("############### TABLE  START ###############")
             for key,value in next,clausArry,nil do
               -- print(key,value)

               if first > 0 then
                    clause = clause.. " AND "..key.."='"..value.."'"
               else
                    clause = clause..key.."='"..value.."' "
               end


                first = first+1
             end
             -- print("############### TABLE  END ###############")
         else
            return nil
         end
         _G.wherec = clause


end
function delete(table)
    if _G.wherec == nil then 
        clause = 'DELETE FROM' ..table
        print(" [DEBUG CLAUSE] "..clause)

        local result = mariadb_await_query(_G.db, clause..";")

        mariadb_delete_result(result)
        return true;
    elseif type(table) == "string" and _G.wherec ~= nil then
         clause = 'DELETE FROM ' ..table.." WHERE ".._G.wherec
         print(" [DEBUG CLAUSE] "..clause)

         local result = mariadb_await_query(_G.db, clause..";")

         mariadb_delete_result(result)
         return true;

     else
        return false
     end
end
function insert(table, values)
    if type(values) == "table" then

        first = 0
        last = 0
        for _ in pairs(values) do last = last + 1 end
        valuekeys_set = "("
        insetvals_set = "("
        clause = "INSERT INTO ".. table
        for key,value in next,values,nil do

            
            if first+1 == last then 
                valuekeys_set = valuekeys_set.."`"..key.."`"..")"
            else 
                valuekeys_set = valuekeys_set.."`"..key.."`"..","
            end 

            if first+1 == last then 
                insetvals_set = insetvals_set.."'"..value.."'"..")"
            else 
                insetvals_set = insetvals_set.."'"..value.."'"..","
            end 

             first = first+1
        end
        clause = clause.." ".. valuekeys_set .. " VALUES ".. insetvals_set
        local result = mariadb_await_query(_G.db, clause..";")
        
    else
        return nil
    end
end

function get(table, --[[optional]]select)

    if select == nil then
        select = "*"
    end


     if type(select) == "string" and _G.wherec == nil then
        clause = 'SELECT '..select.." FROM "..table

     elseif type(select) == "string" and _G.wherec ~= nil then
         clause = 'SELECT '..select.." FROM "..table.." WHERE ".._G.wherec
         print(" [DEBUG CLAUSE] "..clause)

         local result = mariadb_await_query(_G.db, clause..";")
         if mariadb_get_row_count() ~= 0 then
            row = mariadb_get_assoc(result);
            print("mariadb_get_value_index: "..mariadb_get_value_index(1, 1))
         end
         mariadb_delete_result(result)
         return row;

     else
        return false
     end
end

--what = {
--    ['id'] = 6,
--    ['steam_id'] = "1231321321313"
--}
--where(what)
--print(_G.wherec);
--getPlayerData = get("players")

--print("GPD: " ..getPlayerData)
--print("############### DEBUG getPlayerData START ###############")
--for key,value in next,getPlayerData,nil do
--    print("KEY: ".. key .. " VALUE: " .. value)
--end
--print("############### DEBUG getPlayerData ENDED ###############")


--vuls = {
--    ['steam_id'] = "123156456445623321",
--    ['name'] = 'HansPeter Wurst'
--}

--insert("players", vuls)
--vuls = {
--    ['steam_id'] = "123156456445623321",
--    ['name'] = 'HansPeter Wurst'
--}
--where(vuls)
--delete("players")


AddFunctionExport("get", get)
AddFunctionExport("where", where)
AddFunctionExport("insert", insert)
AddFunctionExport("delete", delete)