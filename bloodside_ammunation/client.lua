ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(ConfAmmu.Pos) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)

		SetBlipSprite(blip, 110)
		SetBlipScale (blip, 0.75)
		SetBlipColour(blip, 59)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('~r~Armurerie |~s~Armes')
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
    local hash = GetHashKey("s_m_y_ammucity_01")
    while not HasModelLoaded(hash) do
    RequestModel(hash)
    Wait(20)
	end
	for k,v in pairs(ConfAmmu.AmmuPed) do
	ped = CreatePed("PED_TYPE_CIVMALE", "s_m_y_ammucity_01", v.x, v.y, v.z, v.a, false, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
	end
end)

ppa = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())

		for k, v in pairs(ConfAmmu.Pos) do
			local distance = GetDistanceBetweenCoords(playerCoords, v.x, v.y, v.z, true)

            if distance < 10.0 then
                actualZone = v

                zoneDistance = GetDistanceBetweenCoords(playerCoords, actualZone.x, actualZone.y, actualZone.z, true)

				DrawMarker(21, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.4, 10, 10, 255, 100, false, true, 2, false, nil, nil, false)
            end

            if distance <= 1.5 then
				RageUI.Text({
					message = "Appuyez sur [~b~E~w~] pour ouvrir l'armurerie",
					time_display = 1
				})

                if IsControlJustPressed(1, 51) then
                    RageUI.Visible(RMenu:Get('inspecteur_armurerie', 'main'), not RageUI.Visible(RMenu:Get('inspecteur_armurerie', 'main')))
                end
            end

            if zoneDistance ~= nil then
                if zoneDistance > 1.5 then
                    RageUI.CloseAll()
                end
            end
        end

	end
end)

RMenu.Add('inspecteur_armurerie', 'main', RageUI.CreateMenu("Ammunation", "Armurerie"))
RMenu.Add('inspecteur_armurerie', 'armurerie', RageUI.CreateSubMenu(RMenu:Get('inspecteur_armurerie', 'main'), "Armurerie", "Voici nos armes blanche."))
RMenu.Add('inspecteur_armurerie', 'arme', RageUI.CreateSubMenu(RMenu:Get('inspecteur_armurerie', 'main'), "Armurerie", "Voici nos armes à feu."))
RMenu.Add('inspecteur_armurerie', 'aces', RageUI.CreateSubMenu(RMenu:Get('inspecteur_armurerie', 'main'), "Armurerie", "Voici nos accessoires."))
RMenu.Add('inspecteur_armurerie', 'ppa', RageUI.CreateSubMenu(RMenu:Get('inspecteur_armurerie', 'main'), "Armurerie", "Confirmation"))

Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('inspecteur_armurerie', 'main'), true, true, true, function()

            RageUI.ButtonWithStyle("Armes blanche", "Pour accéder aux armes blanche.", {RightLabel = "→"},true, function()
            end, RMenu:Get('inspecteur_armurerie', 'armurerie'))

			ESX.TriggerServerCallback('e_weaponshop:checkLicense', function(cb)
                if cb then
                    ppa = true
                	else
                 	ppa = false
                end
              end)

              if ppa then
              RageUI.ButtonWithStyle("Armes à feu", "Pour accéder aux armes à feu.", { RightLabel = "→" }, true, function(Hovered, Active, Selected)
                if (Selected) then

                end
              end, RMenu:Get('inspecteur_armurerie', 'arme'))

              else

                RageUI.ButtonWithStyle("Armes à feu", "Pour accéder aux armes à feu.", { RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                    if (Selected) then
                    end
                  end)

                end

			RageUI.ButtonWithStyle("Accessoires", "Pour accéder aux accessoires.", {RightLabel = "→"},true, function()
            end, RMenu:Get('inspecteur_armurerie', 'aces'))

            if ppa then

                RageUI.ButtonWithStyle("Acheter le P.P.A", "Vous avez le PPA.", { RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                    if (Selected) then
                    end
                  end)

                else

			RageUI.ButtonWithStyle("Acheter le P.P.A", "Permet de débloquer les armes à feu", {RightLabel = "~g~75,000$"},true, function()
            end, RMenu:Get('inspecteur_armurerie', 'ppa'))


        end


        end, function()
        end)

		RageUI.IsVisible(RMenu:Get('inspecteur_armurerie', 'ppa'), true, true, true, function()

                RageUI.ButtonWithStyle("Confirmer", nil, { }, true, function(Hovered, Active, Selected)
                    if Selected then
						local prix = 50000
						TriggerServerEvent('Eweapon:addppa', 'weapon')
						RageUI.GoBack()
                    end
                end)

				RageUI.ButtonWithStyle("~r~Annuler", nil, { }, true, function(Hovered, Active, Selected)
                    if Selected then
						RageUI.GoBack()
                    end
                end)

        end, function()
        end)

        RageUI.IsVisible(RMenu:Get('inspecteur_armurerie', 'armurerie'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Blanche) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('weaponshops:giveWeapon', v)
                    end
                end)
            end

        end, function()
        end)

		RageUI.IsVisible(RMenu:Get('inspecteur_armurerie', 'arme'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Armes) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('weaponshops:giveWeapon', v)
                    end
                end)
            end

        end, function()
        end)

        RageUI.IsVisible(RMenu:Get('inspecteur_armurerie', 'aces'), true, true, true, function()

            for k, v in pairs(ConfAmmu.Type.Items) do
                RageUI.ButtonWithStyle(v.Label, nil, {RightLabel = "~g~"..v.Price.."$"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent('item:acheter', v)
                    end
                end)
            end

        end, function()
        end)

        Citizen.Wait(0)
    end
end)
