# <img src="https://raw.githubusercontent.com/nyirsh/KTUI/main/Resources/Thumb.png" width="50px" height="50px"> KT Command Node UI Extender
Kill Team Command Node UI Extender - A tool to improve KT Command Node UI experience

If you like this mod, please consider supporting me and the people I worked with. Everything I did is open source for people to use or take inspiration from, completely for free in my own free time. Thank you very much for using my mod whether you decide to buy me a coffee or not.

<a href="https://www.buymeacoffee.com/nyirsh"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=nyirsh&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>

## Contents
How to use the mod:
* [Prepare miniatures](#prepare-miniatures)
* [Increase and decrease wounds](#increase-and-decrease-wounds)
* [Change orders](#change-orders)
* [Interacting with tokens](#interacting-with-tokens)
* [Save and load positions](#save-and-load-positions)
* [Display ranges](#display-ranges)
* [Attack with weapons](#attack-with-weapons)

How to create tokens:
* [One-sided tokens](#one-sided-tokens)
* [One-sided advanced tokens](#one-sided-advanced-tokens)
* [Simple equipment tokens](#simple-equipment-tokens)
* [Two-sided tokens](#two-sided-tokens)
* [Bundling tokens together](#bundling-tokens-together)

Other stuff:
* [Credits](#credits)
* [Reserved names](#reserved-names)
* [Order tokens](#order-tokens)

--------------------------------------
# How to use the mod

## Prepare the miniatures
After you prepared your roster using [KT Command Node](https://steamcommunity.com/sharedfiles/filedetails/?id=2614731381&searchtext=Command+node), import it to a table that has the `KT UI Extender Mat` on it, place your miniatures on top and click on `Extend KT UI`. You don't have to save the newly processed roster if you don't want to, in fact, you can import the mat yourself on any table and re-extend the miniatures every single time which is also the way to update the models with new functionalities in case of need.

## Increase and decrease wounds
By clicking on the health bar of any miniature, you can toggle `+` and `-` buttons to appear/disapper. You can use those buttons to adjust your miniature's health. A wound token will also be automatically be displayed if your model has less than half remaing health.

## Change orders
You have access to several ways to change the orders on your miniatures, just use the ones you prefer:
* Left click on the token itself to swap between `Ready` / `Activated` states
* Right click on the token to swap between `Engage` / `Conceal` orders while keeping the active status
* Right click on the miniature and click on either `Engange` or `Conceal` to assign that `Ready` order to the miniature
* If you have imported the `KT UI Extender Mat` on the table, by putting any number of miniatures on it and clicking on either `All Engage` or `All Conceal`. Only the miniatures currently on the mat will be affected

## Interacting with tokens
## Save and load positions

## Display ranges
Hover your mouse over a miniature and start typing numbers to display a `circular range` of your choise around the miniature. For example, if you type `5` you'll see a `5"` circle around your miniature.
If a miniature is already displaying a range, if you type the same number again it will briefly show you a `spherical range` around the miniature, useful to check distances between objects on different heights. You can do this any amount of times.
By pressing `R` instead of a number, you'll make the miniature display a `1"`, `2"`, `3"` and `6"` `circular ranges`
To stop showing ranges, just press `0`.
`PLEASE BE AWARE: you can only use the numbers of your keyboard that are above the letters, the numpad is not supported.`

## Attack with weapons
Right click on a miniature and you'll see an amount of menus accordingly to the amount of weapons that model has, they're all marked as either `M` or `R` to show if they're Melee or Ranged weapons. By doing so a message will be displayed in chat with your intention and the dice roller will also automatically perform the roll for you -whenever the new roller will be implemented into the base table

--------------------------------------
# How to create tokens

## One-sided tokens
* Spawn a `Token` item (`Objects > Components > Custom > Token`)
* If you want the miniature to count how many tokens of the same kind have been applied to it, check the `Stackable` option
* Add the url of the token's `Image` and click on `Import`
* Right click on the newly created token then access the `Tags` menu voice and add a new tag called `KTUITokenSimple` or highlight it from the list if already present
* Right click on the token add give it a unique description that doesn't contain any spaces or new lines and nothing else. Please refer to [Reserved names](#reserved-names) to check a list of already reserved names
* You can also give it a fancy name but it's not mandatory
```
Name: Minus 1
Description: Minus_1_blue
```

## One-sided advanced tokens
* Spawn a `Token` item (`Objects > Components > Custom > Token`)
* If you want the miniature to count how many tokens of the same kind have been applied to it, check the `Stackable` option
* Add the url of the token's `Image` and click on `Import`
* Right click on the newly created token then access the `Tags` menu voice and add a new tag called `KTUITokenAdvanced` or highlight it from the list if already present
* Right click on the token and go under `Scripting > Scripting Editor`, then copy the whole [SingleSidedAdvancedToken.lua](https://github.com/nyirsh/KTUI/blob/main/Scripts/SingleSidedAdvancedToken.lua) and paste it into your model's script.
* In the first lines of the script change the values of both `face_settings` to match your token's visuals

`name`: a unique description that doesn't contain any spaces or new lines and nothing else. Please refer to [Reserved names](#reserved-names) to check a list of already reserved names

`url`: url of the image used to represent the token's face

`removable`: if set to `false`, after being attached to the miniature it can't be removed by any means (useful for permanent equipments)

`stackable`: if set to `true`, the miniature will count how many tokens of the same kind have been applied to it

`secret`: if set to `true` makes the token only visible to the miniature's owner, after being applied to it, until it is clicked on. Useful for secret roles specific tokens (ie. Interloper). It will also override `removable`, `stackable` and `equipment` to `false`.

`equipment`: if set to `true` makes the token will be considered as an equipment one. It will also override `stackable` to `false`.

## Simple equipment tokens
* Spawn a `Token` item (`Objects > Components > Custom > Token`)
* Add the url of the token's `Image` and click on `Import`
* Right click on the newly created token then access the `Tags` menu voice and add a new tag called `KTUITokenEquipment` or highlight it from the list if already present
* Right click on the token add give it a unique description that doesn't contain any spaces or new lines and nothing else. Please refer to [Reserved names](#reserved-names) to check a list of already reserved names
* You can also give it a fancy name but it's not mandatory
```
Name: Climbing Rope
Description: Kommando_EQ_Climbing_Rope
```
Please be aware that any token created with this method will have the `removable` parameter automatically set to `false`, it is therefore better to use an [One-sided advanced tokens](#one-sided-advanced-tokens) if you're creating a "Limited" kind of equipment.

## Two-sided tokens
Please refrain from creating tokens this way if you're not familiar on how to import custom models or how the TTS scripts work
* Import your token's `Custom Model` to TTS (please refer to guides on how to create and import your own custom models)
* Right click on the newly created token then access the `Tags` menu voice and add a new tag called `KTUITokenAdvanced` or highlight it from the list if already present
* Right click on the token and go under `Scripting > Scripting Editor`, then copy the whole [TwoSidedToken.lua](https://github.com/nyirsh/KTUI/blob/main/Scripts/TwoSidedToken.lua) and paste it into your model's script.
* In the first lines of the script change the values of both `face_up_settings` and `face_down_settings` to match your token's visuals

`name`: a unique description that doesn't contain any spaces or new lines and nothing else. Please refer to [Reserved names](#reserved-names) to check a list of already reserved names

`url`: url of the image used to represent the token's face

`removable`: if set to `false`, after being attached to the miniature it can't be removed by any means (useful for permanent equipments)

`stackable`: if set to `true`, the miniature will count how many tokens of the same kind have been applied to it

`secret`: if set to `true` makes the token only visible to the miniature's owner, after being applied to it, until it is clicked on. Useful for secret roles specific tokens (ie. Interloper). It will also override `removable`, `stackable` and `equipment` to `false`.

`equipment`: if set to `true` makes the token will be considered as an equipment one. It will also override `stackable` to `false`.

* If the token is not recognizing the right face completely (so it's not like face up and face down are mixed up), try to re-import your model from scratch and change the value of `face_coordinate` to a different one before experimenting with `face_up_limit` too

## Bundling tokens together
If you wish it is also possible to bundle all the tokens up into a single state-driven token. To do so, make sure that all the tokens you're about to bundle up together have the proper tags / scripts / descriptions before merging them all together in the same state

--------------------------------------
# Other stuff

## Credits
* [MoonkeyMod](https://steamcommunity.com/id/moonkey2010) and [Lues](https://steamcommunity.com/id/luesdgrinn) for creating the [KT Map Base Table](https://steamcommunity.com/sharedfiles/filedetails/?id=2574389665)
* [Focks](https://steamcommunity.com/id/zeuglinredux) for creating [KT Command Node](https://steamcommunity.com/sharedfiles/filedetails/?id=2614731381&searchtext=Command+node)
* [Rebelson666](https://discordapp.com/users/330047329988116480) for making the graphics

## Reserved names
Please do not use, under any circumstances, the following names/descriptions for your tokens:
* Engage_ready
* Engage_activated
* Conceal_ready
* Conceal_activated
* Wound_blue
* Wound_red
* Minus_1_blue
* Minus_1_red
* Plus_1_blue
* Plus_1_red
* Exclamation_blue
* Exclamation_red
* Crosshair_blue
* Crosshair_red

## Order tokens
* Spawn a non-stackable `Token` item (`Objects > Components > Custom > Token`)
* Add the url of the token's `Image` and click on `Import`
* Right click on the newly created token then access the `Tags` menu voice and add a new tag called `KTUITokenOrder` or highlight it from the list if already present
* Right click on the token add give it any of these descriptions: `Engage_ready`, `Engage_activated`, `Conceal_ready`, `Conceal_activated`
* You can also give it a fancy name but it's not mandatory
