require "forwardable"

module Controllable
  def self.included(base)
    base.extend Forwardable

    # Delegate all the Cuba‑context bits to @context
    base.def_delegators :@context,
      :req, :res, :session, :csrf, :settings,
      :view, :render

    # Auto‑inject an initializer so you never write it again
    base.class_eval do
      def initialize(context)
        @context = context
      end

      def params
        deep_transform_keys(req.params) { |key| key.to_s }
      end

      def render_view(name, locals = {})
        res.write view(name, locals)
      end

      def deep_transform_keys(obj, &block)
        case obj
        when Hash
          obj.each_with_object({}) do |(k,v), h|
            h[yield(k)] = deep_transform_keys(v, &block)
          end
        when Array
          obj.map { |e| deep_transform_keys(e, &block) }
        else
          obj
        end
      end

      private :params, :render_view, :deep_transform_keys
    end
  end
end
