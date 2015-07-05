#!/usr/bin/ruby

# Module defined in moral.rb file

module Moral
   VERY_BAD = 0
   BAD = 1
   def Moral.sin(badness)
    puts badness
   end
end

module Week
   FIRST_DAY = "Sunday"
   def Week.weeks_in_month
      puts "You have four weeks in a month"
   end
   def Week.weeks_in_year
      puts "You have 52 weeks in a year"
   end
end

# Mixins - multiple inheritance directly . Mixins give you a wonderfully controlled way of adding functionality to classes . However, their true powe comes out when the code in the mixin starts to interact with code in hte class that uses it.
module A
   def a1
   end
   def a2
   end
end
module B
   def b1
   end
   def b2
   end
end

class Sample
include A
include B
   def s1
   end
end

samp=Sample.new
samp.a1
samp.a2
samp.b1
samp.b2
samp.s1




