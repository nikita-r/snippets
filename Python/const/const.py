#·const.py

class _const:
    class Err(TypeError): pass
    def __setattr__(self, name, value):
      # if self.__dict__.has_key(name):
        if name in self.__dict__:
            raise self.Err('Cannot rebind const.%s' % name)
        self.__dict__[name]=value
   #def __delattr__ ?

import sys
sys.modules[__name__]=_const()
