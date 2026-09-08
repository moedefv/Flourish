<sub>Credits to **@AlexanderLindholt** for creating **[Tween+](https://devforum.roblox.com/t/v2-tween-advanced-performant-tweening/3599638)** and **[Signal+](https://devforum.roblox.com/t/signal-super-fast-elegant-signals/3552231)**, which helped make Flourish faster and more optimized.</sub>

# Flourish

Flourish is a lightweight Roblox GUI effects library designed to help make your interfaces feel a lot more polished.

## Features

* **Stackable Effects** - Combine multiple effects on the same element
* **Customizable** - Configure effect strength and offsets
* **Tween-Based** - Smooth animations powered by Tween+

## Installation

### [Creator Hub](https://create.roblox.com/store/asset/110208100777922/Flourish)

Add Flourish to your inventory, then insert it into your experience through the Toolbox. Then, place Flourish in `ReplicatedStorage`

### [Download](https://github.com/user-attachments/files/31971523/Flourish.zip)

Download Flourish, extract into RBXM, then drag the file in studio. Place it in `ReplicatedStorage`.

## Usage

Require Flourish and create a Flourish object from a `GuiObject`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flourish = require(ReplicatedStorage.Flourish)

local button = path.to.button
local buttonObject = Flourish.new(button)
```

You can then add effects to your GUI element:

```lua
buttonObject:Expand("Hover")
buttonObject:Expand("Click")
buttonObject:Shake("Click")

buttonObject:Pulse()
buttonObject:Lift()
-- effects like Pulse and Lift are non dynamic, meaning you are not supposed to pass in anything for them because they're automatically set up
-- you can tell an effect is non dynamic by looking at the autocomplete
```

Effects like Pulse and Lift are non dynamic, meaning you are not supposed to pass in anything for them since they're automatically set up.
You can tell an effect is non dynamic by looking at the autocomplete, as shown below.

Effects can be combined and stacked together. For example, hovering while clicking can apply both Expand effects simultaneously if you do this:

```lua
buttonObject:Expand("Hover") -- expands whenever you hover over it
buttonObject:Expand("Click") -- expands whenever you click it
```

## Settings

Flourish provides configurable settings for effect strength and offsets, here is this as an example:

```lua
local Settings = {
    EXPAND_SCALE = 0.05,
    PULSE_SCALE = 0.05,

    LIFT_OFFSET = UDim2.fromScale(0, -0.005),
} -- and any other effects
```

Adjust these values to customize how strong each effect feels.

## API

### `Flourish.new(element)`

Creates a new Flourish object for a `GuiObject`.

```lua
local buttonObject = Flourish.new(button)
```

### `:effect(connectionType)`

Adds an effect of your choice, with a required connection type (unless the effect is non-dynamic. you can tell by looking at the autocomplete)

### `:Disconnect(effectName, connectionType)`

Disconnects a specific effect connection or all connections for an effect.

```lua
buttonObject:Disconnect("Expand", "Hover") -- stops the button from expanding when you hover over it
buttonObject:Disconnect("Expand", "All") -- stops the button from expanding at all
```

## Version

**v0.1**
