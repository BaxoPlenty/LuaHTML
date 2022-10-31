local library = {}
local properties = {
	["gui"] = {
		["Name"] = function(element, value)
			element.Name = value
		end,
	},
	["Frame"] = {
		["Name"] = function(element, value)
			element.Name = value
		end,
		["BackgroundColor"] = function(element, value)
			element.BackgroundColor3 = Color3.fromHex(value)
		end,
		["Size"] = function(element, value)
			element.Size = UDim2.new(unpack(string.split(value, ",")))
		end,
	},
	["Button"] = {
		["Name"] = function(element, value)
			element.Name = value
		end,
		["Size"] = function(element, value)
			element.Size = UDim2.new(unpack(string.split(value, ",")))
		end,
		["Text"] = function(element, value)
			element.Text = value
		end,
		["BackgroundTransparency"] = function(element, value)
			element.BackgroundTransparency = value
		end,
	},
}

local realTagNames = {
	["gui"] = "ScreenGui",
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
