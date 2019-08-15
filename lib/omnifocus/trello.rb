require "open-uri"
require "json"
require "yaml"
require "digest/md5"

module OmniFocus::Trello
  PREFIX  = "TR"
  KEY = "3ad9e72a2e2d41a98450ca775a0bafe4"

  def load_or_create_trello_config
    path   = File.expand_path "~/.omnifocus-trello.yml"
    config = YAML.load(File.read(path)) rescue nil

    unless config then
      config = { :token => "Open URL https://trello.com/1/authorize?key=#{KEY}&name=OmniFocus+Trello+integration&expiration=never&response_type=token and copy the token from the web page here.", :done_lists => ["Done", "Deployed", "Finished", "Cards in these boards are considered done, you add and remove names to fit your workflow."] }

      File.open(path, "w") { |f|
        YAML.dump(config, f)
      }

      abort "Created default config in #{path}. Go fill it out."
    end

    config
  end

  def populate_trello_tasks
    print "populating tasks"	  
    config     = load_or_create_trello_config
    token      = config[:token]
    done_lists = config[:done_lists] || config[:done_boards]

    boards = fetch_trello_boards(token)
    fetch_trello_cards(token).each do |card|
      process_trello_card(boards, done_lists, card)
    end
  end

  def fetch_trello_cards(token)
    url = "https://api.trello.com/1/members/my/cards?key=#{KEY}&token=#{token}"

    JSON.parse(open(url).read)
  end

  # get nested tag "When : Today", which need create in of. 
  def gettag()
          omnifocus.tags.get.each do |tagg|
	            tagg.tags.get.each do |t|
			    if t.name.get == "Today" 
				    return t
			    end
		    end 

          end

  end 

  def process_trello_card(boards, done_lists, card)
    number       = card["idShort"]

    datelast  = card["dateLastActivity"]
    hex = Digest::MD5.hexdigest(datelast)

    description  = if card["desc"].length > 0
      card["shortUrl"] + "\n\n" + card["desc"]
    else
      card["shortUrl"]
    end

    description = hex + "\n" + description 
			   
    today  =  nil
    flag = false 

    # label red meam flagged in of, label green mean Today tag in of.
    if !card["labels"].empty?
      card["labels"].each { |l|  if l["color"]== "green"
  			                today = "Today"
  			         end
                                 if l["color"] == "red"
  				        flag = true
			         end
      }
    end

                   
    due          = card["due"]
    board        = boards.find {|candidate| candidate["id"] == card["idBoard"] }
    project_name = board["name"]
    ticket_id    = "#{PREFIX}-#{project_name}##{number}"
    title        = "#{ticket_id}: #{card["name"]}"
    list         = board["lists"].find {|candidate| candidate["id"] == card["idList"] }
    


    

    # If card is in a "done" list, mark it as completed.
    if done_lists.include?(list["name"])
      return
    end

    puts ticket_id      
    if existing[ticket_id]
      # of note format:
      #	 datelastactivity
      #	 descriptinn or url
      
      # get note from of and compare
      hex = hex + "\n"
      if update[ticket_id] == hex 
          bug_db[existing[ticket_id]][ticket_id] = true
          return
      else 
	      #if the card have been updated, not mark it complete ,we remove the card ,and then readd the card 
              project = nerd_projects.projects[project_name]
	      project.tasks[its.name.contains(ticket_id)].get.each do |task|
                puts "deletingg #{ticket_id}, will readd latter into of"
                task.delete
              end
      end
    end

   if due 
      t = Time.parse(due)
   end
   if today != nil 
       if t 
         bug_db[project_name][ticket_id] = { :name => title, :note => description, :due_date => t, :flagged => flag, :primary_tag => gettag()}
       else
         bug_db[project_name][ticket_id] = { :name => title, :note => description, :flagged => flag, :primary_tag => gettag()}
       end
   else 
       if t 
          bug_db[project_name][ticket_id] = { :name => title, :note => description, :due_date => t, :flagged => flag}
       else
          bug_db[project_name][ticket_id] = { :name => title, :note => description,  :flagged => flag}
       end

   end

  end

  def fetch_trello_boards(token)
    url = "https://api.trello.com/1/members/my/boards?key=#{KEY}&token=#{token}&lists=open"
    JSON.parse(open(url).read)
  end
end
