socket = io()
$ ->

	post = $("#post")
	card_box = $("#card_box")
	u_id = $("#user_id")
	
	$("#post_form").submit((e)->
		e.preventDefault()
		post.hide()
		body = $("#post_body")
		data = {}
		data.body = body.val()
		data.user_id = u_id.val()
		data.socket_id = socket.id

		socket.emit("send_post_card",data)
		$("#create_post").closeModal()
		body.val("")
		post.fadeIn()
	)

	socket.on("failed_save_data",(data)->
		if data
			console.log "unsaved!"
	)

		
	socket.on("hand_out_post_card",(data)->
		friends_id = $("#friends_id").val().split("_")
		friends_id.shift()

		create_delete_form = (data,current_user_id)->
			if data.user_id == current_user_id
				return "<a href='/posts/#{data.id}/edit'>編集</a><i id='delete_post_#{data.id}_#{data.user_id}' class='mdi-action-delete red-text tiny delete_post_form right'></i>"
			else
				Materialize.toast("<a href='/posts/#{data.id}'>#{data.user_name}さんの新しい書き込み(・∀・)！</a>",3330)

		if friends_id.indexOf("#{data.user_id}") >= 0
			current_user_id = $("#current_user_id").val()
			post_card = "<article id='posted_card_#{data.id}' class='col s12 m6'>
				<div class='card'>
				<div class='card-content'>
				<div class='row'>
				<div class='col s2 m3 l2'>
				<img src='#{if data.user_image != "/thumb/null" then "#{data.user_image}" else "/images/amethyst_flat.png"}' class='circle responsive-img'></div>
				<div class='col s10 m9 l10'><span class='card-title cyan-text'>#{data.user_name}</span></div>
				</div>
				<p>#{data.body.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\n/g,"<br/>")}</p>
				<span class='font_size_10 right'>#{data.created_at}</span>
				</div>
				<div class='card-action'>
				<a href='/posts/#{data.id}/' class='teal-text'>コメント</a>
				#{create_delete_form(data,current_user_id)}
				</div>
				</div>
				</article>"
			card_box.prepend(post_card)
	)

	socket.emit("send_circle_talk",{
		firsr_check: true,
		room_id: $("#room_id").val()
	})

	#############################
	#サークル内で会話するためのSocket
	$("#submit_talk").on("click",()->
		data = {}
		data.body = $("#circle_talk").val()

		if data.body.length >= 1
			data.user_id = $("#user_id").val()
			data.user_name = $("#user_name").val()
			data.user_image = $("#user_image").val()
			data.circle_id = $("#circle_id").val()
			data.room_id = $("#room_id").val()
			data.firsr_check = false
			
			socket.emit("send_circle_talk",data)
			$("#circle_talk").val("")
	)
	
	socket.on("sent_talk_from_server",(data)->
		card_panel = "<article class='card #{if data.user_id == $('#user_id').val() then 'blue' else 'grey'} lighten-1 white-text'>
			<div class='card-content'>
			<div class='row'>
			<div class='col s2 m1'>
			<img src='#{if data.user_image then "/thumb/#{data.user_image}" else '/images/colorfull2.jpg'}' class='circle responsive-img blue'>
			</div>
			<div class='col s10 m11'>
			<h5 class='font_size_18'>#{data.user_name}</h5>
			</div>
			</div>
			<div class='row'>
			<div class='col s12'>
			<p>#{data.body.replace(/\n/g,'<br/>')}</p>
			</div>
			</div>
			</div>
			</article>"

		$("#cotery_comments_field").append(card_panel)
		$("#new_talk").closeModal()
	)

	#ポストにコメントをするためのコード
	if location.pathname.match(/posts\/[0-9]*$/)
		data = {first_check: true,room_id: $("#room_id").val()}
		socket.emit "create_new_comment",data

	$("#make_comment").submit((e)->
		e.preventDefault()
		data = {}
		data.room_id = $("#room_id").val()
		data.body = $("#comment_body").val()
		data.user_id = $("#user_id").val()
		data.user_name = $("#user_name").val()
		data.user_image = $("#user_image").val()
		data.post_id = $("#post_id").val()
		data.first_check = false
		
		socket.emit("create_new_comment",data)
	)

	socket.on("sent_create_new_comment",(data)->
		comment_data = "<li class='collection-item avatar'>
		<img src='#{if data.user_image? then data.user_image else "/images/amethyst_flat.png"}' class='circle'>
		<span class='title'>#{data.user_name}</span>
		<p>#{data.body.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\n/g,"<br/>")}</p>
	  </li>"
		#console.log data
		$("#comments").append(comment_data)
		$("#comment_body").val("")
	)
	
	$(document).on("click",".song_card",->
		data = {
			song_id:  $(@).attr("id").split("_")[1],
			#user_id: 必要ならユーザーの情報を送ってもいいかもしれない
		}
		socket.emit("play_song",data)
	)

	window.AudioContext = window.AudioContext||window.webkitAudioContext
	ctx = new AudioContext()

	socket.on("send_song_data",(data)->
		ctx.decodeAudioData(data,(buffer)->
			buf_node = ctx.createBufferSource()
			buf_node.buffer = buffer
			buf_node.connect(ctx.destination)
			buf_node.start(0)
		
			$(".song_controller").slideDown()
			$(document).on("click",".stop",->
				console.log "Stop"
				buf_node.stop()
			)
		,->
			console.log "Failed decode"
		)
	)


	##サークルに書き込みがあった場合にサークルに関わる人全員に通知を送る
	#user_id_for_all_page = $("#user_id_for_all_page").val()
	#console.log "notification_#{user_id_for_all_page}"

	#socket.on("notification_#{user_id_for_all_page}",(data)->
	#	console.log data
	#	#Materialize.toast("<a href='/coteries/#{data.cotery_id}'>#{data.flash}</a>",3330)
	#)
