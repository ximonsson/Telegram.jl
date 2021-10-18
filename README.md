# Telegram.jl

This package only supports some basic functions of the Telegram Bot API. I use this when I want to be pinged with results after long test runs.

## Quick Intro

I have no idea why someone else would be interested in this package but here comes some quick intro you can try.

After installing the package (you chose if you want to clone the repo or install it the julia way right from github), just activate and import.

```julia
] activate .
using Telegram
```

You handle your token and other secrets however you wish, I recommend environment variables:

```julia
token = ENV["TELEGRAM_BOT_API_TOKEN"]
chatid = ENV["TELEGRAM_CHAT_ID"]
```

All functions that communicate with the telegram bot api take a `Telegram.Bots.Bot` object. Create one using:

```julia
bot = Telegram.Bots.Bot(token)
```

Test the bot with:

```julia
bot_user = Telegram.Bots.get_me(bot)
```

If successful `bot_user` will then be a `Telegram.Bots.User` object containing information about the bot and you are ready to work with the other methods of the API.
