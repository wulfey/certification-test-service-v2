class Plan
# not subclassing off active record base because there will be no plans table

    PLANS = [:free, :premium]
    
    def self.options
        PLANS.map { |plan| [plan.capitalize, plan] }    
    end
    # map modifies all elements in an array taht you pas
    # this modifies all plans to be capitalized
    
end