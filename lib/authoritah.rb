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
        actions = options.delete(action_identifier)
        
        check_role_selectors(options)
        
        role_method     = options.first[0]
        role_predicate  = options.first[1]
        
        controller_permissions[controller_name.to_sym] ||= PermissionSet.new
        controller_permissions[controller_name.to_sym] <<
          {:type => perm_type, :role_method => role_method, :role_predicate => role_predicate, :actions => actions ? Array(actions) : nil}
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
        return true if permitted?(action_name.to_sym)
        render(:file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404) 
        false
      end
      
      protected
      
        def permitted?(action)
          return true unless permissions = self.class.this_controllers_permissions
          permissions.permits?(self, action) && !permissions.forbids?(self, action)
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
        apply_rules(:permit, controller, action).include?(false) == false
      end

      def forbids?(controller, action)
        apply_rules(:forbid, controller, action).include?(true)
      end
      
      def permissions
        @permissions ||= []
      end
      
      protected
      
        def apply_rules(rule_type, controller, action)
          permissions.select{|p| 
            p[:type] == rule_type
          }.select{|p| 
            p[:actions].include?(action) || p[:actions].include?(:all)
          }.map do |permission|
            begin
              if permission[:role_predicate].is_a? Symbol
                controller.send(permission[:role_method]).send(permission[:role_predicate])
              elsif permission[:role_predicate].is_a? Proc
                permission[:role_predicate].call(controller.send(permission[:role_method]))
              else
                false
              end
            rescue
              false
            end
          end
        end
    end
    
  end
end