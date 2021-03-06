fs = require("fs")
crypto = require("crypto")
sql = require("./sql")


#大文字化
cap= (s) ->
	return "#{s[0].toUpperCase()}#{s.slice(1)}"

hash = (s) ->
	sha512 = crypto.createHash('sha512')
	sha512.update(s)
	return sha512.digest('hex')


path = "./app/models/"
createModels = ->
	models = {}
	for i in fs.readdirSync(path)
		unless i.match(/^\./)
			r = i.split(".")[0]
			eval("#{cap(r)} = require('../../app/models/#{r}')")
			eval("#{cap(r)}.hash = hash")
	

	User.hasMany(Post)
	User.hasMany(Timeline)
	
	Post.belongsTo(User)
	Timeline.belongsTo(User)
	
	User.hasMany(Comment)
	Post.hasMany(Comment)
	Comment.belongsTo(User)
	Comment.belongsTo(Post)

	User.hasMany(Session)
	Session.belongsTo(User)
	
	User.hasMany(Friend)
	Friend.belongsTo(User)
	
	User.hasMany(Song)
	Song.belongsTo(User)
	
	User.hasMany(Cotery)
	Cotery.belongsTo(User)
	
	Cotery.hasMany(Talk)
	Talk.belongsTo(Cotery)

	User.hasMany(Talk)
	Talk.belongsTo(User)
	
	User.hasMany(Blog)
	Blog.belongsTo(User)

	User.hasMany(Notification)
	Notification.belongsTo(User)

	User.hasMany(Permit)
	Permit.belongsTo(User)
#sql.s.sync({force: true})
#sql.s.sync()

module.exports = createModels
