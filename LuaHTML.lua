local logger = {}

function logger:info(message)
	print("[LUAHTML -    INFO] " .. message)
end

function logger:warning(message)
	print("[LUAHTML - WARNING] " .. message)
end

function logger:error(message)
	print("[LUAHTML -   ERROR] " .. message)
end

local library = {}
local functions = {}
local generalProperties = {
	["Name"] = function(element, value)
		element.Name = value
	end,
	["Size"] = function(element, value)
		element.Size = UDim2.new(unpack(string.split(value, ",")))
	end,
	["BackgroundColor"] = function(element, value)
		if string.find(value, "#") == 1 then
			element.BackgroundColor3 = Color3.fromHex(value)
		else
			element.BackgroundColor3 = Color3.fromRGB(unpack(string.split(value, ",")))
		end
	end,
	["BackgroundTransparency"] = function(element, value)
		element.BackgroundTransparency = value
	end,
	["BorderThickness"] = function(element, value)
		element.BorderSizePixel = value
	end,
	["BorderColor"] = function(element, value)
		if string.find(value, "#") == 1 then
			element.BorderColor3 = Color3.fromHex(value)
		else
			element.BorderColor3 = Color3.fromRGB(unpack(string.split(value, ",")))
		end
	end,
	["Color"] = function(element, value)
		if string.find(value, "#") == 1 then
			element.TextColor3 = Color3.fromHex(value)
		else
			element.TextColor3 = Color3.fromRGB(unpack(string.split(value, ",")))
		end
	end,
	["Text"] = function(element, value)
		element.Text = value
	end,
	["BorderRadius"] = function(element, value)
		local Rounding = Instance.new("UICorner")

		if string.find(value, ',') == nil then
			Rounding.CornerRadius = UDim.new(0, value)
		else
			Rounding.CornerRadius = UDim.new(unpack(string.split(value, ",")))
		end

		Rounding.Parent = element
	end,
	["Position"] = function(element, value)
		element.Position = UDim2.new(unpack(string.split(value, ",")))
	end
}
local properties = {
	["Gui"] = {
		["Name"] = generalProperties.Name,
	},
	["Frame"] = {
		["Name"] = generalProperties.Name,
		["BackgroundColor"] = generalProperties.BackgroundColor,
		["Size"] = generalProperties.Size,
		["BackgroundTransparency"] = generalProperties.BackgroundTransparency,
		["BorderThickness"] = generalProperties.BorderThickness,
		["BorderColor"] = generalProperties.BorderColor,
		["Position"] = generalProperties.Position,
		["BorderRadius"] = generalProperties.BorderRadius,
	},
	["Button"] = {
		["Name"] = generalProperties.Name,
		["Size"] = generalProperties.Size,
		["BackgroundColor"] = generalProperties.BackgroundColor,
		["Text"] = generalProperties.Text,
		["BackgroundTransparency"] = generalProperties.BackgroundTransparency,
		["BorderThickness"] = generalProperties.BorderThickness,
		["BorderColor"] = generalProperties.BorderColor,
		["BorderRadius"] = generalProperties.BorderRadius,
		["Position"] = generalProperties.Position,
		["Color"] = generalProperties.Color,
		["OnClick"] = function (element, value)
			if functions[value] then
				element.MouseButton1Click:Connect(functions[value])
			else
				logger:warning("OnClick property doesn't have a valid function.")
			end
		end
	},
}

local realTagNames = {
	["Gui"] = "ScreenGui",
	["Frame"] = "Frame",
	["Button"] = "TextButton",
}

local function createTag(tagName, attributes)
	local props = properties[tagName]
	local element = Instance.new(realTagNames[tagName])

	for _, v in next, attributes do
		if props[v.name] then
			props[v.name](element, v.value)
		end
	end

	return element
end

function library:initializeFunctions(functionsTable)
	functions = functionsTable
end

function library:create(html)
	local tags = {}
	local tag = {
		started = false,
		hasBody = true,
		isClosingTag = false,
		text = "",
		body = {},
		tagName = "",
		attributes = {},
	}

	local attribute = {
		nameEnded = false,
		started = false,
		valueStarted = false,
		name = "",
		value = "",
	}

	local function resetTag()
		tag = {
			started = false,
			hasBody = true,
			isClosingTag = false,
			text = "",
			body = {},
			tagName = "",
			attributes = {},
		}
	end

	local function endTag()
		table.insert(tags, tag)

		resetTag()
	end

	local function resetAttribute()
		attribute = {
			nameEnded = false,
			started = false,
			valueStarted = false,
			name = "",
			value = "",
		}
	end

	local function endAttribute()
		table.insert(tag.attributes, attribute)

		resetAttribute()
	end

	local function addText(text)
		tag.text = tag.text .. text
	end

	for i = 1, #html do
		local c = string.sub(html, i, i)

		if c == "<" then
			-- begin tag

			addText(c)

			tag.started = true
		elseif c == "/" then
			if tag.text == "<" then
				tag.isClosingTag = true
				tag.hasBody = false
			else
				tag.hasBody = false
			end

			addText(c)

			resetAttribute()
		elseif c == ">" then
			-- end tag

			addText(c)

			endTag()
		elseif c == " " then
			if tag.started == true then
				addText(c)

				if #tag.tagName >= 1 then
					attribute.started = true

					if attribute.valueStarted == true then
						attribute.value = attribute.value .. c
					end
				end
			end
		elseif c == "=" then
			addText(c)

			if attribute.started == true then
				attribute.nameEnded = true
			end

			if attribute.valueStarted == true then
				attribute.value = attribute.value .. c
			end
		elseif c == '"' then
			addText(c)

			if attribute.started == true then
				if attribute.valueStarted == false then
					attribute.valueStarted = true
				else
					attribute.valueStarted = false

					endAttribute()
				end
			end
		else
			if tag.started == true then
				addText(c)

				if attribute.started == true then
					if attribute.nameEnded == false then
						attribute.name = attribute.name .. c
					else
						if attribute.valueStarted == true then
							attribute.value = attribute.value .. c
						end
					end
				else
					tag.tagName = tag.tagName .. c
				end
			end
		end
	end

	local addBodyFor = {}

	for i = 1, #tags do
		local tag = tags[i]

		if tag.isClosingTag == true then
			table.remove(addBodyFor, #addBodyFor)
		end

		if addBodyFor[#addBodyFor] ~= nil then
			if tag.isClosingTag == false then
				table.insert(addBodyFor[#addBodyFor].body, tag)
			end
		end

		if tag.hasBody == true then
			table.insert(addBodyFor, tag)
		end
	end

	local guiTag = tags[1]

	local function createObject(tag)
		if realTagNames[tag.tagName] then
			local element = createTag(tag.tagName, tag.attributes)

			for _, childTag in tag.body do
				local newElement = createObject(childTag)

				if newElement then
					newElement.Parent = element
				end
			end

			return element
		end

		return nil
	end

	local guiObject = createObject(guiTag)

	return guiObject
end

return library
