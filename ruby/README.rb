
require(ENV['HOME']+'/code/network/ruby/README.rb')

# https://ruby-hacking-guide.github.io/
# ruby -e 'p("content")'
p('content'.upcase())
p('MAKE IT SMALL'.downcase())

$gval = "Global variable"
class A
  @@cvar = "Class variable"
  def initialize()
    @i = "ok"
  end
end
class B < A
  def print_i()
    p(@i)
    p(" AHoj: #{@@cvar}")
  end
end
B.new().print_i()  # Shows 'ok' \n 'Ahoj: Class Variable'

module M
  def myupcase(str)
    return str.upcase()
  end
end
class C
  include M
end
p(C.new().myupcase("content"))   # CONTENT

module OneMore
  def method_OneMore()
    p("OneMore")
  end
end
module M2
  include OneMore
  def method_M2()
    p('M2')
  end
end
class C
  include M2
end
C.new().method_M2()           # M
C.new().method_OneMore        # OneMore

class Cls
  def test()
    return "CLS"
  end
end
module Mod
  def test()
    return "MOD"
  end
end
class C2 < Cls
  include Mod
end
p(C2.new().test())   # MOD

class SomeClass
  Const1 = 3
end
p(::SomeClass::Const1)  # 3
p(SomeClass::Const1)


module Net
  class SMTP
  end
  class POP
  end
  class HTTP
    
  end
end

Const = "far"
class C3
  Const = "near"
  class C4
    p(Const)    # near
  end 
end

module M5
end
p(M.class())   # Module is shown

p(Class.superclass())    # Module
p(Module.superclass())   # Object
p(Object.superclass())   # BasicObject   (NIl in another version )

#Up to now we used `new` and `include` without any explanation, but finally I can explain their true form. `new` is really a method defined for the class `Class`. Therefore on whatever class, (because it is an instance of `Class`), `new` can be used immediately. But `new` isn’t efined in `Module`. Hence it’s not possible to create instances in a module. And since `include` is defined in the `Module` class, it can be called on both modules and classes.

#These three classes `Object`, `Module` and `class` are objects that support the foundation of Ruby. We can say that these three objects describe the Ruby’s object world itself. Namely they are objects which describe objects. Hence, `Object Module Class` are Ruby’s “meta-objects”.

obj = Object.new()
def obj.my_first()
  puts("My first singleton method")
end
obj.my_first()


# File.unlink("core")  # deletes the coredump


p(%q(string))       # string
%Q(string)         # string
%(string)          # string
$path=ENV['HOME']
p("<a href=\"http://i.loveruby.net#{$path}\">")
p(%Q(<a href="http://escapingAll.net#{$path}">))   # "<a href=\"http://escapingAll.net/home/kuntuzangmo\">"

<<EOS
Hello World
listen
EOS


arr = [0,2,4,6,8]
arr.each do |item|
  p(item)
end
# add definition to the Array class
class Array
  def my_each
    i = 0
    while i < self.length
      yield self[i]
      i += 1
    end
  end
end
arr.my_each do |i|
  p(i)
end


twice = Proc.new {|n| n * 2 }
p twice.call(9)    # 18
twice = lambda {|n| n * 2 }

block = Proc.new { |i| p i}
[0,1,2].each(&block)
[0,1,2].each {|i| p i}


key = 1
p("def #{defined?(key)}  ined")   # "def local-variable  ined"

class C
  def i() @i end          # A method definition can be written in one line.
  def i=(n) @i = n end
end
obj = C.new
obj.i = 1
obj.i += 2    # obj.i = obj.i + 2
p obj.i       # 3

#process() while have_content?
#sleep(1) until ready?

class << obj
  p self  #=> #<Class:#<Object:0x40156fcc>>   # Singleton Class 「(obj)」
  def a() end   # def obj.a
  def b() end   # def obj.b
end

# it can be infinitely nested
a, b, c = [1, 2, 3]
a, (b, c, d) = [1, [2, 3, 4]]
a, (b, (c, d)) = [1, [2, [3, 4]]]
(a, b), (c, d) = [[1, 2], [3, 4]]


#array.each do |i|
#end
#hash.each do |key, value|
#end

# nested hashed
# [[key,value],index] are yielded
hash.each_with_index do |(key, value), index|
  #....
end

class C
  alias new orig
end

class C
  undef method_name
end


