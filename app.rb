#© Matthias Lee 2021 All rights reserved.
require "sinatra"
require "pstore"
db = PStore.new("db.pstore")
get("/") do
	@counter1 = db.transaction { db["shorturlscounter"] }["c"].to_s
	@counter2 = db.transaction { db["accessedtimescounter"] }["c"].to_s
	erb :home
end
get("/api") do
	erb :api
end
get("/api/") do
	erb :api
end
get("/resources/:r") do
	send_file "./resources/" + params["r"]
end
get("/adminpanel") do
@error = ""
erb :adminsignin
end
post("/adminpanel") do
if params["pass"] == File.read("./adminpassword.txt").gsub("\n", "")
	@vlg = File.read("./VIEW LOG.txt").gsub("\n", "<br>")
	@clg = File.read("./CREATION LOG.txt").gsub("\n", "<br>")
	erb :admin
else
	@error = "<p style = 'color:red'>Invalid Password</p>"
	erb :adminsignin
end
end
post("/") do
rdu = params["url"].gsub(" ", "")
	if rdu[0..7] == "https://" || rdu[0..6] == "http://" || rdu[0..5] == "ftp://"
		else
			rdu = "http://" + rdu
		end
	counter1 = db.transaction { db["shorturlscounter"] }["c"]
	counter2 = db.transaction { db["accessedtimescounter"] }["c"]
	newcount = counter1 + 1
	db = PStore.new("db.pstore")
	if params["csturl"].gsub(" ", "") == ""
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		uch = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
		outurl = nil
		
		if wu[rdu.gsub(" ", "")] != nil
			File.write("CREATION LOG.txt", "\n#{wu[rdu.gsub(" ", "")]} Recreated on #{Time.now.inspect} by #{request.ip}", mode: "a")
			outurl = wu[rdu.gsub(" ", "")]
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
			@ou = outurl
				erb :done
		else
			
			if rdu == ""
				redirect "/"
			end
			outurl = "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}"
			if uw_custom[outurl] != nil || uw[outurl] != nil
				return "An internal error has occured. Please go back and try again."
			else
				
				db.transaction do
					db["uw"][outurl] = rdu
					db["wu"][rdu] = outurl
					
					db.commit
				end
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
				File.write("CREATION LOG.txt", "\n#{outurl} Created on #{Time.now.inspect} by #{request.ip}", mode: "a")
				@ou = outurl
				erb :done
			end
		end
	else

		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		outurl = nil
		if uw[params["csturl"].gsub(" ", "")] != nil || uw_custom[params["csturl"].gsub(" ", "")] != nil
			erb :exists
		else
			
			if rdu == ""
				redirect "/"
			end
			if rdu[0..7] == "https://" || rdu[0..6] == "http://" || rdu[0..5] == "ftp://"
			else
				rdu = "http://" + rdu
			end
			outurl = params["csturl"].gsub(" ", "")
			if !!outurl.match(/[^A-z0-9_\-\@]/) || outurl.include?("\\")
				erb :badchar
			else
				db.transaction do
					db["uw_custom"][outurl] = rdu
					
					db.commit
				end
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
				File.write("CREATION LOG.txt", "\n#{outurl} Created on #{Time.now.inspect} by #{request.ip}", mode: "a")
				@ou = outurl
				erb :done
			end
		end
	end
end
post("/api") do
	rdu = params["url"].gsub(" ", "")
	if rdu[0..7] == "https://" || rdu[0..6] == "http://" || rdu[0..5] == "ftp://"
	else
		rdu = "http://" + rdu
	end
	counter1 = db.transaction { db["shorturlscounter"] }["c"]
	counter2 = db.transaction { db["accessedtimescounter"] }["c"]
	newcount = counter1 + 1
	if params["csturl"].gsub(" ", "") == ""
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		uch = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
		outurl = nil
		
		if wu[rdu.gsub(" ", "")] != nil
			File.write("CREATION LOG.txt", "\n#{wu[rdu.gsub(" ", "")]} Recreated on #{Time.now.inspect} by #{request.ip} with API", mode: "a")
			outurl = wu[rdu.gsub(" ", "")]
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
				return outurl
		else
		
			outurl = "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}" + "#{uch[rand(1..34) - 1]}"
			if uw_custom[outurl] != nil || uw[outurl] != nil
				return "ERR:INTERR"
			else
				newcount = counter1 + 1
				db.transaction do
					db["uw"][outurl] = rdu
					db["wu"][rdu] = outurl
					
					db.commit
				end
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
				File.write("CREATION LOG.txt", "\n#{outurl} Created on #{Time.now.inspect} by #{request.ip} with API", mode: "a")
				return outurl
			end
		end
	else
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		outurl = nil
		if uw[params["csturl"].gsub(" ", "")] != nil || uw_custom[params["csturl"].gsub(" ", "")] != nil
			return "ERR:URLEXIST"
		else
			
			if rdu[0..7] == "https://" || rdu[0..6] == "http://" || rdu[0..5] == "ftp://"
			else
				rdu = "http://" + rdu
			end
			outurl = params["csturl"].gsub(" ", "")
			if !!outurl.match(/[^A-z0-9_\-\@]/) || outurl.include?("\\")
				return "ERR:BADCHAR"
			else
				db.transaction do
					db["uw_custom"][outurl] = rdu
					db.commit
				end
				db.transaction do
					db["shorturlscounter"]["c"] = newcount
					db.commit
				end
				File.write("CREATION LOG.txt", "\n#{outurl} Created on #{Time.now.inspect} by #{request.ip} with API", mode: "a")
				return outurl
			end
		end
	end
end
get("/:url") do
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		counter2 = db.transaction { db["accessedtimescounter"] }["c"]
		newc = counter2 + 1
	if uw[params["url"]] != nil
		File.write("./VIEW LOG.txt", "\n#{params["url"]} Viewed on #{Time.now.inspect} by #{request.ip}", mode: "a")
		db.transaction do
			db["accessedtimescounter"]["c"] = newc
			db.commit
		end
		redirect uw[params["url"]]
	else
		
		if uw_custom[params["url"]] != nil
			File.write("./VIEW LOG.txt", "\n#{params["url"]} viewed on #{Time.now.inspect} by #{request.ip}", mode: "a")
		db.transaction do
			db["accessedtimescounter"]["c"] = newc
			db.commit
		end
			redirect uw_custom[params["url"]]
		else
			erb :notfound
		end
	end
end
get("/:url/") do
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
		counter2 = db.transaction { db["accessedtimescounter"] }["c"]
		newc = counter2 + 1
	if uw[params["url"]] != nil
		File.write("./VIEW LOG.txt", "\n#{params["url"]} Viewed on #{Time.now.inspect} by #{request.ip}", mode: "a")
		db.transaction do
			db["accessedtimescounter"]["c"] = newc
			db.commit
		end
		redirect uw[params["url"]]
	else
		
		if uw_custom[params["url"]] != nil
			File.write("./VIEW LOG.txt", "\n#{params["url"]} viewed on #{Time.now.inspect} by #{request.ip}", mode: "a")
		db.transaction do
			db["accessedtimescounter"]["c"] = newc
			db.commit
		end
			redirect uw_custom[params["url"]]
		else
			erb :notfound
		end
	end
end
get("/preview/:url") do
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
	if uw[params["url"]] != nil
		@cor = "random"
		@url = uw[params["url"]]
		@crurl = params["url"]
		erb :preview
	else
		if uw_custom[params["url"]] != nil
			@cor = "custom"
			@url = uw_custom[params["url"]]
			@crurl = params["url"]
			erb :preview
		else
			erb :notfound
		end
	end
end
get("/apipreview/:url") do
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
	if uw[params["url"]] != nil
		url = uw[params["url"]]
		return "R:" + url
	else
		if uw_custom[params["url"]] != nil
			url = uw_custom[params["url"]]
			return "C:" + url
		else
			return "ERR:NF"
		end
	end
end
get("/preview/:url/") do
		uw = db.transaction { db["uw"] }
		wu = db.transaction { db["wu"] }
		uw_custom = db.transaction { db["uw_custom"] }
	if uw[params["url"]] != nil
		@cor = "random"
		@url = uw[params["url"]]
		@crurl = params["url"]
		erb :preview
	else
		if uw_custom[params["url"]] != nil
			@cor = "custom"
			@url = uw_custom[params["url"]]
			@crurl = params["url"]
			erb :preview
		else
			erb :notfound
		end
	end
end
