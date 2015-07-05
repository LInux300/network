#!/usr/bin/ruby -w
# ruby cheat_sheet.rb cheat_sheet_support.rb
# 
print "*** module ","*"*60, "\n" 
$LOAD_PATH << '.'                       # must be to read from current dir
require 'cheat_sheet_support'                         # filename
wrongdoing = Moral.sin(Moral::VERY_BAD) # module from file moral.rb , it returns 0


print "*** class ","*"*60, "\n" 
class Decade
include Week
   no_of_yrs=10
   def no_of_months
      puts Week::FIRST_DAY
      number=10*12
      puts number
   end
end
d1=Decade.new
puts Week::FIRST_DAY             # Sunday
Week.weeks_in_month              # You have four weeks in a month
Week.weeks_in_year               # You have 52 weeks in a year
d1.no_of_months                  # Sunday
                                 # 120

name="Kuntuzangpo"
puts "Hello: #{name}"
puts "Count it #{25+10/2}"        # 30
puts "Is it greater? #{5 > -2}"   # true
puts 3 + 2 < 5 - 7                # false


print "*** Formatter ","*"*60, "\n" 
formatter = "%{first} %{second} %{third} %{fourth}"
puts formatter % {first: 1, second: 2, third: 3, fourth: 4}    # 1 2 3 4 
puts formatter % {
  first: "I had this thing.",
  second: "That you could type up right.",
  third: "But it didn't sing.",
  fourth: "So I said goodnight."
}

print "How old are you? \n"
#age = gets.chomp
#puts "you are: #{age}"

#arguments
print "*** ARGV arguments ","*"*60, "\n" 
first, second = ARGV
puts "Your first variable is: #{first}"
puts "Your second variable is: #{second}"
file_name = ARGV.first
prompt = '> '                       
puts "File name is #{file_name}."
#puts "Do you like me #{file_name}? ", prompt
#likes = $stdin.gets.chomp
#puts "#{likes}, I like you."


filename = ARGV.first
begin 
  myFile = open(filename)
  if myFile
    puts "Here's your file #{filename}:"
    print myFile.read
    #raise ExceptionType, "Error Message" condition
  end
rescue Exception => e
  # handle error
  #file = STDIN
  #print file, "==", STDIN, "\n"
  puts e.message
  #puts e.backtrace.inspect
  puts "Write existing filename:"
  filename = $stdin.gets.chomp
  retry                          # returns to begin
ensure
  puts "It always goes hee. Ensuring execution" 
end

print "*** String ","*"*60, "\n" 
print <<EOF
    This is the first way of creating
    here document ie. multiple line string.
EOF
print <<"EOF";                # same as above
    This is the second way of creating
    here document ie. multiple line string.
EOF
print <<`EOC`                 # execute commands
	echo hi there
	echo lo there
EOC
print <<"foo", <<"bar"  # you can stack them
	I said foo.
foo
	I said bar.
bar
%{Ruby is fun.}     # equivalent to "Ruby is fun."
%Q{ Ruby is fun. }  # equivalent to " Ruby is fun. "
%q[Ruby is fun.]    # equivalent to a single-quoted string
%x!ls!              # equivalent to back tick command output `ls`


BEGIN {
   puts "Initializing Ruby Program"
}
END {
   puts "Terminating Ruby Program"
}

print "*** multiple comments ","*"*60, "\n" 
=begin
This is a comment.
This is a comment, too.
This is a comment, too.
I said that already.
=end

print "*** variables ","*"*60, "\n" 
$global_variable="Ruby on Rails" 
class Customer
   CONSTANT01 = "Begging with an uppercase letter. Constants may not be defined within methods."
   @@no_of_customers=0   # class variable  
   def initialize(id, name, addr)
      @cust_id=id        # instance variable
      @cust_name=name
      @cust_addr=addr
   end
   def hello
      _localvariable="only avaiable in the function"
      puts "Hello Ruby!"
   end
   def counter
       @@no_of_customers+=1     
      puts @@no_of_customers
   end
end
cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
cust2=Customer.new("2", "Poul", "New Empire road, Khandala")
cust2.hello                        # Hello Ruby!
cust1.counter                      # 1
cust2.counter                      # 2
puts cust2                         # object

print "*** array ","*"*60, "\n" 
# http://www.tutorialspoint.com/ruby/ruby_arrays.htm
ary = [  "Array", 10, 3.14, "This is a string", "last element", ]
ary.each do |i|
   puts i
end
a = Array.new(2)           # [nil,nil]
names = Array.new(4, "mac")
puts "#{names}"            # macmacmacmac
nums = Array.[](1, 2, 3, 4,5)
puts nums   
nums = Array[1, 2, 3, 4,5]
puts nums          # under each other 
digits = Array(0..9)
nums.clear         # removes all elements
puts "#{digits}"    # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
six = digits.at(6)
puts six            # 6
multiarr = [['one','two','three'],[1,2,3,4]]
for i in multiarr
   puts(i.inspect)
end

# literal Ruby Hash is created by example
# http://www.tutorialspoint.com/ruby/ruby_hashes.htm
print "*** hash ","*"*60, "\n" 
h1 = Hash.new
h2 = Hash.new("Some")
h3 = Hash["a" => 100, "b" => 200]
hsh = colors = { "red" => 0xf00, "green" => 0x0f0, "blue" => 0x00f }
hsh['white'] = 123                     # add key value
hsh.delete('blue')                     # delete key
h1.merge(h2)
h1.sort
h1.values
hsh.each do |key, value|
   print key, " is ", value, "\n"      # red is 3840
end


# ranges
print "*** ranges ","*"*60, "\n" 
(10..15).each do |n| 
   print "ranges:", n, ' ' 
end

#.eql?	True if the receiver and argument have both the same type and equal values.	1 == 1.0 returns true, but 1.eql?(1.0) is false.
#equal?	True if the receiver and argument have the same object id.	if aObj is duplicate of bObj then aObj == bObj is true, a.equal?bObj is false but a.equal?aObj is true.

# binary, bitwise operators
#a = 0011 1100
#b = 0000 1101
#-----------------
#a&b = 0000 1100
#a|b = 0011 1101
#a^b = 0011 0001
#~a  = 1100 0011

print "*** defined? ","*"*60, "\n" 
defined? method_call # True if a method is defined
puts defined? super     # => "super" (if it can be called)
defined? yield   # True if a code block has been passed


print "*** module ","*"*60, "\n" 
MR_COUNT = 0        # constant defined on main Object class
module Foo
  MR_COUNT = 0
  ::MR_COUNT = 1    # set global count to 1
  MR_COUNT = 2      # set local count to 2
end
puts MR_COUNT       # this is the global constant
puts Foo::MR_COUNT  # this is the local "Foo" constant


print "*** constants ","*"*60, "\n" 
CONST = ' out there'
class Inside_one
   CONST = proc {' in there'}
   def where_is_my_CONST
      ::CONST + ' inside one'
   end
end
class Inside_two
   CONST = ' inside two'
   def where_is_my_CONST
      CONST
   end
end
puts Inside_one.new.where_is_my_CONST
puts Inside_two.new.where_is_my_CONST
puts Object::CONST + Inside_two::CONST
puts Inside_two::CONST + CONST


print "*** if elsif ","*"*60, "\n" 
x=1
if x > 2
   puts "x is greater than 2"
elsif x <= 2 and x!=0
   puts "x is 1"
else
   puts "I can't guess the number"
end

x=1
unless x>2
   puts "x is less than 2"
 else
  puts "x is greater than 2"
end


$var =  1
print "1 -- Value is set\n" if $var           # 1 -- Value is set
print "2 -- Value is set\n" unless $var       # doesn't write anything
$var = false
print "3 -- Value is set\n" unless $var       # 3 -- Value is set


print "*** case ","*"*60, "\n" 
$age =  5
case $age
when 0 .. 2
    puts "baby"
when 3 .. 6
    puts "little child"
when 7 .. 12
    puts "child"
when 13 .. 18
    puts "youth"
else
    puts "adult"
end

print "*** while ","*"*60, "\n" 
$i = 0
$num = 5
while $i < $num  do
   puts("Inside the loop i = #$i" )
   $i +=1
end


$i = 0
$num = 5
while $i < $num  do
   puts("Inside the loop i = #$i" )
   $i +=1
end


for i in 0..5
   puts "Value of local variable is #{i}"
end



for i in 0..5
   if i > 2 then
      break
   end
   puts "Value of local variable is #{i}"
end


def test
   puts "You are in the method"
   yield
   puts "You are again back to the method"
   yield
end
test {puts "You are in the block"}
#You are in the method
#You are in the block
#You are again back to the method
#You are in the block

#You also can pass parameters with the yield statement. Here is an example:
def test
   yield 5
   puts "You are in the method test"
   yield 100
end
test {|i| puts "You are in the block #{i}"}
#You are in the block 5
#You are in the method test
#You are in the block 100


def test(&block)
   block.call
end
test { puts "Hello World!"}
# Hello World!



myStr = String.new("THIS IS TEST")
puts foo = myStr.downcase       
#puts myStr.empty?   # false
#puts myStr.hash
#myStr.lstrip        # remove whitespace
#myStr.match(pattern)   # http://www.tutorialspoint.com/ruby/ruby_strings.htm


print "*** time ","*"*60, "\n" 
time = Time.new
# Components of a Time
puts "Current Time : " + time.inspect
puts time.year    # => Year of the date 
puts time.month   # => Month of the date (1 to 12)
puts time.day     # => Day of the date (1 to 31 )
puts time.wday    # => 0: Day of week: 0 is Sunday
puts time.yday    # => 365: Day of year
puts time.hour    # => 23: 24-hour clock
puts time.min     # => 59
puts time.sec     # => 59
puts time.usec    # => 999999: microseconds
puts time.zone    # => "UTC": timezone name
# July 8, 2008
Time.local(2008, 7, 8)  
# July 8, 2008, 09:10am, local time
Time.local(2008, 7, 8, 9, 10)   
# July 8, 2008, 09:10 UTC
Time.utc(2008, 7, 8, 9, 10)  
# July 8, 2008, 09:10:11 GMT (same as UTC)
Time.gm(2008, 7, 8, 9, 10, 11)  

time = Time.new
values = time.to_a
p values     # [0, 53, 18, 5, 7, 2015, 0, 186, true, "CEST"]

# Returns number of seconds since epoch
time = Time.now.to_i  
# Convert number of seconds into Time object.
Time.at(time)
# Returns second since epoch which includes microseconds
time = Time.now.to_f
# Here is the interpretationa
time = Time.new
time.zone       # => "UTC": return the timezone
time.utc_offset # => 0: UTC is 0 seconds offset from UTC
time.zone       # => "PST" (or whatever your timezone is)
time.isdst      # => false: If UTC does not have DST.
time.utc?       # => true: if t is in UTC time zone
time.localtime  # Convert to local timezone.
time.gmtime     # Convert back to UTC.
time.getlocal   # Return a new Time object in local zone
time.getutc     # Return a new Time object in UTC
puts time.to_s
puts time.ctime
puts time.localtime
puts time.strftime("%Y-%m-%d %H:%M:%S")


print "*** ranges ","*"*60, "\n" 
score = 70
result = case score
   when 0..40 then "Fail"
   when 41..60 then "Pass"
   when 61..70 then "Pass with Merit"
   when 71..100 then "Pass with Distinction"
   else "Invalid Score"
end
puts result


print "*** iterators ","*"*60, "\n" 
a = [1,2,3,4,5]
b = a.collect{|x| 10*x}     
puts b                         # 10
                               # 20 ...


print "*** file ","*"*60, "\n" 
# new file http://www.tutorialspoint.com/ruby/ruby_input_output.htm
#aFile = File.new("filename", "mode")
   # ... process the file
#aFile.close
# open file r, r+, w -> overwrite, w+, a, a+  - append mode 
#File.open("filename", "mode") do |aFile|
#   # ... process the file
#end
=begin
File.zero?( "test.txt" )      # => true
File::ctime( "test.txt" )
File.size?( "text.txt" )     # => 1002
File::ftype( "test.txt" )     # => file
File.readable?( "test.txt" )   # => true
File.writable?( "test.txt" )   # => true
File.executable?( "test.txt" ) # => false
File::directory?( "/usr/local/bin" ) # => true
File.open("file.rb") if File::exists?( "file.rb" )
File.file?( "text.txt" ) 
=end

print "*** dir ","*"*60, "\n" 
Dir.chdir("/home/kuntuzangpo/Desktop/")
puts Dir.entries(Dir.pwd).join(' ')  # wite in line
Dir.foreach(Dir.pwd) do |entry|      # under each other
   puts entry
end
#Dir.mkdir( "mynewdir", 755 )
#Dir.delete("testdir")
require 'tmpdir'
   tempfilename = File.join(Dir.tmpdir, "tingtong")
   tempfile = File.new(tempfilename, "w")
   tempfile.puts "This is a temporary file"
   tempfile.close
   File.delete(tempfilename)
require 'tempfile'
   f = Tempfile.new('tingtong')
   f.puts "Hello"
   puts f.path
   f.close


=begin
def promptAndGet(prompt)
   print prompt
   res = readline.chomp
   throw :quitRequested if res == "!"
   return res
end
catch :quitRequested do
   name = promptAndGet("Name: ")
   age = promptAndGet("Age: ")
   sex = promptAndGet("Sex: ")
   # ..
   # process information
end
promptAndGet("Name:")
=end

=begin
Class Exception
    Interrupt
    NoMemoryError
    SignalException
    ScriptError
    StandardError
    SystemExit
=end 



class Box
   def initialize(w,h)
      @width, @height = w, h
   end
   def getArea
      getWidth() * getHeight
   end
   def getWidth
      @width
   end
   def getHeight
      @height
   end
   # make them private
   private :getWidth, :getHeight
   def printArea
      @area = getWidth() * getHeight
      puts "Big box area is : #@area"
   end
   # make it protected
   protected :printArea
end
box = Box.new(10, 20)
a = box.getArea()
puts "Area of the box is : #{a}"
#box.printArea()    # NoMethodError
# define a subclass
class BigBox < Box
   # add a new instance method
   def printArea
      @area = @width * @height
      puts "Big box area is : #@area"
   end
end
box = BigBox.new(10, 20)
box.printArea()

# operator overlaoding
class Box
  def initialize(w,h) # Initialize the width and height
    @width,@height = w, h
  end
  def +(other)         # Define + to do vector addition
    Box.new(@width + other.width, @height + other.height)
  end
  def -@               # Define unary minus to negate width and height
    Box.new(-@width, -@height)
  end
  def *(scalar)        # To perform scalar multiplication
    Box.new(@width*scalar, @height*scalar)
  end
end

# freezing objects, to prevent an object from being changed
class Box
   def initialize(w,h)
      @width, @height = w, h
   end
   def getWidth
      @width
   end
   def getHeight
      @height
   end
   def setWidth=(value)
      @width = value
   end
   def setHeight=(value)
      @height = value
   end
end
box = Box.new(10, 20)
# let us freez this object
box.freeze
if( box.frozen? )
   puts "Box object is frozen object"
else
   puts "Box object is normal object"
end
#box.setWidth = 30     # can't modify frozen Box
#box.setHeight = 50    # can't modify frozen Box
x = box.getWidth()
y = box.getHeight()
puts "Width of the box is : #{x}"
puts "Height of the box is : #{y}"



print "*** regex regular expression ","*"*60, "\n" 
line1 = "Cats are smarter than dogs";
if ( line1 =~ /Cats(.*)/ )
  puts "Line1 contains Cats"
end
phone = "2004-959-559 #This is Phone Number"
phone = phone.sub!(/#.*$/, "")   
puts "Phone Num : #{phone}"      # Phone Num : 2004-959-559
phone = phone.gsub!(/\D/, "")    
puts "Phone Num : #{phone}"      # Phone Num : 2004959559
text = "rails are rails, really good Ruby on Rails"
# Change "rails" to "Rails" throughout
text.gsub!("rails", "Rails")
puts "#{text}"


print "*** web app cgi ","*"*60, "\n" 
#http://www.tutorialspoint.com/ruby/ruby_web_applications.htm
require 'cgi'
cgi = CGI.new
puts cgi.header
puts "<html><body>This is a test</body></html>"
h = cgi.params  # =>  {"FirstName"=>["Zara"],"LastName"=>["Ali"]}
h['FirstName']  # =>  ["Zara"]
h['LastName']   # =>  ["Ali"]
cgi.keys

cgi = CGI.new("html4")
cgi.out{
   cgi.html{
      cgi.head{ "\n"+cgi.title{"This Is a Test"} } +
      cgi.body{ "\n"+
         cgi.form{"\n"+
            cgi.hr +
            cgi.h1 { "A Form: " } + "\n"+
            cgi.textarea("get_text") +"\n"+
            cgi.br +
            cgi.submit
         }
      }
   }
}

=begin
# http://www.tutorialspoint.com/ruby/ruby_sending_email.htm
require 'net/smtp'
message = <<MESSAGE_END
From: Private Person <me@fromdomain.com>
To: A Test User <test@todomain.com>
MIME-Version: 1.0
Content-type: text/html
Subject: SMTP e-mail test

This is an e-mail message to be sent in HTML format

<b>This is HTML message.</b>
<h1>This is headline.</h1>
MESSAGE_END
Net::SMTP.start('localhost') do |smtp|
  smtp.send_message message, 'me@fromdomain.com', 
                             'rudolfvavra@gmail.com'
end
=end


# http://ruby-doc.org/stdlib-2.2.2/libdoc/socket/rdoc/index.html
# http://www.tutorialspoint.com/ruby/ruby_socket_programming.htm

# xml
# http://www.tutorialspoint.com/ruby/ruby_xml_xslt.htm

# soap, web services
# http://www.tutorialspoint.com/ruby/ruby_web_services.htm


# standart graphical user interface for Ruby is Tk. 
# http://www.tutorialspoint.com/ruby/ruby_tk_guide.htm
=begin
require 'tk'
root = TkRoot.new { title "Hello, World!" }
TkLabel.new(root) do
   text 'Hello, World!'
   pack { padx 15 ; pady 15; side 'left' }
end
Tk.mainloop
=end


# multifhreading
def func1
   i=0
   while i<=2
      puts "func1 at: #{Time.now}"
      sleep(2)
      i=i+1
   end
end
def func2
   j=0
   while j<=2
      puts "func2 at: #{Time.now}"
      sleep(1)
      j=j+1
   end
end
puts "Started At #{Time.now}"
t1=Thread.new{func1()}
t2=Thread.new{func2()}
t1.join
t2.join
puts "End at #{Time.now}"
#func1 at: 2015-07-05 21:21:30 +0200
#func2 at: 2015-07-05 21:21:30 +0200
#func2 at: 2015-07-05 21:21:31 +0200
#func1 at: 2015-07-05 21:21:32 +0200
#func2 at: 2015-07-05 21:21:32 +0200
#func1 at: 2015-07-05 21:21:34 +0200








