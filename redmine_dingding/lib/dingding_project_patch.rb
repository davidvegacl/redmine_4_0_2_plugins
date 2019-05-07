module DingdingProjectPatch

  def self.included(base)
    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_one :dingding
    
    end


  end

end