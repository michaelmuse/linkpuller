#LINKPULLER
---
Linkpuller is a simple tool that pulls the links out of a Twitter feed and makes a reading list out of them for you"

---

HEROKU http://linkpuller.herokuapp.com/

---


-External data:

--Twitter gem
    -specifically to look up user timelines, in different quantities


  -Diffbot API
    -To enrich the articles - this may run out of credits at some point
    
To use linkpuller, just log in, choose a username that generally has great links, and pick an amount of tweets to pull. The more you pull, the longer it takes. Generally, pulling all tweets from a user will take a very long time.

In the view function, it arranges links by domain and actually writes you an export file of the bookmarks that you can upload to your browser. This would let you quickly bookmark all the links in your browser from an @username you like so that you might browse them later.


Obviously, there is a very light frontend. The frontend helps execute a very data intensive task when you pull a users tweets - a data query that fetches hundreds (or thousands) of tweets conditionally on if they have links, loops through each one of them and does the following [assigns their attributes to a tweet object in the database, creates a link object and performs the same operation of saving the link's attributes to the database, then looking up those links in the Diffbot API and extracting things like an Author Name, Title, etc for the linked page], again for each of the thousand of tweets.

For speed issues, I did some refactoring, of note may be reducing the number of calls to the database:

```ruby

    ###In order to solve so many saves to db, I save the looked up data to arrays
    tweet_arr = []
    twitter_name_arr = []
    link_arr = []
    if tweets != nil
      tweets.each do |tweet|
        begin 
          curr_url = tweet.attrs[:entities][:urls][0]
        rescue 
        end
        if curr_url 
          #Store a new tweet
          tweet_hash = {}
          tweet_hash[:twitter_tweet_id] = tweet.attrs[:id].to_s
          tweet_hash[:url]              = curr_url[:expanded_url]
          tweet_hash[:tweet_date]       = tweet.attrs[:created_at]
          tweet_hash[:twitter_name_id]  = tweet.attrs[:user][:id].to_s
          tweet_hash[:text]             = tweet.attrs[:text]
          tweet_hash[:domain]           = URI.parse(curr_url[:expanded_url]).host
          tweet_arr << tweet_hash  

          # Store a new TwitterName
          twitter_name_hash = {}
          twitter_name_hash[:twitter_name_id] = tweet.attrs[:user][:id].to_s #if this already exists, the user is not remade
          twitter_name_hash[:username]        = tweet.attrs[:user][:screen_name]
          twitter_name_arr << twitter_name_hash

          # Store a new link
          link_hash = {}
          link_hash[:twitter_tweet_id]        = tweet.attrs[:id].to_s
          link_hash[:url]                     = curr_url[:expanded_url]
          link_hash[:domain]                  = URI.parse(curr_url[:expanded_url]).host
          link_arr << link_hash
        end
      end
      # SAVE ALL THE DATA I HAVE COLLECTED IN THESE HASHES WITH THREE DB CALLS
      Tweet.create(tweet_arr)
      TwitterName.create(twitter_name_arr)
      new_links = Link.create(link_arr)
    end
  end
  
```

Other interesting refactoring involved making fewer database calls to prepare the data for the view - instead of looping through each element, I send all the data to the view in a single variable

```ruby
    @data = get_all_tweet_info_for_table(params[:id])
    @domain_counts = get_domain_info_for_table_columns(@data.keys) #this method takes just the tweets
###### helper methods for the above are beolw:
  def get_all_tweet_info_for_table(tname_id)
    if tname_id
    username = TwitterName.find(tname_id)
    tweets = Tweet.where(twitter_name_id: username.twitter_name_id).order(:domain)
    else
    tweets = Tweet.find(:all, :order => :domain)
    end
    data = {}
    tweets.each do |tweet|
      user_name_and_links_array = []
      user_name_and_links_array << username
      user_name_and_links_array <<  Link.find_by_sql(["SELECT * FROM links WHERE twitter_tweet_id = ?", tweet.twitter_tweet_id])
  #give me a hash where I can get my data without more DB calls
      data[tweet] = user_name_and_links_array
    end
    return data
  end
  def get_domain_info_for_table_columns(tweets)
    domain_counts = {}
    tweets.each do |tweet|
      #increment the domain
      domain_counts[tweet.domain] ? domain_counts[tweet.domain] += 1 : domain_counts[tweet.domain] = 1
    end
    return domain_counts
  end
end

```

The API that looks up the URL's attributes is very slow (which hangs long enough to cause Heroku to time out unfortunately), so I also spent a lot of time trying to figure out how to use RubyProf to measure that within my loop, Typhoeus to see if I could make many requests concurrently (needs more work), and ultimately decided upon delayed_job to redirect you to the page and lookup this data later. If I had more time, I would implement a scheduler to kick off these delayed jobs regularly, but currently, I do it manually :)

My test coverage is still decent despite all the refactoring, which is a nice win:

![Test Coverage](http://content.screencast.com/users/MichaelMuse/folders/Jing/media/aed9443e-3e21-49bb-b011-d2d419579cf5/00000018.png)

If I had more time I would like to rewrite them to ensure that beyond every line being run by my tests (not always necessary), every condition is being tested (not necessarily perfect yet).

Overall, it was a really fun project that allowed me to bite off way more than I could chew, which was pretty cool for 1 month of coding experience.
