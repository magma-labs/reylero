module.exports = (reylero) ->
 reylero.hear /netinha/i, (res) ->
   res.send "Soooooo, You are you gonna have the stand-up from home, right?"

 reylero.respond /la netinha/i, (res) ->
   res.reply "Maigos I will be having the stand-up from home, I'll be going to the office after."

  reylero.respond /no today/i, (res) ->
   res.reply "That's OK , It would be some other day."

   