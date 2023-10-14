ads = {}
ads.count = 0
ads.count_reset = 60
ads.count_hide_reset = 20
ads.count_hide = ads.count_hide_reset

ads.id_banner = "ca-app-pub-7363433497567386/4784351490"
-- "ca-app-pub-7363433497567386/4784351490"
ads.id_interstitial = "ca-app-pub-7363433497567386/4896707180"
-- "ca-app-pub-7363433497567386/4896707180"
ads.enable = true


function ads:Initialize()
    if love.system.getOS() == "Android" then
        love.ads.createBanner(ads.id_banner,"top")
    end
end

function ads:update(dt)
    if love.system.getOS() == "Android" then
        if ads.count <= 0 then
            if love.ads.isInterstitialLoaded() and gameState ~= 1 then
                love.ads.showInterstitial()
            end
            ads.enable = true
            ads.count = ads.count_reset
        else
            ads.count = ads.count - dt
        end

        if ads.count_hide <= 0 then
            love.ads.hideBanner()
        else
            ads.count_hide = ads.count_hide - dt
        end
    end
end

function ads:show()
    if love.system.getOS() == "Android" then
        if ads.enable == true then
            ads.enable = false
            love.ads.showBanner()
            love.ads.requestInterstitial(ads.id_interstitial)
            ads.count_hide = ads.count_hide_reset
        end
    end
end

ads:Initialize()

return ads
