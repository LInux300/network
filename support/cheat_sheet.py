# examples of python

print [i for i in range(10) if i % 2 == 0]  # [0, 2, 4, 6, 8]

print "---- Tuples"
tup1 = ('physics', 'chemistry', 1997, 2000);
print "tup1[1:5]: ", tup1[1:5]
tuple1, tuple2 = (123, 'xyz'), (456, 'abc')
print "compare tuples: %s " % cmp(tuple1, tuple2);             # -1 different         
tuple1, tuple2 = (123, 'xyz', 'zara', 'abc'), (456, 700, 200)
print "Max value element : ", max(tuple1);                      # zara
print "Max value element : ", min(tuple2);                      # 200
a = (1, 2, 3)
b = a + (4, 5, 6)
c = b[1:]
print "print c tuple:", c                       # print c tuple: (2, 3, 4, 5, 6)
aList = [123, 'xyz', 'zara', 'abc'];
print type(aList)                               # <type 'list'>
aTuple = tuple(aList)                           # convert into list
print type(aTuple)                              # <type 'tuple'>
for i, v in enumerate(['tic', 'tac', 'toe']):
    print i, v

print "singleton"
singleton = 'hello',
print type(singleton)                   # <type 'tuple'>

print "Dictionaries"
tel = {'jack': 4098, 'sape': 4139}
tel['guido'] = 4127
print "dictionary:", tel                # {'sape': 4139, 'jack': 4098, 'guido': 4127}
knights = {'gallahad': 'the pure', 'robin': 'the brave'}
for k, v in knights.iteritems():
      print k, v

print "Array"
myArray = ['d', [1.0, 2.0, 3.14], 3 ,u'hello \u2641']
myArray.insert(2, 'x')
print "myArray:", myArray
print "myArray:", type(myArray)    # myArray: ['d', [1.0, 2.0, 3.14], 'x', 3, u'hello \u2641']
from array import array
myArray2 = array('d', [1.0, 2.0, 3.14])
print "myArray2:", myArray2     # myArray2: array('d', [1.0, 2.0, 3.14])
myArray2.reverse()
print "myArray2 reverse:", myArray2     # myArray2: array('d', [3.14, 2.0, 1.0])
myArray2.tostring()
print "myArray2 to string:", myArray2     
myArray2.tolist()
print "myArray2 to list:", myArray2     

print "----List"
a = [66.25, 333, 333, 1, 1234.5]
print a.count(333), a.count(66.25), a.count('x') # 2 1 0
a.insert(2, -1)
a.append(333)     # [66.25, 333, -1, 333, 1, 1234.5, 333]
print "Index: %s " % a.index(333)      # 1
a.remove(333) 
print "Remove 333: %s " % a      #[66.25, -1, 333, 1, 1234.5, 333] 
a.reverse()  
print a                 # [333, 1234.5, 1, 333, -1, 66.25]
a.sort()
print a             #[-1, 1, 66.25, 333, 333, 1234.5]
a.pop()             # Remove the item at the given position in the list, and return it. If no index is specified last one


i=iter('abc')
print i.next()    # a
print i.next()    # b


class MyIterator(object):
    def __init__(self, step):
        self.step = step
    def next(self):
        """Returns the next element."""
        if self.step == 0:
            raise StopIteration
        self.step -= 1
        return self.step
    def __iter__(self):
        """Returns the iterator itself."""
        return self
for el in MyIterator(4):
    print el    # 3 2 1 0


print 20*"-" + " Fibonacci" + "-"*20  
def fibonacci():
    a, b = 0, 1
    while True:
        yield b
        a, b = b, a + b
fib = fibonacci()
#for i in range(1,20):
#    print fib.next()
print [fib.next() for i in range(10)]


print 20*"-" + " Yield " + "-"*20  
#Yield is a keyword that is used like return, except the function will return a generator
def my_generator():
    try:
        yield 'something'
    except ValueError:
        yield 'dealing with the exception'
    finally:    # will catch any close claa or throw call, recommended way to do some cleanup
        print "ok let's clean"
myGen= my_generator()
#myGen.next()  # run in the end
#myGen.throw()
#myGen.close()


import itertools
print 20*"-" + " Itertools " + "-"*20  
horses = [1, 2, 3, 4]
races = itertools.permutations(horses)
print(races)        # print object
print(list(itertools.permutations(horses))) # print list

"""
import multitask
import time
def coroutine_1():
    for i in range(3):
        print 'c1'
        yield i
def coroutine_2():
    for i in range(3):
        print 'c2'
        yield i
multitask.add(coroutine_1())
multitask.add(coroutine_2())
multitask.run()
"""

myIter = (x*x for x in range(10) if x %2 ==0)
for i in myIter:
    print i         # 0,4, 16, 36, 64

print "Decorators to make function and method wrapping (a function that receives a function and returns an enhanced one)"
class WhatFor(object):
    @classmethod
    def it(cls):
        print 'work with %s' % cls
    #it = classmethod(it)
    @staticmethod
    def uncommon():
        print 'I could be a global function'
myWhatFor = WhatFor()
myWhatFor.it()
myWhatFor.uncommon()


print "Meta Descriptor - use one or more methods in the hosting class to perform the task"
class Chainer(object):
    def __init__(self, methods, callback=None):
        self._methods = methods
        self._callback = callback
    def __get__(self, instance, klass):
        if instance is None:
            # only for instances
            return self
        results = []
        for method in self._methods:
            results.append(method(instance))
            if self._callback is not None:
                if not self._callback(instance,method,results):
                    break
        return results
class TextProcessor(object):
    def __init__(self, text):
        self.text = text
    def normalize(self):
        if isinstance(self.text, list):
            self.text = [t.lower() for t in self.text]
        else:
            self.text = self.text.lower()
    def split(self):
        if not isinstance(self.text, list):
            self.text = self.text.split()
    def treshold(self):
        if not isinstance(self.text, list):
            if len(self.text) < 2:
                self.text = ''
        self.text = [w for w in self.text if len(w) > 2]
def logger(instance, method, results):
    print 'calling %s' % method.__name__
    return True
def add_sequence(name, sequence):
    setattr(TextProcessor, name,
        Chainer([getattr(TextProcessor, n) for n in sequence], logger))
add_sequence('simple_clean', ('split', 'treshold'))
my = TextProcessor(' My Taylor is Rich ')
my.simple_clean
print my.text               # ['Taylor', 'Rich']


print "-"*30 + "Properties"
class MyClass(object):
    def __init__(self):
        self._my_secret_thing = 1
    def _i_get(self):
        return self._my_secret_thing
    def _i_set(self, value):
        self._my_secret_thing = value
    def _i_delete(self):
        print 'neh!'
    my_thing = property(_i_get, _i_set, _i_delete, 'the thing')
myclass = MyClass()
print myclass.my_thing      # 1
myclass.my_thing=3          
print myclass.my_thing      # 3
del myclass.my_thing        # neh!
#help(myclass)              # Methods defined here: __init__, __dict__, __weakref__, my_thing

print "__new__ is meta-constructor. It is called every time an object has to be instantiated by the class factory"
class MyClass2(object):
    def __new__(cls):
        print '__new__ called'
        return object.__new__(cls) # default factory
    def __init__(self):
        print '__init__ called'
        self.a = 1
insMyClass2 = MyClass2()          # __new__ called
                                  # __init__ called
#help(insMyClass2)

class MyClass3(object):
    def __new__(cls):
        return [1,2,3]
myMyClass3 = MyClass3()
print myMyClass3                    # [1,2,3]
print myMyClass3.__new__            # object
#help(myMyClass3.__new__ )          #
myMyClass3.__add__ 
print myMyClass3                    # [1,2,3]
#help(myMyClass3)                    # 

#Meta-programming is very powerful, but remember that is obfuscales the readability of the class design

print "*"*30 + "Super"
class Card:
    def __init__( self, rank, suit, hard, soft ):
        self.rank= rank
        self.suit= suit
        self.hard= hard
        self.soft= soft
class NumberCard( Card ):
    def __init__( self, rank, suit ):
        super().__init__( str(rank), suit, rank, rank )



def foo(*positional, **kwargs):
    print "Positional:", positional
    print "Keywords:", kwargs
    for key, value in kwargs.iteritems():
        print key, value
print foo('one', 'two', 'three')        # Positional: ('one', 'two', 'three')
                                        # Keywords: a{}
foo(a='one', b='two', c='three')  # Positional: ()
                                        # Keywords: {'a': 'one', 'c': 'three', 'b': 'two'}
foo('one','two',c='three',d='four')   # Positional: ('one', 'two')
                                            # Keywords: {'c': 'three', 'd': 'four'}
def func(a='a', b='b', c='c', **kwargs):
    print 'a:%s, b:%s, c:%s' % (a, b, c)
func(**{'a' : 'z', 'b':'q'})                # a:z, b:q, c:c
func(a = 'z', b = 'q')                      # a:z, b:q, c:c

class MyCard:
    def __init__( self, dealer_card, *cards ):
        self.dealer_card= dealer_card
        self.cards= list(cards)
    def __str__( self ):
        return "-".join( map(str, self.cards) )
    def __repr__(self):
        return 'reprruda'
myCard = MyCard(123,'456', 2345, 'abc')    
print myCard                # 456-2345-abc
print myCard.__repr__       #<bound method MyCard.__repr__ of reprruda>
print hash(myCard)          # 8740707558329


print "------------------------ super --------------------"
class Card2(object):
    insure= False
    def __init__( self, rank, suit, hard, soft ):
        self.rank= rank
        self.suit= suit
        self.hard= hard
        self.soft= soft
    def __repr__( self ):
        return "{__class__.__name__}(suit={suit!r}, rank={rank!r})". format(__class__=self.__class__, **self.__dict__)
    def __str__( self ):
        return "{rank}{suit}".format(**self.__dict__)
    def __eq__( self, other ):
        return self.suit == other.suit and self.rank == other.rank
    def __hash__( self ):
        return hash(self.suit) ^ hash(self.rank)
class AceCard2( Card2 ):
    insure= True
    def __init__( self, rank, suit ):
        super(AceCard2, self).__init__( "A", suit, 1, 11 )
c1 = AceCard2( 1, 'qw' )
c2 = AceCard2( 1, 'qw' )
print "Super class card1: %s \t card2: %s" % (id(c1), id(c2) )
print "Print if inside: ", (  c1 is c2 )


print "------------------------ __lt__ --------------------"
class BlackJackCard_p(object):
    def __init__( self, rank, suit ):
        self.rank= rank
        self.suit= suit
    def __lt__( self, other ):
        print( "Compare {0} < {1}".format( self, other ) )
        return self.rank < other.rank
    def __str__( self ):
        return "{rank}{suit}".format( **self.__dict__ )
two = BlackJackCard_p( 2, 'l' )
three = BlackJackCard_p( 3, 'l' )
print two < three           # True
print two > three           # False
class BlackJackCard(object):
    def __init__( self, rank, suit, hard, soft ):
        self.rank= rank
        self.suit= suit
        self.hard= hard
        self.soft= soft
    def __lt__( self, other ):
        if not isinstance( other, BlackJackCard ): return NotImplemented
        return self.rank < other.rank
    def __le__( self, other ):
        try:
            return self.rank <= other.rank
        except AttributeError:
            return NotImplemented
    def __gt__( self, other ):
        if not isinstance( other, BlackJackCard ): return NotImplemented
        return self.rank > other.rank
    def __ge__( self, other ):
        if not isinstance( other, BlackJackCard ): return NotImplemented
        return self.rank >= other.rank
    def __eq__( self, other ):
        if not isinstance( other, BlackJackCard ): return NotImplemented
        return self.rank == other.rank and self.suit == other.suit
    def __ne__( self, other ):
        if not isinstance( other, BlackJackCard ): return NotImplemented
        return self.rank != other.rank and self.suit != other.suit
    def __str__( self ):
        return "{rank}{suit}".format( **self.__dict__ )

two2 = BlackJackCard( 2, 'l','h','s' )
three2 = BlackJackCard( 3, 'l','h','s' )
print two2 < three2           # True
print two2 == three2           # False
#help(BlackJackCard)

print "This create immutable objects"
class BlackJackCard3( tuple ):
    def __getattr__( self, name ):
        return self[{'rank':0, 'suit':1, 'hard':2 ,'soft':3}[name]]
    def __setattr__( self, name, value ):
        raise AttributeError
d = BlackJackCard3( ('A', 'l', 1, 11) )
print d.rank            # 'A'
print d.suit              # 'l
#d.hard= 2              # error

""" not working properly
class BlackJackCard4( tuple ):
    def __new__( cls, rank, suit, hard, soft ):
        return super().__new__( cls, (rank, suit, hard, soft) )
    def __getattr__( self, name ):
        return self[{'rank':0, 'suit':1, 'hard':2 ,'soft':3}[name]]
    def __setattr__( self, name, value ):
        raise AttributeError
d = BlackJackCard4( 'A', 'l', 1, 11 )
print d.rank            # 'A'
print d.suit              # 'l
"""

class Rectangle(object):
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.area = width * height
class Square(Rectangle):
    def __init__(self, length):
        super(Square, self).__init__(length, length)  # super() executes fine now
r = Rectangle(4,5)
print r.area  # 20 
s = Square(5)
print s.area  # 25
# the same as above without super 
class Rectangle2(object):
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.area = width * height
class Square2(Rectangle2):
    def __init__(self, length):
        Rectangle2.__init__(self, length, length)  # super() executes fine now
r = Rectangle2(4,5)
print r.area  # 20 
s = Square2(5)
print s.area  # 25


class entryExit(object):
    def __init__(self, fu):
        self.fu = fu
    def __call__(self):
        print "Entering", self.fu.__name__
        self.fu()
        print "Exited", self.fu.__name__
@entryExit
def func1():
    print "inside func1()"
@entryExit
def func2():
    print "inside func2()"
func1()     # Entering func1
            # inside func1()
            # Exited func1
#func2()


class RateTimeDistance( dict ):
    def __init__( self, *args, **kw ):
        super(RateTimeDistance, self).__init__( *args, **kw )
        self._solve()
    def __getattr__( self, name ):
        return self.get(name,None)
    def __setattr__( self, name, value ):
        self[name]= value
        self._solve()
    def __dir__( self ):
        return list(self.keys())
    def _solve(self):
        if self.rate is not None and self.time is not None:
            self['distance'] = self.rate*self.time
        elif self.rate is not None and self.distance is not None:
            self['time'] = self.distance / self.rate
        elif self.time is not None and self.distance is not None:
            self['rate'] = self.distance / self.time
rtd= RateTimeDistance( rate=6.3, time=8.25, distance=None )
print( "Rate={rate}, Time={time}, Distance={distance}".format(**rtd ) )  #Rate=6.3, Time=8.25, Distance=51.975






