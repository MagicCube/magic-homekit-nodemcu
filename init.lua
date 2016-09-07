stop = false

WIFI_SSID = "Henry's Living Room 2.4GHz";
WIFI_PWD = "13913954971";

print("***************************")
print("* Hello from MaigcHomekit *")
print("***************************")

require("server")

print("Run main() in 5 seconds...")
tmr.alarm(1, 5000, tmr.ALARM_SINGLE, function()
    if stop == false then
        main()
    end
end)

function main()
    joinAP();
end

function startup()
    restartServer()
    print("HTTP RESTful service started.")
    tmr.stop(2)
    updateTemperatureAndHumidity()
    tmr.alarm(2, 10000, tmr.ALARM_AUTO, updateTemperatureAndHumidity)
end

function joinAP()
    connectToAP(WIFI_SSID, WIFI_PWD)
    print("Connecting to WIFI...");
    tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
        if getWifiStatus() == 2 then
            print("Fail to join the AP: Wrong password.")
            tmr.stop(1)
        elseif getWifiStatus() == 3 then
            print("Fail to join the AP: SSID not found.")
            tmr.stop(1)
        elseif getWifiStatus() == 4 then
            print("Fail to join the AP: Fail to join the AP.")
            tmr.stop(1)
        elseif getWifiStatus() == 5 then
            print("Successfully join the AP.")
            print("IP address: " .. getIP())
            tmr.stop(1)
            if stop == false then
                startup()
            end
        else
            print("...")
        end
    end)
end

function getTemperatureAndHumidity()
    pin = 4
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        return { temperature = temp, humidity = humi }
    elseif status == dht.ERROR_CHECKSUM then
        return nil
    elseif status == dht.ERROR_TIMEOUT then
        return nil
    end
    return nil
end

function updateTemperatureAndHumidity()
    if stop == false then
        result = getTemperatureAndHumidity()
        if result ~= nil then
            print("Temperature = " .. result.temperature .. ", Humidity = " .. result.humidity);
            setValue("temperature", result.temperature)
            setValue("humidity", result.humidity)
        end
    else
        tmr.stop(2)
    end
end
