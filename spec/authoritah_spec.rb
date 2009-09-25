require File.dirname(__FILE__) + '/spec_helper'

describe Authoritah::Controller do
  
  before(:each) do
    ActionController::Base.send(:include, Authoritah::Controller)
    ActionController::Base.send(:clear_permissions)
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
    
  describe "a basic permits wildcard rule" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?)
      @permissions = TestAuthorizerController.send(:controller_permissions)[:test_authorizer]
    end
    it "should have one permission" do @permissions.size.should == 1 end
    it "should use current_user to retrieve the 'role object'" do @permissions.first[:role_method].should == :current_user end
    it "should use logged_in? as the predicate to call on the 'role object'" do @permissions.first[:role_predicate].should == :logged_in? end
    it "should not specify the actions" do @permissions.first[:actions].should == [:all] end
  end

  describe "a basic permits rule on a single action" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?, :to => :show)
      @permissions = TestAuthorizerController.send(:controller_permissions)[:test_authorizer]
    end
    it "should have one permission" do @permissions.size.should == 1 end
    it "should use current_user to retrieve the 'role object'" do @permissions.first[:role_method].should == :current_user end
    it "should use logged_in? as the predicate to call on the 'role object'" do @permissions.first[:role_predicate].should == :logged_in? end
    it "should specify the action" do @permissions.first[:actions].should == [:show] end
  end

  describe "a basic rule on many actions" do
    before(:each) do
      TestAuthorizerController.permits(:current_user => :logged_in?, :to => [:show, :create, :update])
      @permissions = TestAuthorizerController.send(:controller_permissions)[:test_authorizer]
    end
    it "should specify the actions" do @permissions.first[:actions].should == [:show, :create, :update] end
  end
end

describe TestAuthorizerController, :type => :controller do

  before(:each) do
    TestAuthorizerController.send(:include, Authoritah::Controller)
    TestAuthorizerController.send(:clear_permissions)
  end
  
  context "with no permissions set " do
    it "should render the index" do get :index; response.should render_template('index') end
  end
  
  describe "specifying permit rules" do
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
  
  describe "using a Proc" do
    context "with a wildcard rule" do
      before(:each) do
        TestAuthorizerController.permits(:current_user => Proc.new {|u| u.logged_in?})
      end
      context "a logged in user" do
        before(:each) do
          controller.stubs(:current_user => stub(:logged_in? => true))
        end
        it "should render index" do get :index; response.should render_template('index') end
      end
    end
  end
end