classdef SomeDumbClass
  
  properties
    foo
    barWithSetter
  end
  
  methods
    
    function this = set.barWithSetter(this, x)
      this.barWithSetter = x;
    end
    
  end
  
end