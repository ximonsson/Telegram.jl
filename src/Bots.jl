module Bots

using HTTP, JSON3

const URL = "https://api.telegram.org"

struct APIError <: Exception
	msg::AbstractString
end

struct MessageEntity

end

struct Message

end

struct Bot
	token::String
end

"""
	request(bot::Bot, method::AbstractString, args..; kwargs...)

Generic function for calling a method towards the telegram API.
"""
function request(bot::Bot, method::AbstractString, args...; kwargs...)
	url = "$URL/" * "bot$(bot.token)/" * method
	headers = Dict("Content-Type" => "application/json",)
	body = JSON3.write(kwargs)

	r = HTTP.request("POST", url, headers, body)

	if r.status != 200
		throw(APIError(r.body))
	end

	JSON3.read(r.body)
end

"""
getMe
"""
get_me(bot::Bot) = request(bot, "getme")

"""
getUpdates
"""
get_updates(bot::Bot; kwargs...) = request(bot, "getupdates"; kwargs...)

"""
getChat
"""
get_chat(bot::Bot, cid::Union{AbstractString,Integer}) = request(bot, "getchat"; chat_id = cid)

"""
	parse_mode::AbstractString = "MarkdownV2",
	entities::AbstractVector{MessageEntity} = [],
	disable_web_page_preview::Bool = false,
	disable_notification::Bool = false,
	reply_to_message_id::Union{Nothing,Integer} = nothing,
	allow_sending_without_reply::Bool = false,

sendMessage
"""
function send_message(
		bot::Bot,
		cid::Union{Integer,AbstractString},
		txt::AbstractString,
		args...;
		kwargs...
)
	request(bot, "sendmessage"; chat_id = cid, text = txt, kwargs...)
end

end
