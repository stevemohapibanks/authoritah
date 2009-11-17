module Authoritah
  module Controller

    class OptionsError < StandardError
      def initialize(message)
        super(message)
      end
    end

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
      
      base.before_filter :check_permissions
    end
    
    module ClassMethods
      
      def permits(*args)
        apply_declaration(:permit, :to, args)
      end
      
      def forbids(*args)
        apply_declaration(:forbid, :from, args)
      end
      
      def apply_declaration(perm_type, action_identifier, args)
        options = args.extract_options!
        args.each {|a| options[a] = nil}
        actions = options.delete(action_identifier)
        on_reject = options.delete(:on_reject) || :render_404
        
        raise ":on_reject must be a symbol or a Proc" unless on_reject.is_a?(Symbol) || on_reject.is_a?(Proc)
        
        check_role_selectors(options)

        role_method     = options.to_a.first[0]
        role_predicate  = options.to_a.first[1]
        
        controller_permissions[controller_name.to_sym] ||= PermissionSet.new
        controller_permissions[controller_name.to_sym] << {
          :type => perm_type,
          :role_method => role_method,
          :role_predicate => role_predicate,
          :actions => actions ? Array(actions) : nil,
          :on_reject => on_reject
        }
      end
      
      def this_controllers_permissions
        controller_permissions[controller_name.to_sym]
      end
      
      protected
      
        def check_role_selectors(options)
          raise Authoritah::Controller::OptionsError.new("Too many role selectors") if options.size > 1
        end
        
        def controller_permissions
          @@controller_permissions ||= {}
        end
        
        def clear_permissions
          @@controller_permissions = {}
        end
    end
    
    module InstanceMethods

      def check_permissions
        permitted?(action_name.to_sym)
      end
      
      protected
      
        def render_404
          render(:file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404)
        end
      
        def permitted?(action)
          return true unless permissions = self.class.this_controllers_permissions
          permissions.permits?(self, action)
        end
    end
    
    class PermissionSet
      
      def <<(permission_hash)
        permission_hash[:actions] = [:all] unless permission_hash[:actions]
        permissions << permission_hash
      end
      
      def size
        permissions.size
      end
      
      def first
        permissions.first
      end
      
      def permits?(controller, action)
        permitted, on_reject_action = apply_rule_chain(:permit, controller, action)
        if permitted
          return true
        else
          if on_reject_action.is_a?(Proc)
            controller.instance_eval(&on_reject_action)
          else
            controller.send(on_reject_action)
          end
          return false
        end
      end

      def permissions
        @permissions ||= []
      end
      
      protected
        
        # Returns [true, nil] if the rule chain applied without a problem.
        # Returns [false, :reject_to destination] otherwise
        def apply_rule_chain(rule_type, controller, action)
          select_permissions_for(action).each do |permission|
            begin
              response = if permission[:role_predicate].is_a? Symbol
                controller.send(permission[:role_method]).send(permission[:role_predicate])
              elsif permission[:role_predicate].is_a? Proc
                controller.instance_exec(controller.send(permission[:role_method]), &permission[:role_predicate])
              elsif permission[:role_predicate] == nil
                controller.send(permission[:role_method])
              end
              response = !response if permission[:type] == :forbid
              return [false, permission[:on_reject]] unless response
            rescue
              return [permission[:type] == :forbid, permission[:on_reject]]
            end
          end
          [true, nil]
        end
                
        def select_permissions_for(action)
          permissions.select{|p| 
             p[:actions].include?(action) || p[:actions].include?(:all)
           }
        end
    end
    
  end
end

ActionController::Base.send(:include, Authoritah::Controller)