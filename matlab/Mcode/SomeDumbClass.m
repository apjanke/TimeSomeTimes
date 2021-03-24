classdef SomeDumbClass
  
  properties
    foo
    barWithSetter
    charProperty char
    charvecProperty (1,:) char
  end
  
  methods
    
    function this = set.barWithSetter(this, x)
      this.barWithSetter = x;
    end
    
  end
  
end