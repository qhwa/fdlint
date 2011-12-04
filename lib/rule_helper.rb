module XRay
  module RuleHelper
    
    def dispatch(items, node)
      results = []
      items.each do |item|
        result = self.send(item, node)
        result && (results << result.flatten)
      end
      results
    end

  end
end
