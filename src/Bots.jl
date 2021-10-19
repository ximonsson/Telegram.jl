module Bots

using HTTP, JSON3, Dates

const URL = "https://api.telegram.org"

struct Bot
	token::String
end

struct APIError <: Exception
	msg::AbstractString
end

"""
[Telegram User](https://core.telegram.org/bots/api#user)
"""
struct User
	ID::Int
	bot::Bool
	first_name::String

	User(o::AbstractDict) = new(o[:id], o[:is_bot], o[:first_name])
end

"""
	request(bot::Bot, method::AbstractString, args..; kwargs...)

Generic function for calling a method towards the telegram API.
"""
function request(bot::Bot, method::AbstractString, args...; kwargs...)
	url = "$URL/" * "bot$(bot.token)/" * method
	headers = Dict("Content-Type" => "application/json",)
	body = JSON3.write(kwargs)

	r = HTTP.request("POST", url, headers, body, status_exception = false)
	resp = JSON3.read(r.body)
	r.status >= 300 && throw(APIError(resp[:description]))

	return resp[:result]
end

"""
	get_me(bot::Bot)

[getMe](https://core.telegram.org/bots/api#getme)

A simple method for testing your bot's auth token. Returns a User object.
"""
get_me(bot::Bot) = request(bot, "getme") |> User

"""
[Telegram Chat](https://core.telegram.org/bots/api#chat)
"""
struct Chat
	ID::Int
	type::String

	Chat(o::AbstractDict) = new(o[:id], o[:type])
end

"""
[Telegram Message](https://core.telegram.org/bots/api#message)
"""
struct Message
	ID::Int
	from::Union{User,Nothing}
	chat::Chat
	date::DateTime
	text::String

	Message(o::AbstractDict) =
		new(
			o[:message_id],
			User(o[:from]),
			Chat(o[:chat]),
			unix2datetime(o[:date]),
			o[:text],
		)
end

"""
This object represents an incoming update.

[Telegram Update](https://core.telegram.org/bots/api#update)
"""
struct Update
	ID::Int
	msg::Union{Message,Nothing}
	edited_msg::Union{Message,Nothing}

	Update(o::AbstractDict) = new(
			o[:update_id],
			haskey(o, :message) ? Message(o[:message]) : nothing,
			haskey(o, :edited_message) ? Message(o[:edited_message]) : nothing,
		)
end

"""
	get_updates(bot::Bot; kwargs...)

[getUpdates](http://core.telegram.org/bots/api#getupdates)

Use this method to recieve incoming updates.
"""
get_updates(bot::Bot; kwargs...) = request(bot, "getupdates"; kwargs...) .|> Update

"""
	get_chat(bot::Bot, chatid::Union{AbstractString,Integer})

Use this method to get up to date information about the chat. Returns a Chat object.
[getChat](https://core.telegram.org/bots/api#getchat)
"""
get_chat(bot::Bot, cid::Union{AbstractString,Integer}) = request(bot, "getchat"; chat_id = cid) |> Chat

"""
	send_message(bot::Bot, chatid::Union{Integer,AbstractString}, txt::AbstractString, args...; kwargs...)

Use this method to send text messages. On success, the sent Message is returned.
[sendMessage](https://core.telegram.org/bots/api#sendmessage)

```
	parse_mode::AbstractString = "MarkdownV2",
	entities::AbstractVector{MessageEntity} = [],
	disable_web_page_preview::Bool = false,
	disable_notification::Bool = false,
	reply_to_message_id::Union{Nothing,Integer} = nothing,
	allow_sending_without_reply::Bool = false,
```

"""
send_message(
		bot::Bot,
		cid::Union{Integer,AbstractString},
		txt::AbstractString,
		args...;
		kwargs...
) = request(bot, "sendmessage"; chat_id = cid, text = txt, kwargs...) |> Message

end
