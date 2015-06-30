class CountSubStrings:

  def __init__(self):
    """Counts subsrtrings in string"""
    check_string = "i am checking this string to see how many times each character appears"
    chars=""
    for i in range(1,2100):
      chars+="%s" % unichr(i)
    self.count(check_string,chars)

  def count(self,check_string,chars):
    count = {}
    for s in check_string:
      if s != " ":
        if count.has_key(s):
          count[s] += 1
        else:
          count[s] = 1

    for key in count:
      if count[key] > 1:
        print key, count[key]

if __name__=="__main__":
  CountSubStrings()


