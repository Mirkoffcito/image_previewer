
module ActionDispatch
  def route(target)
    if target.is_a?(String) && target.include?("#")
      ctrl_name, action = target.split("#", 2)
      class_name = ctrl_name
                      .split("_")
                      .map(&:capitalize)
                      .join + "Controller"

      ctrl_klass = Object.const_get(class_name)
      ctrl       = ctrl_klass.new(self)
      ctrl.public_send(action)

      # return the Rack triplet
      res.finish
    end
  end
end

