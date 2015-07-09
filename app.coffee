puts = (s) ->
	console.log s

express = require("express")
session = require('express-session')
path = require("path")
favicon = require("static-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
bodyParser = require("body-parser")
debug = require('debug')('echo')
flash = require("connect-flash")
app = express()
http = require('http').Server(app)
io = require('socket.io')(http)
fs = require("fs")
_ = require("underscore")
require("./lib/models")()

#-----Flash-----#
app.use(session({
    secret: "fhaioehf83cyfiqc9qy4cbre8cyo8fneo8cfg8oac8fwbufbghwcvfi7tcew",
    resave: true,
    saveUninitialized: true
}))
app.use(flash())
#-----flash-----#


# view engine setup
app.set "views", path.join(__dirname, "app/views")
app.set "view engine", "jade"
app.use favicon()
app.use logger("dev")
app.use bodyParser.json()
app.use bodyParser.urlencoded()
app.use cookieParser()
app.use express.static(path.join(__dirname, "public"))
app.locals.pretty = true



##全コントローラ共通のメソッドを記述
##クッキーからログイン中かどうかを判別する
#app.get("/*",(req,res,next)->
#	s_id = req.cookies._echo_app
#	#console.log "ログイン中かどうかを判別するよ！クッキーからな！"
#	#console.log "(´・ω・`)`)#{s_id}"
#	
#	User.find(where: {
#		uniq_session_id: s_id
#	}).then((user)->
#		req.session.current_user = user
#		#console.log req.session.current_user
#		next()
#	).catch((err)->
#		console.log "This cookie is unknown!"
#		next()
#	)
#)

for route in fs.readdirSync("./app/controllers/")
	unless route.match(/^\./)
		r = route.split(".")[0]
		r = if r == "index" then "/" else r
		app.use("/#{r}",require("./app/controllers/#{r}"))
#-----Routings-----#


#/ catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err
  return


#/ error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err

    return


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}
  return






#-----SocketIO------#
io.on("connection",(socket)->
	console.log("(・∀・)！User connected")

	#トップページからのPOSTアクセスを管理する
	socket.on("send_post_card",(data)->
		console.log data
		socket_id = data.socket_id

		User.findById(data.user_id).then((user)->
			Post.build({
				body: data.body,
				user_id: data.user_id,
				user_name: user.name,
				user_image: user.image
			}).save().then((post)->
				
				data = {}
				data.id = post.id
				data.body = post.body
				data.user_id = post.user_id
				data.user_name = post.user_name
				data.user_image = post.user_image

				io.sockets.emit("hand_out_post_card",data)
			).catch((err)->
				console.log err
			)
		).catch((err)->
			console.log "Cant find user #{err}"
			io.to(data.socket_id).emit("failed_save_data",err)
		)
	)
)
#-----SocketIO------#

http.listen(3000,->
	console.log "Server is running!"
)
