require 'sinatra'
require 'erb'
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:///#{Dir.pwd}/project.db")

class URL
  include DataMapper::Resource
  
  property :id, Serial
  property :url, String
  property :alias, String
  
  validates_presence_of :url
    
  before :save, :generate_alias
    
  def generate_alias
    lower_case = ("a".."z").to_a
     upper_case = ("A".."Z").to_a
     nums = (1..9).to_a

     range = lower_case.count + upper_case.count + nums.count

     char_types = [lower_case, upper_case, nums]

     self.alias = 4.times.inject("") do |str|
       type_count = rand(3)
       type = char_types[type_count]    
       char = type[rand(type.count)]
       str << char.to_s
     end
  end
  
  def debug
    puts "-------------"
    puts "URL: #{self.url}"
    puts "Alias: #{self.alias}"
    puts "-------------"
  end
  
end


DataMapper.finalize
DataMapper.auto_upgrade!



helpers do
  def url(a)
    # alias is a keyword :(
    # Could I make the root url dynamic?
    "http://bobs.cc/#{a}"
  end
  
  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
end

# I'll deal with auth later.

get '/' do
  @saved = params[:saved] if params[:saved]
  @urls = URL.all
  erb :index
end

get '/:alias' do
  url = URL.first(:alias => params[:alias])
  if !url.nil?
    redirect url.url
  else
    redirect '/'
  end
end

post '/save/' do
  @url = URL.new(:url => params[:url]["url"])
  if @url.save
    redirect to "/?saved=#{@url.alias}"
  end
end

