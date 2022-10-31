local library = {}
local tags = {
	["gui"] = {
        properties = {
            ["Name"] = function(element, value)
                element.Name = value
            end
        },
		createElement = function(properties)
            
        end,
	},
}

function library:test(html) end

return library
