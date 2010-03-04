require File.dirname(__FILE__) + '/spec_helper'
require 'ruby-debug'
describe Authoritah::Controller do
  
  before(:each) do
    ActionController::Base.send(:include, Authoritah::Controller)
    ActionController::Base.send(:clear_permissions)
    TestAuthorizerController.send(:clear_permissions)
    SpecialisedTestAuthorizerController.send(:clear_permissions)
  end
  
  describe "adding methods to controllers" do
    it "should add an permits method to the controller" do
      ActionController::Base.methods.should include('permits')
    end

    it "should add a forbids method to the controller" do
      ActionController::Base.methods.should include('forbids')
    end

    it "should add a before_filter to check permissions to the controller" do
      ActionController::Base.before_filters.should include(:check_permissions)
    end
  end
  
  it "should raise an error if too many role selectors specified" do
    lambda do
      TestAuthorizerController.permits(:current_user => :logged_in?, :another_user => :logged_out?)
    end.should raise_error(Authoritah::Controller::OptionsError)
  end
  
  describe "a basic permits wildcard rule with no predicate" do
    before(:each) do
      TestAuthorizerController.permits(:current_user)
      @permissions = TestAuthorizerController.send(:controller_permissions)
    end
    it "should have one permission" do @permissions.size.should == 1 end
    it "should use current_user to retrieve the 'role object'" do @permissions.first[:role_method].should == :current_user end
    it "should have nil predicate method" do @permissions.first[:role_predicate].should == nil end
    it "should not specify the actions" do @permissions.first[:actions].should == [:all] end
  end
    
  describe "a basic permits wildcard rule" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?)
      @permissions = TestAuthorizerController.send(:controller_permissions)
    end
    it "should have one permission" do
      @permissions.size.should == 1 
    end
    it "should use current_user to retrieve the 'role object'" do @permissions.first[:role_method].should == :current_user end
    it "should use logged_in? as the predicate to call on the 'role object'" do @permissions.first[:role_predicate].should == :logged_in? end
    it "should not specify the actions" do @permissions.first[:actions].should == [:all] end
  end

  describe "a basic permits rule on a single action" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?, :to => :show)
      @permissions = TestAuthorizerController.send(:controller_permissions)
    end
    it "should have one permission" do @permissions.size.should == 1 end
    it "should use current_user to retrieve the 'role object'" do @permissions.first[:role_method].should == :current_user end
    it "should use logged_in? as the predicate to call on the 'role object'" do @permissions.first[:role_predicate].should == :logged_in? end
    it "should specify the action" do @permissions.first[:actions].should == [:show] end
  end

  describe "a basic rule on many actions" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?, :to => [:show, :create, :update])
      @permissions = TestAuthorizerController.send(:controller_permissions)
    end
    it "should specify the actions" do @permissions.first[:actions].should == [:show, :create, :update] end
  end
end

describe TestAuthorizerController, :type => :controller do

  before(:each) do
    TestAuthorizerController.send(:include, Authoritah::Controller)
    TestAuthorizerController.send(:clear_permissions)
    SpecialisedTestAuthorizerController.send(:include, Authoritah::Controller)
    SpecialisedTestAuthorizerController.send(:clear_permissions)
  end
  
  context "with no permissions set " do
    it "should render the index" do get :index; response.should render_template('index') end
  end
  
  it "should inherit rules in a subclass" do
    class ParentController < ActionController::Base
      include Authoritah::Controller
      permits :current_user
    end
    class ChildController < ParentController
    end
    ChildController.controller_permissions.size.should == 1
    ChildController.controller_permissions.first[:role_method].should == :current_user
  end
  
  describe "specifying permit rules" do
    context "with a wildcard permission (no predicate)" do
      before(:each) do
        TestAuthorizerController.permits(:current_user)
      end

      context "a user exists" do
        before(:each) do
          controller.stubs(:current_user => true)
        end
        it "should render index" do
          get :index
          response.should render_template('index')
        end
      end
      context "an unauthenticated user" do
        before(:each) do
          controller.stubs(:current_user => false)
        end
        it "should receive a 404" do
          get :index
          response.status.should == "404 Not Found"
          response.should render_template(File.join(RAILS_ROOT, 'public', '/404.html'))
        end
      end
    end
    
    context "with a wildcard permission" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?)
      end

      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should render index" do
          get :index
          response.should render_template('index')
        end
      end
      context "an unauthenticated user" do
        before(:each) do
          controller.stubs(:current_user => false)
        end
        it "should receive a 404" do
          get :index
          response.status.should == "404 Not Found"
          response.should render_template(File.join(RAILS_ROOT, 'public', '/404.html'))
        end
      end
    end

    context "with a single permitted action" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?, :to => :create)
      end

      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should permit POST create" do post :create; response.should redirect_to('/success') end
        it "should render index" do get :index; response.should render_template('index') end
      end
      context "an unauthenticated user" do
        before(:each) do
          controller.stubs(:current_user => false)
        end
        it "should receive a 404 when POST create" do
          post :create
          response.status.should == "404 Not Found"
          response.should render_template(File.join(RAILS_ROOT, 'public', '/404.html'))
        end
        it "should render the index" do get :index; response.should render_template('index') end
      end
    end

    context "with a multiple permitted actions" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?, :to => [:create, :show, :index])
      end

      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should permit create" do post :create; response.should redirect_to('/success') end
        it "should render index" do get :index; response.should render_template('index') end
      end
      context "an unauthenticated user" do
        before(:each) do
          controller.stubs(:current_user => false)
        end
        it "should receive a 404 when POST create" do
          post :create
          response.status.should == "404 Not Found"
          response.should render_template(File.join(RAILS_ROOT, 'public', '/404.html'))
        end
        it "should receive a 404" do get :index; response.status.should == "404 Not Found" end
      end
    end
  end
  
  describe "specifying forbid rules" do
    context "with a wildcard forbid" do
      before(:each) do
        TestAuthorizerController.forbids(:current_user => :blacklisted?)
      end
      context "a blacklisted user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true, :blacklisted? => true))
        end
        it "should receive a 404" do
          get :index
          response.status.should == "404 Not Found"
          response.should render_template(File.join(RAILS_ROOT, 'public', '/404.html'))
        end
      end
      context "an unauthenticated user" do
        before(:each) do
          controller.stubs(:current_user => false)
        end
        it "should render index" do get :index; response.should render_template('index') end
      end
    end
  end
  
  describe "specifying a combination of permit and forbid rules" do
    context "with a wildcard forbid" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?)
        TestAuthorizerController.forbids(:current_user => :blacklisted?, :from => :create)
      end
      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should permit create" do post :create; response.should redirect_to('/success') end
        it "should render index" do get :index; response.should render_template('index') end
      end
      context "a blacklisted user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true, :blacklisted? => true))
        end
        it "should receive a 404 for create" do post :create; response.status.should == "404 Not Found" end
        it "should render index" do get :index; response.should render_template('index') end
      end
      context "an unauthenticated user" do
        it "should receive a 404" do get :index; response.status.should == "404 Not Found" end
      end
    end
  end
  
  describe "using a lambda" do
    context "with a wildcard rule" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => lambda {|u| u.logged_in?})
      end
      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should render index" do get :index; response.should render_template('index') end
      end
    end
    context "that accesses controller environment" do
      before(:each) do
        TestAuthorizerController.class_eval do
          define_method(:user_is_allowed?) { |user| true }
        end
        @user = stub(:logged_in? => true)
        controller.stubs(:current_user => @user)
        TestAuthorizerController.permits(:current_user => lambda {|u| user_is_allowed?(u) })
      end
      context "an allowed_user" do
        it "should render show" do
          controller.expects(:user_is_allowed?).at_least_once.with(@user).returns(true)
          get :show, :id => "100"
          response.should render_template('show')
        end
      end
      context "a logged in user with the wrong ID" do
        it "should render show" do
          controller.expects(:user_is_allowed?).at_least_once.with(@user).returns(false)
          get :show, :id => "100"
          response.status.should == "404 Not Found"
        end
      end
    end
  end
  
  describe "specifying a different action to run on failure" do
    
    it "should check that :on_reject is a Proc or Symbol" do
      lambda do
        TestAuthorizerController.permits(:current_user => :logged_in?, :on_reject => :method)
      end.should_not raise_error
      lambda do
        TestAuthorizerController.permits(:current_user => :logged_in?, :on_reject => lambda {})
      end.should_not raise_error
      lambda do
        TestAuthorizerController.permits(:current_user => :logged_in?, :on_reject => 5)
      end.should raise_error
    end
    
    context "when :on_reject => :set_flash_and_redirect" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?, :on_reject => :set_flash_and_redirect)
        TestAuthorizerController.send(:define_method, :set_flash_and_redirect) do
          flash[:error] = "You need to be logged in to do that"
          redirect_to root_url
        end
      end
      context "an unauthenticated user" do
        it "should redirect to /" do
          get :index
          response.should redirect_to(root_url)
        end
        it "should set the flash" do
          get :index
          flash[:error].should == "You need to be logged in to do that"
        end
      end
    end
    
    context "when :on_reject => lambda" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?, :on_reject => lambda { redirect_to root_url })
      end
      context "an unauthenticated user" do
        it "should redirect to /" do
          get :index
          response.should redirect_to(root_url)
        end
      end
    end
    
    context "with multiple rules" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => :logged_in?)
        TestAuthorizerController.forbids(:current_user => :blacklisted?, :on_reject => :set_blacklisted)
        TestAuthorizerController.send(:define_method, :set_blacklisted) do
          flash[:error] = "You can't be blacklisted to do that"
          redirect_to '/blacklisted'
        end
      end
      
      context "as a blacklisted user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true, :blacklisted? => true))
        end
        it 'should redirect to /blacklisted' do
          get :index
          response.should redirect_to('/blacklisted')
        end
      end
      
    end
  end

end