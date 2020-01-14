#·const.py

class _const:
    class Err(TypeError): pass
    def __setattr__(self, name, value):
      if name in self.__dict__:
         raise type(self).Err('Cannot rebind const.%s' % name)
      self.__dict__[name]=value
    def __delattr__(self, name):
         raise type(self).Err('Cannot delete const.%s' % name)
    def __init__(self):
      self.Err = ... # need to hide the class attribute

import sys
sys.modules[__name__]=_const()
